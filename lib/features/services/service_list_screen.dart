
import 'package:flutter/material.dart';
import 'service_model.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      Service("1", "Bathroom Cleaning", 499),
      Service("2", "Kitchen Cleaning", 399),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Services")),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (c, i) => ListTile(
          title: Text(services[i].name),
          trailing: const Text("Add"),
        ),
      ),
    );
  }
}
