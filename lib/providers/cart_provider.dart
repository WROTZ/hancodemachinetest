
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/services/service_model.dart';

// Manages the list of items in the cart
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Add a service to the cart or increment its quantity
  void addItem(Service service) {
    final existingItemIndex = state.indexWhere((item) => item.service.id == service.id);

    if (existingItemIndex != -1) {
      final updatedList = List<CartItem>.from(state);
      updatedList[existingItemIndex].increment();
      state = updatedList;
    } else {
      state = [...state, CartItem(service: service)];
    }
  }

  // Decrement an item's quantity or remove it from the cart
  void removeItem(Service service) {
    final existingItemIndex = state.indexWhere((item) => item.service.id == service.id);

    if (existingItemIndex != -1) {
      final updatedList = List<CartItem>.from(state);
      if (updatedList[existingItemIndex].quantity > 1) {
        updatedList[existingItemIndex].decrement();
        state = updatedList;
      } else {
        state = state.where((item) => item.service.id != service.id).toList();
      }
    }
  }

  // Method to clear the entire cart
  void clearCart() {
    state = [];
  }
}

// The global provider for our cart state
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// A provider to compute the total price of items in the cart
final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (total, item) => total + (item.service.price * item.quantity));
});
