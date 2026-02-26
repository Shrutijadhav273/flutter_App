import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cartItems = [];

  final List<Map<String, String>> groceryItems = [
    {"name": "Rice", "image": "https://i.imgur.com/6X4P6bH.png"},
    {"name": "Wheat", "image": "https://i.imgur.com/5Aqgz7o.png"},
    {"name": "Sugar", "image": "https://i.imgur.com/3ZQ3Z6V.png"},
    {"name": "Salt", "image": "https://i.imgur.com/Jp8bF9L.png"},
    {"name": "Potato", "image": "https://i.imgur.com/BP4y9XG.png"},
    {"name": "Tomato", "image": "https://i.imgur.com/sR4X8pL.png"},
    {"name": "Onion", "image": "https://i.imgur.com/lm0Yk3T.png"},
    {"name": "Apple", "image": "https://i.imgur.com/kXq8w3L.png"},
    {"name": "Banana", "image": "https://i.imgur.com/Fz8R3Vh.png"},
    {"name": "Milk", "image": "https://i.imgur.com/3mXk9XG.png"},
  ];

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

  void addToCart(String itemName) async {
    await dbHelper.addItem(itemName, 1);
    loadCart();
  }

  void increaseQuantity(int id, int currentQty) async {
    await dbHelper.updateItem(id, currentQty + 1);
    loadCart();
  }

  void decreaseQuantity(int id, int currentQty) async {
    if (currentQty > 1) {
      await dbHelper.updateItem(id, currentQty - 1);
    } else {
      await dbHelper.deleteItem(id);
    }
    loadCart();
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
              ),
              child: Text("Grocery Menu",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Grocery Store"),
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
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: groceryItems.length,
          itemBuilder: (context, index) {
            final item = groceryItems[index];

            final cartItem = cartItems.firstWhere(
              (element) => element['item'] == item['name'],
              orElse: () => {},
            );

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(item["image"]!, height: 80),
                  const SizedBox(height: 10),
                  Text(item["name"]!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  cartItem.isEmpty
                      ? ElevatedButton(
                          onPressed: () =>
                              addToCart(item["name"]!),
                          child: const Text("Add 1 Kg"),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  decreaseQuantity(
                                      cartItem['id'],
                                      cartItem['quantity']),
                            ),
                            Text("${cartItem['quantity']} Kg"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  increaseQuantity(
                                      cartItem['id'],
                                      cartItem['quantity']),
                            ),
                          ],
                        )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}