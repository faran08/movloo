import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;

  ErrorDialog({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //Hello
          children: [
            Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
