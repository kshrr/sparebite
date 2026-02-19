import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_listings_page.dart';
import 'upload_food_page.dart';
import 'login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  String ngoStatus = "loading";

  @override
  void initState() {
    super.initState();
    loadUserStatus();
  }

  // ---------------- GET USER NGO STATUS ----------------
  Future<void> loadUserStatus() async {
    final uid = auth.currentUser!.uid;

    final doc = await firestore.collection("users").doc(uid).get();

    setState(() {
      ngoStatus = doc.data()?["ngoStatus"] ?? "none";
    });
  }

  // ---------------- APPLY AS NGO ----------------
  Future<void> applyAsNGO() async {
    final uid = auth.currentUser!.uid;

    await firestore.collection("users").doc(uid).update({
      "ngoStatus": "pending",
    });

    setState(() => ngoStatus = "pending");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("NGO application submitted")),
    );
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await auth.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sparebite"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------- WELCOME ----------
            const Text(
              "Welcome 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            buildNGOStatusBadge(),

            const SizedBox(height: 30),

            // ---------- QUICK ACTIONS ----------
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: actionCard(
                    icon: Icons.add_circle,
                    title: "Donate Food",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UploadFoodPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: actionCard(
                    icon: Icons.history,
                    title: "My Donations",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyListingsPage(),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: actionCard(
                    icon: Icons.track_changes,
                    title: "Matching Status",
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: actionCard(
                    icon: Icons.volunteer_activism,
                    title: "Apply as NGO",
                    onTap: ngoStatus == "none" ? applyAsNGO : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ---------- IMPACT ----------
            const Text(
              "Your Impact",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(child: impactCard("Meals Saved", "24")),
                const SizedBox(width: 15),
                Expanded(child: impactCard("Donations", "5")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- NGO STATUS BADGE ----------------
  Widget buildNGOStatusBadge() {
    Color color;
    String text;

    switch (ngoStatus) {
      case "approved":
        color = Colors.green;
        text = "Verified NGO";
        break;
      case "pending":
        color = Colors.orange;
        text = "NGO Application Pending";
        break;
      default:
        color = Colors.grey;
        text = "Community Member";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color),
      ),
    );
  }

  // ---------------- ACTION CARD ----------------
  Widget actionCard({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Colors.green),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ---------------- IMPACT CARD ----------------
  Widget impactCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}
