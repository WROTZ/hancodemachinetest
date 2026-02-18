
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/services/service_model.dart';

// Manages the list of past bookings
class BookingNotifier extends StateNotifier<List<Booking>> {
  BookingNotifier() : super([]);

  // Add a new booking to the list
  void addBooking(List<CartItem> items, int totalAmount) {
    final newBooking = Booking(
      items: items,
      bookingDate: DateTime.now(),
      totalAmount: totalAmount,
    );
    state = [newBooking, ...state]; // Add to the top of the list
  }
}

// The global provider for our bookings list
final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
  return BookingNotifier();
});
