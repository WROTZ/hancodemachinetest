
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/service_model.dart';
import 'location_service.dart';

// --- Providers ---

// Location Providers
final locationServiceProvider = Provider((ref) => LocationService());
final currentAddressProvider = FutureProvider<String>((ref) {
  return ref.watch(locationServiceProvider).getCurrentAddress();
});

// Search and filter providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredCleaningServicesProvider = Provider<List<Service>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return allServices.where((service) => service.name.toLowerCase().contains(query)).toList();
});


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> availableServices = [
      {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
      {'icon': Icons.delete_outline, 'label': 'Disposal'},
      {'icon': Icons.plumbing, 'label': 'Plumbing'},
      {'icon': Icons.carpenter_outlined, 'label': 'Carpentry'},
      {'icon': Icons.wash_outlined, 'label': 'Laundry'},
      {'icon': Icons.electrical_services_outlined, 'label': 'Electrician'},
      {'icon': Icons.handyman_outlined, 'label': 'Repair'},
      {'icon': Icons.arrow_forward, 'label': 'See All'},
    ];

    final filteredServices = ref.watch(filteredCleaningServicesProvider);
    final address = ref.watch(currentAddressProvider);

    return Scaffold(
      appBar: AppBar(
        // Use a Consumer to rebuild the AppBar title on location changes
        title: InkWell(
          onTap: () => ref.refresh(currentAddressProvider), // Refresh location on tap
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: address.when(
                  data: (addressText) => Text(
                    addressText,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => const Text(
                    "Fetching location...",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  error: (err, stack) => const Text(
                    "Enable Location", // Show a clear call to action on error
                    style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.black54),
            ],
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/perfect_cleaning_banner.png', height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (query) => ref.read(searchQueryProvider.notifier).state = query,
                      decoration: InputDecoration(
                        hintText: "Search for a service",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF5FCD70), Color(0xFF0E826B)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Available Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: availableServices.length,
                itemBuilder: (context, index) {
                  final service = availableServices[index];
                  return InkWell(
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 30, backgroundColor: Colors.green.withOpacity(0.1), child: Icon(service['icon'], color: Colors.green, size: 28)),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Text(
                            service['label'], 
                            style: const TextStyle(fontSize: 12), 
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Cleaning Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => context.push('/services'), child: const Text("See all")),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    return Card(
                      margin: const EdgeInsets.only(right: 16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              service.image,
                              height: 120, width: 150, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 120, width: 150, color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
       bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0: break;
            case 1: context.push('/bookings'); break;
            case 2: context.push('/profile'); break;
          }
        },
      ),
    );
  }
}
