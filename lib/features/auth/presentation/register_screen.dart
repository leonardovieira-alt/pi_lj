import 'package:flutter/material.dart';

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

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthController.text = '${picked.day}/${picked.month}/${picked.year}';
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
    if (isLoading) {
      return;
    }

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

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration inputDecoration({required String hint, Widget? suffixIcon, Widget? prefixIcon}) {
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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Registro',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            'Ja possui uma conta? ',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                      fieldLabel('Aniversario'),
                      TextField(
                        controller: birthController,
                        readOnly: true,
                        onTap: selectDate,
                        decoration: inputDecoration(
                          hint: '01/01/2000',
                          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      fieldLabel('Phone Number'),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: inputDecoration(
                          hint: '(11) 9 1234-5678',
                          prefixIcon: Container(
                            width: 56,
                            alignment: Alignment.center,
                            child: const Text(
                              '+55',
                              style: TextStyle(fontSize: 12, color: Color(0xFF374151)),
                            ),
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
                            onPressed: isLoading
                                ? null
                                : () => setState(() => obscurePassword = !obscurePassword),
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                      if (passwordMessage.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          passwordMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                passwordMessage == 'Senhas iguais' ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA400),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Registrar-se',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
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
