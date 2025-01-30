import 'package:flutter/material.dart';

class ErrorDialog {

  const ErrorDialog();

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          titlePadding: const EdgeInsets.all(0),
          // Title and content together:
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A colored container for a header feel
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              // Spacing after the icon
              const SizedBox(height: 16.0),
            ],
          ),
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.close),
              label: const Text('DISMISS'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            const SizedBox(width: 8.0),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
              onPressed: () {
                // TODO: Add your retry logic here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}