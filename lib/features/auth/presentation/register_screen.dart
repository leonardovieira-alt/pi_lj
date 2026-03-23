import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String passwordMessage = '';
  bool isLoading = false;

  final authService = AuthService();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    birthController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  // formatação de número de telefone

  String formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length <= 2) {
      return '(${digits}';
    } else if (digits.length <= 7) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    } else if (digits.length <= 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
    }
  }

  void onPhoneChanged(String value) {
    final formatted = formatPhone(value);

    phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

// formatação de data para o formato brasileiro

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');

      setState(() {
        birthController.text = '$day/$month/${picked.year}';
      });
    }
  }

  void validatePassword() {
    setState(() {
      if (confirmPasswordController.text.isEmpty) {
        passwordMessage = '';
      } else if (passwordController.text == confirmPasswordController.text) {
        passwordMessage = 'Senhas iguais';
      } else {
        passwordMessage = 'Senhas nao coincidem';
      }
    });
  }

  Future<void> register() async {
    if (isLoading) return;

    final nome = nameController.text.trim();
    final email = emailController.text.trim();
    final senha = passwordController.text;
    final senhaConfirm =
        confirmPasswordController.text.isEmpty ? senha : confirmPasswordController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatorios.')),
      );
      return;
    }

    if (senha != senhaConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas devem ser iguais.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await authService.register(
        nome: nome,
        email: email,
        senha: senha,
        senhaConfirm: senhaConfirm,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFFA400), width: 1.2),
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFAE00), Color(0xFFF7F3E9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 20),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Registro',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 20),

                      fieldLabel('Nome Completo'),
                      TextField(
                        controller: nameController,
                        decoration: inputDecoration(hint: 'Usuario da Silva'),
                      ),

                      const SizedBox(height: 12),

                      fieldLabel('Email'),
                      TextField(
                        controller: emailController,
                        decoration: inputDecoration(hint: 'usuario@gmail.com'),
                      ),

                      const SizedBox(height: 12),

                      fieldLabel('Data de Nascimento'),
                      TextField(
                        controller: birthController,
                        readOnly: true,
                        onTap: selectDate,
                        decoration: inputDecoration(
                          hint: 'dd/MM/yyyy',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),

                      const SizedBox(height: 12),

                      fieldLabel('Número de Telefone'),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: onPhoneChanged,
                        decoration: inputDecoration(
                          hint: '(00) 00000-0000',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('+55'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      fieldLabel('Senha'),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        onChanged: (_) => validatePassword(),
                        decoration: inputDecoration(
                          hint: '******',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                        ),
                      ),

                      if (passwordMessage.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          passwordMessage,
                          style: TextStyle(
                            color: passwordMessage == 'Senhas iguais'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Registrar-se'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}