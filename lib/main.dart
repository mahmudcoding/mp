import 'package:flutter/material.dart';
import 'pages/search.dart';
import 'pages/profile.dart';
import 'pages/cart.dart';
import 'pages/signup.dart';

//storage to check token [AUTH specific]
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Define your pages/screens
  final List<Widget> _pages = [
    const HomeContent(), // Your existing home content
    Search(),
    Cart(),
  ];

    final storage = FlutterSecureStorage();


  void _onProfileTap() async {
    // Check if user is logged in
    final token = await storage.read(key: 'auth_token');
    
    if (token != null && token.isNotEmpty) {
      // User is logged in - navigate to profile page
      setState(() {
        _currentIndex = 3; // Set to profile index
      });
    } else {
      // User is not logged in - navigate to signup page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Signup()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar - only show on home page
      appBar: _currentIndex == 0 
          ? AppBar(
              title: const Text('Student Shop'),
              centerTitle: true,
              elevation: 2,
            )
          : null,

     body: _currentIndex == 3 
          ? const Profile() 
          : _pages[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 3) {
              // Profile tab tapped - check authentication first
              _onProfileTap();
            } else {
              // Other tabs - normal behavior
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Your existing home content wrapped in a StatelessWidget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
        ],
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