// ignore: file_names
// ignore_for_file: library_names

import 'package:flutter/material.dart';

mixin globalFunctions on StatefulWidget {
  // you can also constrain the mixin to specific classes using on in this line.

  void showBottomSheetCustom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.5),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: MediaQuery.of(context).size.width * 0.25,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Heading 1',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Username', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Cost', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Description', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      },
    );
  }
}
