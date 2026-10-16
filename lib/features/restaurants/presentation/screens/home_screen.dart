import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/cart/domain/entities/cart_item.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_state.dart';
import 'package:fooddelivery/features/cart/presentation/screens/cart_screen.dart';
import 'package:fooddelivery/features/foods/presentation/screens/food_menu_screen.dart';
import 'package:fooddelivery/features/orders/presentation/screens/order_history_screen.dart';
import 'package:fooddelivery/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fooddelivery/features/delivery_partner/presentation/screens/delivery_dashboard_screen.dart';
import 'package:fooddelivery/features/restaurant_partner/presentation/screens/partner_dashboard_screen.dart';
import 'package:fooddelivery/features/restaurants/domain/entities/restaurant.dart';
import 'package:fooddelivery/features/restaurants/domain/usecases/get_restaurants.dart';

import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If RestaurantCubit is not already in the widget tree, provide it
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

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FoodGo', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Jaipur, Rajasthan',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
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
            icon: const Icon(Icons.two_wheeler_outlined),
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
            icon: const Icon(Icons.admin_panel_settings_outlined),
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
            icon: const Icon(Icons.storefront_outlined),
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
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<RestaurantCubit>().loadRestaurants(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Search food or restaurants',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              const SizedBox(
                height: 96,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryCard(title: 'Burger', icon: Icons.lunch_dining),
                      _CategoryCard(title: 'Pizza', icon: Icons.local_pizza),
                      _CategoryCard(title: 'Biryani', icon: Icons.rice_bowl),
                      _CategoryCard(title: 'Drinks', icon: Icons.local_drink),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Restaurants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<RestaurantCubit>().loadRestaurants();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              BlocBuilder<RestaurantCubit, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Finding restaurants near you...'),
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
                    if (state.restaurants.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No restaurants available at the moment.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.restaurants.length,
                      itemBuilder: (context, index) {
                        return _RestaurantCard(
                          key: ValueKey(state.restaurants[index].id),
                          restaurant: state.restaurants[index],
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CategoryCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantCard({super.key, required this.restaurant});

  void _showFoodOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return _RestaurantMenuSheet(restaurant: restaurant);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _showFoodOptions(context),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                restaurant.image,
                height: 180,
                width: double.infinity,
                cacheHeight: 360,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${restaurant.rating} ⭐',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      restaurant.cuisine,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.deliveryTime} min delivery',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FoodMenuScreen(restaurant: restaurant),
                              ),
                            );
                          },
                          child: Text(
                            'View Menu →',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
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
