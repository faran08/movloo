import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'auxilaryFiles/ErrorDialog.dart';

class RatingsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  RatingsPage({required this.data});

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  int rating = 0;
  final userReviews = FirebaseFirestore.instance.collection('reviews');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['location_tag']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email Address",
                  fillColor: Colors.grey[100],
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Rating (0 - 5):'),
              Slider(
                value: rating.toDouble(),
                onChanged: (newRating) {
                  setState(() {
                    rating = newRating.round();
                  });
                },
                min: 0,
                max: 5,
                divisions: 5,
                label: rating.toString(),
              ),
              TextFormField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: "Write a Review",
                  fillColor: Colors.grey[100],
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Submitting form')));
                      final reviewData = {
                        'date_time': DateTime.now().millisecondsSinceEpoch,
                        'documentIdOfReview': widget.data['documentID'],
                        'username': widget.data['username'],
                        'emailOfReviewer': emailController.text,
                        'ratingValue': rating,
                        'reviewDescription': reviewController.text
                      };
                      try {
                        userReviews.add(reviewData).then((value) {
                          Fluttertoast.showToast(
                              msg: 'Review Added',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => ErrorDialog(
                            errorMessage: e.toString(),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
