import 'package:flutter/material.dart';
import 'package:pharmafinder/models/medicine_model.dart';
import 'package:pharmafinder/screens/auth_screens/login_screen.dart';
import 'package:pharmafinder/screens/main_screens/medicine_detail_screen.dart';
import 'package:pharmafinder/screens/main_screens/profile_screen.dart';
import 'package:pharmafinder/screens/main_screens/settings_screen.dart';
import 'package:pharmafinder/screens/main_screens/cart_screen.dart';
import 'package:pharmafinder/screens/main_screens/search_screen.dart';
import 'package:pharmafinder/services/medicine_service.dart';
import 'package:pharmafinder/services/auth_service.dart';
import 'package:pharmafinder/widgets/MedicineCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final MedicineService _medicineService = MedicineService();

  late TabController _tabController;
  late Future<List<Medicine>> _allMedicines;
  String _selectedLocation = "Current Location";

  final List<String> _categories = [
    'All',
    'Pain Relief',
    'Cold & Flu',
    'Allergy',
    'Digestive',
    'Antibiotic',
    'Skin Care',
    'Vitamins',
    'Diabetes',
    'Blood Pressure',
    'Mental Health',
    'First Aid',
    'Eye Care',
    'Heart Health',
    'Women\'s Health',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _allMedicines = _medicineService.fetchMedicinesByCategory('All');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildLocationBar()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.teal,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.teal,
                  tabs: _categories.map((cat) => Tab(text: cat)).toList(),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: _categories.map(_buildMedicineGrid).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 140,
      backgroundColor: Colors.teal,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _showUserMenu,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A7B79), Color(0xFF39B9B7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Medicines Nearby',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Search and order essential medicines easily',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedLocation,
              style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: _changeLocation,
            child: const Text('Change', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineGrid(String category) {
    return FutureBuilder<List<Medicine>>(
      future: _allMedicines,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<Medicine> filtered = category == 'All'
            ? snapshot.data!
            : snapshot.data!
                  .where(
                    (med) =>
                        med.category.toLowerCase() == category.toLowerCase(),
                  )
                  .toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No medicines found.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final medicine = filtered[index];
            return MedicineCard(
              medicine: medicine,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicineDetailScreen(medicine: medicine),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildMenuItem(Icons.person, 'My Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }),
            _buildMenuItem(Icons.settings, 'Settings', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),
            _buildMenuItem(Icons.shopping_cart, 'Cart', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            }),
            _buildMenuItem(
              Icons.logout,
              'Logout',
              _confirmLogout,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.teal),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _changeLocation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          const Text(
            "Choose Location",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...[
            'Current Location',
            'Downtown Medical Center',
            'Westside Health District',
            'Eastwood Healthcare Zone',
            'North Hills Pharmacy Hub',
          ].map(
            (location) => ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(location),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedLocation = location);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
