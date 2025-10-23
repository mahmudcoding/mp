import 'package:flutter/material.dart';
import 'pages/page1.dart';
import 'pages/page2.dart';
import 'pages/profile.dart';
import 'pages/cart.dart';
import 'pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Shop — Frontend Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        title: const Text('Student Shop'),
        centerTitle: true,
        elevation: 2,
      ),

      // Body with banner, features, categories, product grid, promo strip, and footer
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Big visual banner
            Container(
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage('https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?ixlib=rb-4.0.3&q=80&w=1400&auto=format&fit=crop'),
                ),
              ),
              child: Container(
                // dark overlay
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.35)),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Fresh Summer Collection\nTrendy. Comfortable. Affordable.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2) Feature row (simple icons + labels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _Feature(icon: Icons.local_shipping, title: 'Fast Delivery'),
                  _Feature(icon: Icons.price_check, title: 'Best Prices'),
                  _Feature(icon: Icons.support_agent, title: '24/7 Support'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3) Category chips (static)
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: const [
                  _CategoryChip(label: 'All'),
                  _CategoryChip(label: 'Shoes'),
                  _CategoryChip(label: 'Bags'),
                  _CategoryChip(label: 'Electronics'),
                  _CategoryChip(label: 'Clothes'),
                  _CategoryChip(label: 'Accessories'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 4) Product grid (static cards, no functionality)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _ProductCardStatic(
                    title: 'Running Sneakers',
                    price: '59.99',
                    image: 'https://cdn-icons-png.flaticon.com/512/2972/2972185.png',
                  ),
                  _ProductCardStatic(
                    title: 'Classic Backpack',
                    price: '39.50',
                    image: 'https://cdn-icons-png.flaticon.com/512/107/107831.png',
                  ),
                  _ProductCardStatic(
                    title: 'Wireless Headphones',
                    price: '79.99',
                    image: 'https://cdn-icons-png.flaticon.com/512/3107/3107988.png',
                  ),
                  _ProductCardStatic(
                    title: 'Casual T-Shirt',
                    price: '15.00',
                    image: 'https://cdn-icons-png.flaticon.com/512/2985/2985176.png',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5) Promotional horizontal strip (simple PageView look-alike — static images)
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _PromoTile(image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800&auto=format&fit=crop', label: 'Summer Sale'),
                  _PromoTile(image: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?q=80&w=800&auto=format&fit=crop', label: 'New Arrivals'),
                  _PromoTile(image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800&auto=format&fit=crop', label: 'Gifts'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 6) Call to action banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, size: 36, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Get 10% student discount', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Sign up to our newsletter and get 10% off your first order', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Signup())), child: const Text('Sign Up'))
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 7) Simple footer-like links (navigate to static pages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Page1())),
                    child: const Text('About'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Cart())),
                    child: const Text('Cart content'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Page2())),
                    child: const Text('Contact'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Profile())),
                    child: const Text('Profile'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),

      // Simple bottom bar (no dynamic logic)
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.copyright, size: 16),
              SizedBox(width: 6),
              Text('Student Shop — Demo UI'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small feature widget (icon + label)
class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Feature({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.deepPurple),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Simple category chip (static)
class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey.shade100,
        elevation: 1,
      ),
    );
  }
}

/// Static product card (no actions)
class _ProductCardStatic extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  const _ProductCardStatic({
    required this.title,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2, // two columns spacing
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Image.network(image, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('\$$price', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star, size: 14, color: Colors.orange),
                  SizedBox(width: 6),
                  Text('4.5', style: TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Promo tile for horizontal strip
class _PromoTile extends StatelessWidget {
  final String image;
  final String label;
  const _PromoTile({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.45)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
