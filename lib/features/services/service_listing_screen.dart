
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'service_model.dart';
import '../../providers/cart_provider.dart';

// Provider to get the total number of items in the cart
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

class ServiceListingScreen extends ConsumerWidget {
  const ServiceListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCount = ref.watch(cartItemCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        // 1. Added Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text("Cleaning Services"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 2. Added Category Filter Chips
              const CategoryFilterChips(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Adjusted padding
                  itemCount: allServices.length,
                  itemBuilder: (context, index) {
                    final service = allServices[index];
                    return ServiceCard(service: service);
                  },
                ),
              ),
            ],
          ),
          // 5. Updated View Cart Button
          if (cartItemCount > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/cart'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$cartItemCount items | ₹${cartTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text("VIEW CART", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

// Widget for the stateful filter chips
class CategoryFilterChips extends StatefulWidget {
  const CategoryFilterChips({super.key});

  @override
  State<CategoryFilterChips> createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  int _selectedIndex = 1; // Maid Services selected by default
  final List<String> _categories = ['Deep cleaning', 'Maid Services', 'Car Cleaning'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_categories.length, (index) {
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: _selectedIndex == index,
            onSelected: (selected) {
              setState(() => _selectedIndex = index);
            },
            selectedColor: Colors.green,
            labelStyle: TextStyle(color: _selectedIndex == index ? Colors.white : Colors.black),
            backgroundColor: Colors.grey.shade200,
            shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
          );
        }),
      ),
    );
  }
}

class ServiceCard extends ConsumerWidget {
  final Service service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.firstWhere((item) => item.service.id == service.id, orElse: () => CartItem(service: service, quantity: 0));
    final quantity = cartItem.quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(service.image, height: 100, width: 100, fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(height: 100, width: 100, color: Colors.grey.shade200, child: const Icon(Icons.error))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Updated Card Details
                  const Text("⭐ 4.2/5 (2.1k Orders)", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(service.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(service.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("₹ ${service.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // 4. Fixed Add/Quantity Buttons
            quantity == 0
                ? ElevatedButton.icon(
                    onPressed: () => ref.read(cartProvider.notifier).addItem(service),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  )
                : Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        InkWell(onTap: () => ref.read(cartProvider.notifier).removeItem(service), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.remove, size: 16))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text(quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        InkWell(onTap: () => ref.read(cartProvider.notifier).addItem(service), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.add, size: 16))),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
