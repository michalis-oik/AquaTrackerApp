import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 213, 212, 255),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromARGB(255, 146, 143, 255), // background circle color
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello",
                            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                          ),
                          Text(
                            "John Doe",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color.fromARGB(255, 146, 143, 255),
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ]),
          )
        ),
      ),
    );
  }
}