import 'package:flutter/material.dart';
import 'package:postal_code/postal_code.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  PostalCode? _postalCode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _postalCode?.city ?? "nothing selected",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 36),
                PostalCodeField(
                  countryCode: "cz",
                  onSelected: (postalCode) {
                    setState(() {
                      _postalCode = postalCode;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
