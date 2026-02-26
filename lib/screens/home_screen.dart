import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';
import 'feedback_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cartItems = [];

  final List<Map<String, String>> groceryItems = [
    {"name": "Rice", "image": "assets/images/rice1.png"},
    {"name": "Wheat", "image": "assets/images/Wheat.png"},
    {"name": "Sugar", "image": "assets/images/Sugar.png"},
    {"name": "Salt", "image": "assets/images/Salt.png"},
    {"name": "Potato", "image": "assets/images/Potato.png"},
    {"name": "Tomato", "image": "assets/images/Tomato.png"},
    {"name": "Onion", "image": "assets/images/Onion.png"},
    {"name": "Apple", "image": "assets/images/Apple.png"},
    {"name": "Banana", "image": "assets/images/Banana.png"},
    {"name": "Milk", "image": "assets/images/Milk.png"},
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

  int get totalCartItems {
    int total = 0;
    for (var item in cartItems) {
      total += item['quantity'] as int;
    }
    return total;
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

      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CartScreen()),
              ).then((_) => loadCart());
            },
            child: const Icon(Icons.shopping_cart),
          ),
          if (totalCartItems > 0)
            Positioned(
              right: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  totalCartItems.toString(),
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white),
                ),
              ),
            ),
        ],
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

            final cartItem = cartItems.where(
              (element) => element['item'] == item['name'],
            ).toList();

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    item["image"]!,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(item["name"]!,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  cartItem.isEmpty
                      ? ElevatedButton(
                          onPressed: () =>
                              addToCart(item["name"]!),
                          child: const Text("Add"),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => decreaseQuantity(
                                cartItem.first['id'] as int,
                                cartItem.first['quantity'] as int,
                              ),
                            ),
                            Text("${cartItem.first['quantity']} Kg"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => increaseQuantity(
                                cartItem.first['id'] as int,
                                cartItem.first['quantity'] as int,
                              ),
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