import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() async {
    final data = await dbHelper.getItems();
    setState(() {
      cartItems = data;
    });
  }

  void increaseQuantity(int id, int quantity) async {
    await dbHelper.updateItem(id, quantity + 1);
    loadCart();
  }

  void decreaseQuantity(int id, int quantity) async {
    if (quantity > 1) {
      await dbHelper.updateItem(id, quantity - 1);
    } else {
      await dbHelper.deleteItem(id);
    }
    loadCart();
  }

  void clearCart() async {
    for (var item in cartItems) {
      await dbHelper.deleteItem(item['id'] as int);
    }
    loadCart();
  }

  int get totalQuantity {
    int total = 0;
    for (var item in cartItems) {
      total += item['quantity'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: cartItems.isEmpty
            ? const Center(
                child: Text(
                  "Your Cart is Empty 🛒",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              item['item'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "${item['quantity']} Kg"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon:
                                      const Icon(Icons.remove_circle),
                                  color: Colors.red,
                                  onPressed: () =>
                                      decreaseQuantity(
                                          item['id'] as int,
                                          item['quantity']
                                              as int),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.add_circle),
                                  color: Colors.green,
                                  onPressed: () =>
                                      increaseQuantity(
                                          item['id'] as int,
                                          item['quantity']
                                              as int),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Total Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Quantity: $totalQuantity Kg",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: clearCart,
                                child:
                                    const Text("Clear Cart"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title:
                                          const Text("Checkout"),
                                      content: const Text(
                                          "Order Placed Successfully!"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            clearCart();
                                            Navigator.pop(
                                                context);
                                            Navigator.pop(
                                                context);
                                          },
                                          child:
                                              const Text("OK"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child:
                                    const Text("Checkout"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}