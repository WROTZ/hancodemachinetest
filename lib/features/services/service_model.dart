
import 'package:uuid/uuid.dart';

// --- Data Models ---

class Service {
  final String id;
  final String name;
  final int price;
  final String image;
  final String description;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });
}

class CartItem {
  final Service service;
  int quantity;

  CartItem({required this.service, this.quantity = 1});

  void increment() => quantity++;
  void decrement() {
    if (quantity > 1) quantity--;
  }
}

class Booking {
  final String id;
  final List<CartItem> items;
  final DateTime bookingDate;
  final int totalAmount;

  Booking({
    required this.items,
    required this.bookingDate,
    required this.totalAmount,
  }) : id = const Uuid().v4();
}


// --- Dummy Data ---

final List<Service> allServices = [
  Service(id: '1', name: 'Bathroom Cleaning', price: 499, image: 'assets/service_bathroom_cleaning.png', description: '60 Minutes'),
  Service(id: '2', name: 'Home Cleaning', price: 899, image: 'assets/service_home_cleaning.png', description: '120 Minutes'),
  Service(id: '3', name: 'Sofa Cleaning', price: 699, image: 'assets/service_sofa_cleaning.png', description: '90 Minutes'),
  Service(id: '4', name: 'Carpet Cleaning', price: 799, image: 'assets/service_carpet_cleaning.png', description: '90 Minutes'),
  Service(id: '5', name: 'Car Cleaning', price: 599, image: 'assets/service_car_cleaning.png', description: '75 Minutes'),
];
