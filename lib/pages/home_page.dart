import 'package:flutter/material.dart';
import 'package:bluetooth_low_energy/pages/chat_central.dart';
import 'package:bluetooth_low_energy/pages/chat_periferico.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatPeriferico(),
                      ),
                    );
                  },
                  child: const Text("Chat Periférico"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatCentral(),
                      ),
                    );
                  },
                  child: const Text("Chat Central"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
