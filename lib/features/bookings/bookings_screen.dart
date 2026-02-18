
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../providers/booking_provider.dart';
import '../services/service_model.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text(
                'You have no active bookings.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(booking: booking);
              },
            ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(booking.bookingDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking #${booking.id.substring(0, 8)}", // Show a short ID
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${booking.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const Divider(height: 24),
            const Text("Services:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...booking.items.map((item) => Text("• ${item.service.name} (x${item.quantity})")).toList(),
          ],
        ),
      ),
    );
  }
}
