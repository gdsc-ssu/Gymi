import 'package:eyedid_flutter_example/%08screens/home_screen.dart';
import 'package:flutter/material.dart';

class BadScreen extends StatelessWidget {
  final bool isVibrant;
  const BadScreen({super.key, required this.isVibrant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Eye Status: 🤔', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(isVibrant: isVibrant)
                    )
                );
              },
              child: const Text('홈 화면으로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}