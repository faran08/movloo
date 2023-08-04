import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:movloo/auxilaryFiles/ErrorDialog.dart';

class LocationForm extends StatefulWidget {
  final String address;
  final LatLng latlong;

  const LocationForm({Key? key, required this.address, required this.latlong})
      : super(key: key);

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _locationTagController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _locationTagController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildReadOnlyTextField(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      int maxLines, int maxLength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            fillColor: Colors.grey.shade100,
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
          style: const TextStyle(color: Colors.black),
          maxLines: maxLines,
          maxLength: maxLength,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildReadOnlyTextField(
                      'Address',
                      widget.address,
                    ),
                    const SizedBox(height: 10),
                    _buildReadOnlyTextField(
                      'Lat/Long',
                      '${widget.latlong.latitude} ${widget.latlong.longitude}',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        'Location Tag', _locationTagController, 1, 10),
                    const SizedBox(height: 20),
                    _buildTextField('Fee', _feeController, 1, 3),
                    const SizedBox(height: 20),
                    _buildTextField(
                        'Description', _descriptionController, 3, 150),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final cost = int.tryParse(_feeController.text) ?? 0;
                            final locationData = {
                              'date_time':
                                  DateTime.now().millisecondsSinceEpoch,
                              'address': widget.address,
                              'lat_lng': GeoPoint(widget.latlong.latitude,
                                  widget.latlong.longitude),
                              'cost': cost,
                              'location_tag': _locationTagController.text,
                              'description': _descriptionController.text,
                              'username': auth.currentUser!.email,
                            };
                            try {
                              FirebaseFirestore.instance
                                  .collection('userLocations')
                                  .add(locationData)
                                  .then((value) {
                                Fluttertoast.showToast(
                                    msg: 'Location Added',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.black,
                                    fontSize: 16.0);
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
                        child: const Text('Add Location'),
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
