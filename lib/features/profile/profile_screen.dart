
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Safely get initials, defaulting to 'FE'
    final String initials = user?.displayName != null && user!.displayName!.length >= 2
        ? user.displayName!.substring(0, 2).toUpperCase()
        : (user?.email != null && user!.email!.length >= 2 ? user.email!.substring(0, 2).toUpperCase() : "FE");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Updated Avatar to match Figma Specs
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5FCD70), Color(0xFF0E826B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFECECEC), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Fathima Ebrahim",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phoneNumber ?? "+91 989 788 4323",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Wallet", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("Balance - ₹125", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileMenuItem(context, icon: Icons.person_outline, title: "Edit Profile"),
            _buildProfileMenuItem(context, icon: Icons.location_on_outlined, title: "Saved Address"),
            _buildProfileMenuItem(context, icon: Icons.description_outlined, title: "Terms & Conditions"),
            _buildProfileMenuItem(context, icon: Icons.privacy_tip_outlined, title: "Privacy Policy"),
            _buildProfileMenuItem(context, icon: Icons.people_outline, title: "Refer a Friend"),
            _buildProfileMenuItem(context, icon: Icons.support_agent_outlined, title: "Customer Support"),
             const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined, color: Colors.red),
              title: const Text("Log Out", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, {required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}
