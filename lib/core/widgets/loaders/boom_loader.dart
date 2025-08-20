import 'package:flutter/material.dart';

class BoomLoader extends StatelessWidget {
  final String? message;
  final double size;

  const BoomLoader({super.key, this.message, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loader visuel
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
            ),
          ),

          const SizedBox(height: 16),

          if (message != null)
            Text(
              message!,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
