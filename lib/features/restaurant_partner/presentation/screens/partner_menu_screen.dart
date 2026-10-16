import 'package:flutter/material.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/foods/data/models/food_model.dart';
import 'package:fooddelivery/features/foods/domain/entities/food.dart';
import 'package:fooddelivery/features/foods/domain/repositories/food_repository.dart';

class PartnerMenuScreen extends StatefulWidget {
  final String restaurantId;

  const PartnerMenuScreen({super.key, this.restaurantId = 'r1'});

  @override
  State<PartnerMenuScreen> createState() => _PartnerMenuScreenState();
}

class _PartnerMenuScreenState extends State<PartnerMenuScreen> {
  final FoodRepository _foodRepository = getIt<FoodRepository>();
  List<Food> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final items = await _foodRepository.getFoodsByRestaurant(
        widget.restaurantId,
      );
      if (mounted) {
        setState(() {
          _foods = List.from(items);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleAvailability(int index) {
    setState(() {
      final current = _foods[index];
      _foods[index] = FoodModel(
        id: current.id,
        restaurantId: current.restaurantId,
        name: current.name,
        description: current.description,
        price: current.price,
        image: current.image,
        category: current.category,
        isAvailable: !current.isAvailable,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_foods[index].name} marked as ${_foods[index].isAvailable ? "Available" : "Unavailable"}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _editPrice(int index) {
    final food = _foods[index];
    final controller = TextEditingController(
      text: food.price.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Price: ${food.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Price (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text.trim());
              if (newPrice != null && newPrice > 0) {
                setState(() {
                  _foods[index] = FoodModel(
                    id: food.id,
                    restaurantId: food.restaurantId,
                    name: food.name,
                    description: food.description,
                    price: newPrice,
                    image: food.image,
                    category: food.category,
                    isAvailable: food.isAvailable,
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Price updated successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Burgers');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Dish Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: catCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
              if (name.isNotEmpty && price > 0) {
                setState(() {
                  _foods.insert(
                    0,
                    FoodModel(
                      id: 'food_${DateTime.now().millisecondsSinceEpoch}',
                      restaurantId: widget.restaurantId,
                      name: name,
                      description: descCtrl.text.trim(),
                      price: price,
                      image: 'assets/images/Burger.png',
                      category: catCtrl.text.trim(),
                      isAvailable: true,
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added to menu!')),
                );
              }
            },
            child: const Text('Add Dish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Catalog')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Dish'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foods.isEmpty
          ? const Center(child: Text('No food items found'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _foods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _foods[index];

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stackTrace) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                item.category,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '₹${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _editPrice(index),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Switch(
                              value: item.isAvailable,
                              onChanged: (_) => _toggleAvailability(index),
                            ),
                            Text(
                              item.isAvailable ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 11,
                                color: item.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
