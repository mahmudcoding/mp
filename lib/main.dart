import 'package:flutter/material.dart';
import 'pages/page1.dart';
import 'pages/page2.dart';
import 'pages/page3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple E-Commerce',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Sneakers",
      "price": 59.99,
      "image":
      "https://cdn-icons-png.flaticon.com/512/148/148812.png"
    },
    {
      "name": "Backpack",
      "price": 39.50,
      "image":
      "https://cdn-icons-png.flaticon.com/512/107/107831.png"
    },
    {
      "name": "Headphones",
      "price": 79.99,
      "image":
      "https://cdn-icons-png.flaticon.com/512/3107/3107988.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Popular Products',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Product Cards
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      product["image"],
                      width: 50,
                      height: 50,
                    ),
                    title: Text(product["name"]),
                    subtitle: Text("\$${product["price"]}"),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text("Buy Now"),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation Buttons
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.home),
                  label: Text("Home"),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.category),
                  label: Text("Categories"),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Page1()));
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.shopping_cart),
                  label: Text("Cart"),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Page2()));
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.person),
                  label: Text("Profile"),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Page3()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}