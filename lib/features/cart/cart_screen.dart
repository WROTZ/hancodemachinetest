
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/booking_provider.dart'; // Import the new booking provider
import '../services/service_model.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final cartItem = cart[index];
                            return _buildCartItem(ref, cartItem.service, cartItem.quantity, index + 1);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => context.push('/services'),
                          icon: const Icon(Icons.add, color: Colors.green),
                          label: const Text("Add more Services", style: TextStyle(color: Colors.green)),
                        ),
                        const SizedBox(height: 24),
                        const Text("Frequently added services", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildFrequentlyAddedServices(),
                        const SizedBox(height: 24),
                        _buildCouponCodeSection(),
                        const SizedBox(height: 24),
                        _buildWalletBalanceInfo(),
                        const SizedBox(height: 24),
                        _buildBillDetails(cart, cartTotal),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isNotEmpty ? _buildBottomActionBar(context, ref, cart, cartTotal) : null,
    );
  }

  Widget _buildCartItem(WidgetRef ref, Service service, int quantity, int itemNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$itemNumber. ${service.name}", style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                InkWell(onTap: () => ref.read(cartProvider.notifier).removeItem(service), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.remove, size: 16))),
                Container(color: Colors.grey.shade300, width: 1, height: 30),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text(quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Container(color: Colors.grey.shade300, width: 1, height: 30),
                InkWell(onTap: () => ref.read(cartProvider.notifier).addItem(service), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.add, size: 16))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 60, child: Text("₹${(service.price * quantity).toStringAsFixed(2)}", textAlign: TextAlign.end, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
  
  Widget _buildFrequentlyAddedServices() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          final service = allServices[index];
          return SizedBox(
            width: 130,
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(right: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(service.image, height: 80, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Center(child: Icon(Icons.error))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCodeSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Coupon Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Coupon Code",
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: () {}, child: const Text("Apply")),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWalletBalanceInfo() {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green),
        const SizedBox(width: 8),
        const Expanded(child: Text("Your wallet balance is ₹125, you can redeem ₹10 in this order.", style: TextStyle(color: Colors.black54))),
      ],
    );
  }

  Widget _buildBillDetails(List<CartItem> cart, int cartTotal) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bill Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...cart.map((item) => _buildBillRow(item.service.name, "₹${(item.service.price * item.quantity).toStringAsFixed(2)}")),
          const Divider(height: 24),
          _buildBillRow("Total", "₹${cartTotal.toStringAsFixed(2)}", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String item, String amount, {bool isTotal = false}) {
    final style = TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey.shade700);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(item, style: style), Text(amount, style: style)],
      ),
    );
  }
  
  Widget _buildBottomActionBar(BuildContext context, WidgetRef ref, List<CartItem> cart, int cartTotal) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Grand Total | ₹${cartTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Save the current cart as a new booking
                ref.read(bookingProvider.notifier).addBooking(List.from(cart), cartTotal);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking Confirmed!'), backgroundColor: Colors.green),
                );
                
                // Clear the cart and navigate home
                ref.read(cartProvider.notifier).clearCart();
                context.go('/');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Book Slot", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
