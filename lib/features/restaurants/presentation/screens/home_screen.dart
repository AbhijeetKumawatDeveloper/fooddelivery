import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fooddelivery/features/auth/presentation/screens/login_screen.dart';
import 'package:fooddelivery/features/cart/domain/entities/cart_item.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_state.dart';
import 'package:fooddelivery/features/cart/presentation/screens/cart_screen.dart';
import 'package:fooddelivery/features/delivery_partner/presentation/screens/delivery_dashboard_screen.dart';
import 'package:fooddelivery/features/orders/presentation/screens/order_history_screen.dart';
import 'package:fooddelivery/features/restaurant_partner/presentation/screens/partner_dashboard_screen.dart';
import 'package:fooddelivery/features/restaurants/domain/entities/restaurant.dart';
import 'package:fooddelivery/features/restaurants/domain/usecases/get_restaurants.dart';

import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = const _HomeScreenBody();

    try {
      context.read<RestaurantCubit>();
    } catch (_) {
      content = BlocProvider(
        create: (_) =>
            RestaurantCubit(getIt<GetRestaurants>())..loadRestaurants(),
        child: content,
      );
    }

    return content;
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _vegOnly = false;
  bool _fastDeliveryOnly = false;
  bool _topRatedOnly = false;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _promoBanners = const [
    {
      'title': 'FLAT 50% OFF',
      'subtitle': 'Use code WELCOME50 on your first 3 orders',
      'tag': 'SPECIAL OFFER',
      'colors': [Color(0xFFE23744), Color(0xFFFF6961)],
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'FoodGo Gold Pass',
      'subtitle': 'Unlimited Free Delivery & 10% Extra OFF',
      'tag': 'PRO MEMBERS',
      'colors': [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      'icon': Icons.stars,
    },
    {
      'title': 'Gourmet Week',
      'subtitle': 'Top Fine Dining Brands with Extra ₹150 OFF',
      'tag': 'CURATED PICKS',
      'colors': [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      'icon': Icons.restaurant_menu,
    },
    {
      'title': 'Late Night Hunger',
      'subtitle': 'Delivering till 4 AM across the city',
      'tag': 'NIGHT DELIVERY',
      'colors': [Color(0xFF1F1C2C), Color(0xFF928DAB)],
      'icon': Icons.nightlight_round,
    },
  ];

  final List<Map<String, String>> _categories = [
    {'title': 'All', 'emoji': '🍽️'},
    {'title': 'Biryani', 'emoji': '🍗'},
    {'title': 'Pizza', 'emoji': '🍕'},
    {'title': 'Burger', 'emoji': '🍔'},
    {'title': 'Thali', 'emoji': '🍱'},
    {'title': 'Chinese', 'emoji': '🍜'},
    {'title': 'Healthy', 'emoji': '🥗'},
    {'title': 'Desserts', 'emoji': '🧇'},
    {'title': 'Ice Cream', 'emoji': '🍨'},
    {'title': 'Drinks', 'emoji': '🥤'},
  ];

  final List<Map<String, String>> _topBrands = [
    {'name': "Domino's", 'time': '22m', 'icon': '🍕'},
    {'name': 'Burger King', 'time': '25m', 'icon': '🍔'},
    {'name': 'Bawarchi', 'time': '32m', 'icon': '🍗'},
    {'name': "Haldiram's", 'time': '28m', 'icon': '🍱'},
    {'name': 'KFC', 'time': '20m', 'icon': '🍗'},
    {'name': 'Subway', 'time': '22m', 'icon': '🥪'},
    {'name': 'Waffle Co.', 'time': '18m', 'icon': '🧇'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> list) {
    return list.where((r) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = r.name.toLowerCase().contains(query);
        final matchCuisine = r.cuisine.toLowerCase().contains(query);
        if (!matchName && !matchCuisine) return false;
      }

      if (_selectedCategory != 'All') {
        if (!r.cuisine.toLowerCase().contains(_selectedCategory.toLowerCase())) {
          return false;
        }
      }

      if (_topRatedOnly && r.rating < 4.5) return false;
      if (_fastDeliveryOnly && r.deliveryTime > 25) return false;
      if (_vegOnly && !r.cuisine.toLowerCase().contains('veg')) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Text(
              'FoodGo',
              style: TextStyle(
                color: Color(0xFFE23744),
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delivering to: Home - 402, Skyline Towers, Indiranagar',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFFE23744),
                        ),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            'Home',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFFE23744),
                        ),
                      ],
                    ),
                    Text(
                      '402, Skyline Towers, Indiranagar',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Account & Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFFEE2E2),
              child: Icon(Icons.person, size: 16, color: Color(0xFFE23744)),
            ),
          ),
          IconButton(
            key: const Key('home_delivery_partner_button'),
            tooltip: 'Delivery Partner Portal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeliveryDashboardScreen(
                    partnerId: 'dp_1',
                    partnerName: 'Vikram Singh (Delivery Hero)',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.two_wheeler_outlined,
              color: Color(0xFF00897B),
            ),
          ),
          IconButton(
            key: const Key('home_admin_portal_button'),
            tooltip: 'Admin Portal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
            icon: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFF1E293B),
            ),
          ),
          IconButton(
            key: const Key('home_partner_pos_button'),
            tooltip: 'Partner POS Portal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PartnerDashboardScreen(
                    restaurantId: 'r1',
                    restaurantName: 'Burger Hub (Partner POS)',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFFE65100),
            ),
          ),
          IconButton(
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          BlocSelector<CartCubit, CartState, int>(
            selector: (state) =>
                (state is CartLoaded) ? state.totalItemCount : 0,
            builder: (context, count) {
              return Badge(
                isLabelVisible: count > 0,
                backgroundColor: const Color(0xFFE23744),
                label: Text('$count'),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFFE23744),
            onRefresh: () => context.read<RestaurantCubit>().loadRestaurants(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Section (Zomato-style)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText:
                              "Search 'Biryani', 'Pizza', 'Burger King'...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFE23744),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : const Icon(Icons.mic, color: Color(0xFFE23744)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // "What's on your mind?" Category Rail
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "WHAT'S ON YOUR MIND?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 92,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected = _selectedCategory == cat['title'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat['title']!;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFFE23744)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFE23744)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(6),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat['emoji']!,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat['title']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFFE23744)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Section Header: All Restaurants
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ALL RESTAURANTS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: () {
                            context.read<RestaurantCubit>().loadRestaurants();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Restaurant List View
                  BlocBuilder<RestaurantCubit, RestaurantState>(
                    builder: (context, state) {
                      if (state is RestaurantLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFFE23744),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Finding best restaurants near you...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is RestaurantFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFE23744),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<RestaurantCubit>()
                                        .loadRestaurants();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is RestaurantLoaded) {
                        final filtered = _filterRestaurants(state.restaurants);

                        if (filtered.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 54,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? "No restaurants match '$_searchQuery'"
                                        : 'No restaurants match current filters.',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedCategory = 'All';
                                        _vegOnly = false;
                                        _fastDeliveryOnly = false;
                                        _topRatedOnly = false;
                                        _searchController.clear();
                                      });
                                    },
                                    child: const Text('Reset Filters'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final restaurant = filtered[index];
                            return _ZomatoRestaurantCard(
                              restaurant: restaurant,
                              onTap: () => _showMenuBottomSheet(context, restaurant),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Top Curated Brands Rail
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'TOP BRANDS FOR YOU',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 85,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _topBrands.length,
                      itemBuilder: (context, i) {
                        final b = _topBrands[i];
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                b['icon']!,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b['name']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                b['time']!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Promotional Carousel (Zomato Offers)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'SPECIAL OFFERS & DEALS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _promoBanners.length,
                      itemBuilder: (context, idx) {
                        final banner = _promoBanners[idx];
                        return Container(
                          width: 290,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: banner['colors'] as List<Color>,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (banner['colors'] as List<Color>).first
                                    .withAlpha(60),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      banner['tag'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    banner['icon'] as IconData,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner['title'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    banner['subtitle'] as String,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Filter Chips (Rating, Veg, Fast Delivery)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        FilterChip(
                          avatar: const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          label: const Text('Ratings 4.5+'),
                          selected: _topRatedOnly,
                          selectedColor: const Color(0xFFFEE2E2),
                          onSelected: (val) {
                            setState(() {
                              _topRatedOnly = val;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          avatar: const Icon(
                            Icons.bolt,
                            size: 14,
                            color: Colors.orange,
                          ),
                          label: const Text('Under 25 mins'),
                          selected: _fastDeliveryOnly,
                          selectedColor: const Color(0xFFFEE2E2),
                          onSelected: (val) {
                            setState(() {
                              _fastDeliveryOnly = val;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          avatar: const Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.green,
                          ),
                          label: const Text('Pure Veg'),
                          selected: _vegOnly,
                          selectedColor: const Color(0xFFFEE2E2),
                          onSelected: (val) {
                            setState(() {
                              _vegOnly = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Bottom Cart Bar (Zomato-style Sticky Cart)
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.totalItemCount > 0) {
                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE23744),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${state.totalItemCount} ITEMS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '₹${state.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Text(
                                'View Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: _RestaurantMenuSheet(restaurant: restaurant),
      ),
    );
  }
}

class _ZomatoRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _ZomatoRestaurantCard({
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image with Discount Banner & Floating Rating
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: restaurant.image.startsWith('http')
                      ? Image.network(
                          restaurant.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Image.asset(
                          restaurant.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(160),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Discount Pill Overlay (Zomato style)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_offer, size: 12, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          'FLAT 50% OFF UP TO ₹100',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating Rating Badge
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24963F),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.star, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Restaurant Details Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹300 for two',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} mins',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.near_me_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '2.1 km',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      const Text(
                        'Explore Menu >',
                        style: TextStyle(
                          color: Color(0xFFE23744),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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

class _RestaurantMenuSheet extends StatefulWidget {
  final Restaurant restaurant;

  const _RestaurantMenuSheet({required this.restaurant});

  @override
  State<_RestaurantMenuSheet> createState() => _RestaurantMenuSheetState();
}

class _RestaurantMenuSheetState extends State<_RestaurantMenuSheet> {
  late final List<CartItem> _menuItems;
  final Map<String, int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    _menuItems = [
      CartItem(
        foodId: '${widget.restaurant.id}_special',
        name: '${widget.restaurant.name} Special',
        image: widget.restaurant.image,
        price: 249,
        quantity: 1,
        restaurantId: widget.restaurant.id,
      ),
      CartItem(
        foodId: '${widget.restaurant.id}_combo',
        name: 'Deluxe Combo Meal',
        image: widget.restaurant.image,
        price: 349,
        quantity: 1,
        restaurantId: widget.restaurant.id,
      ),
      CartItem(
        foodId: '${widget.restaurant.id}_drink',
        name: 'Chilled Beverage',
        image: 'assets/images/Cola.png',
        price: 79,
        quantity: 1,
        restaurantId: widget.restaurant.id,
      ),
    ];

    for (final item in _menuItems) {
      _selectedQuantities[item.foodId] = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.restaurant.cuisine,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select items and quantities to add to your cart',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const Divider(height: 24),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _menuItems.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final qty = _selectedQuantities[item.foodId] ?? 1;

                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.image,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.fastfood,
                              size: 40,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${item.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            onPressed: () {
                              if (qty > 1) {
                                setState(() {
                                  _selectedQuantities[item.foodId] = qty - 1;
                                });
                              }
                            },
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedQuantities[item.foodId] = qty + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: () {
                        final itemToAdd = item.copyWith(quantity: qty);
                        context.read<CartCubit>().addToCart(itemToAdd);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$qty x ${item.name} added to cart'),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

