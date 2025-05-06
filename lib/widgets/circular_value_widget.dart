import 'package:flutter/material.dart';

class CircularValueWidget extends StatelessWidget {
  final String label;
  final String value;

  const CircularValueWidget({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:  Border.all(color: Colors.orange, width: 6),
          ),
          child: Center(
            child: Text(
              '$value $label',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
