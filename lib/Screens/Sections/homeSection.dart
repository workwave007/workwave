import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeSection> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "User";
      });
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text("Home Screen"),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userName == null)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey, ${getGreeting()}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$userName!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const Text(
              "Explore Tools",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  FeatureCard(
                    title: "Resume Builder",
                    imageUrl: "https://images.unsplash.com/photo-1673526759327-54f1f5b27322?fm=jpg&q=60&w=3000",
                    onTap: () {
                      Navigator.pushNamed(context, '/resumeBuilder');
                    },
                  ),
                  FeatureCard(
                    title: "Image to PDF",
                    imageUrl: "https://images.unsplash.com/photo-1673526759327-54f1f5b27322?fm=jpg&q=60&w=3000",
                    onTap: () {
                      Navigator.pushNamed(context, '/imgToPdf');
                    },
                  ),
                  FeatureCard(
                    title: "Compress PDF",
                    imageUrl: "https://images.unsplash.com/photo-1673526759327-54f1f5b27322?fm=jpg&q=60&w=3000",
                    onTap: () {
                      Navigator.pushNamed(context, '/compressPdf');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String imageUrl; // Image URL or asset path
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.2),
          child: Container(
            height: screenWidth / 3,
            width: screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
