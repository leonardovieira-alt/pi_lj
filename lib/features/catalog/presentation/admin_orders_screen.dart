import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final List<OrderModel> orders = [
    OrderModel(
      userName: 'Jorge',
      userImage: '',
      items: [
        OrderItem(name: 'Produto 1', quantity: 3, price: 8),
        OrderItem(name: 'Produto 2', quantity: 2, price: 10),
        OrderItem(name: 'Produto 3', quantity: 1, price: 15),
      ],
    ),
  ];

  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (_, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            currency: currency,
            onToggleExpand: () {
              setState(() => order.isExpanded = !order.isExpanded);
            },
            onToggleRetirada: () {
              setState(() => order.isRetirado = !order.isRetirado);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final NumberFormat currency;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleRetirada;

  const _OrderCard({
    required this.order,
    required this.currency,
    required this.onToggleExpand,
    required this.onToggleRetirada,
  });

  @override
  Widget build(BuildContext context) {
    final totalQtd = order.items.fold<int>(0, (sum, e) => sum + e.quantity);
    final totalPrice =
        order.items.fold<double>(0, (sum, e) => sum + (e.quantity * e.price));

    final isRetirado = order.isRetirado;

    return GestureDetector(
      onTap: onToggleExpand,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRetirado ? Colors.green[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isRetirado
                        ? '${order.userName} retirou o pedido de $totalQtd produtos'
                        : '${order.userName} fez um pedido com $totalQtd produtos',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(order.isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),

            if (order.isExpanded) ...[
              const SizedBox(height: 12),

              // HEADER TABELA
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PRODUTO'),
                  Text('QTD'),
                  Text('PREÇO'),
                ],
              ),
              const SizedBox(height: 8),

              // ITENS
              ...order.items.map((item) {
                final totalItem = item.price * item.quantity;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(item.name),
                        ],
                      ),
                      Text('${item.quantity}'),
                      Text(currency.format(totalItem)),
                    ],
                  ),
                );
              }),

              const Divider(),

              // TOTAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL DO PEDIDO'),
                  Text('$totalQtd'),
                  Text(currency.format(totalPrice)),
                ],
              ),

              const SizedBox(height: 12),

              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRetirado ? Colors.orange : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onToggleRetirada,
                  child: Text(
                    isRetirado
                        ? 'Marcar como não retirado'
                        : 'Marcar como retirado',
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class OrderModel {
  final String userName;
  final String userImage;
  final List<OrderItem> items;

  bool isExpanded;
  bool isRetirado;

  OrderModel({
    required this.userName,
    required this.userImage,
    required this.items,
    this.isExpanded = false,
    this.isRetirado = false,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}