// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locationLib;
import 'package:movloo/LocationForm.dart';
import 'package:movloo/signIU.dart';
import 'package:movloo/webFiles/showGraph.dart';

class webHomePage extends StatefulWidget {
  const webHomePage({super.key, required this.title});

  final String title;

  @override
  State<webHomePage> createState() => _webHomePageState();
}

class _webHomePageState extends State<webHomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  // GoogleMapController _mapController;
  MapType currentMapType = MapType.satellite;
  FirebaseAuth auth = FirebaseAuth.instance;
  late Widget userWidget = Container();
  String userEmail = '';
  Widget actionsWidget = Container();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget floatingAction = Container();
  String _address = '';
  LatLng? _currentPosition;
  bool checkForNewLocation = false;
  List<Marker> _markers = [];
  late BitmapDescriptor myIcon;
  locationLib.Location location = locationLib.Location();
  late bool _serviceEnabled;
  late locationLib.PermissionStatus _permissionGranted;
  final userLocations = FirebaseFirestore.instance.collection('userLocations');

  void _onLongPress(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          MediaQuery.of(context).size.width / 2,
          0,
          MediaQuery.of(context).size.width / 2,
          0), // This position can be changed according to your requirement
      items: [
        PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.location_searching_rounded),
                SizedBox(
                  width: 10,
                ),
                Text("Current Location"),
              ],
            )),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.map_rounded),
              SizedBox(
                width: 10,
              ),
              Text("Map Type"),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _onOptionSelected(value);
      }
    });
  }

  void _onOptionSelected(int value) {
    // Perform your actions based on the selected option
    if (value == 1) {
      print('Option 1 selected');
      moveToCurrentLocation();
    } else if (value == 2) {
      print('Option 2 selected');
      setState(() {
        if (currentMapType == MapType.satellite) {
          currentMapType = MapType.normal;
        } else {
          currentMapType = MapType.satellite;
        }
      });
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    final latitudes = positions.map((position) => position.latitude).toList();
    final longitudes = positions.map((position) => position.longitude).toList();
    final minLat =
        latitudes.reduce((value, element) => value < element ? value : element);
    final maxLat =
        latitudes.reduce((value, element) => value > element ? value : element);
    final minLng = longitudes
        .reduce((value, element) => value < element ? value : element);
    final maxLng = longitudes
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        northeast: LatLng(maxLat, maxLng), southwest: LatLng(minLat, minLng));
  }

  void confirmDelete(BuildContext context, Map<String, dynamic> data) {
    // Create button
    Widget yesButton = TextButton(
      child: Text("YES"),
      onPressed: () {
        userLocations.doc(data['documentID']).delete().then((value) {
          Navigator.of(context).pop();
          loadLocations();
        });
        Navigator.of(context).pop(); // Dismiss the dialog
      },
    );

    Widget noButton = TextButton(
      child: Text("NO"),
      onPressed: () {
        Navigator.of(context).pop(); // Dismiss the dialog
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text("Are you sure you want to delete this Toilet?"),
      actions: [
        noButton,
        yesButton,
      ],
    );

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showInfoPopup(BuildContext context, Map<String, dynamic> data) {
    // Create OKAY button
    Widget okayButton = TextButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CSVGraphPage(
                    locationName: data['location_tag'],
                  )),
        );
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Information"),
      content: Text(
          "This is a test feature, as original data is not available; data shown in this graph is taken from free opensource locations."),
      actions: [
        okayButton,
      ],
    );

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showDialogCustom(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Dialog radius
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 1.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double containerWidth = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // New code
                  children: [
                    Container(
                      width: containerWidth * 0.1,
                      height: containerWidth * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(containerWidth * 0.3),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: containerWidth * 0.05,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(data['location_tag'],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(data['username'],
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    Text(data['cost'].toString(),
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    Text(data['description'],
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    Text('Ratings : 3.5', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 30),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showInfoPopup(context, data);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Stats',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              confirmDelete(context, data);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> loadAllLocations() async {
    final userLocations =
        FirebaseFirestore.instance.collection('userLocations');
    final documents = await userLocations.get();

    setState(() {
      _markers.clear();
      _markers.addAll(documents.docs.map((doc) {
        final data = doc.data();
        GeoPoint geoPoint = data['lat_lng'];
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        return Marker(
          icon: myIcon,
          markerId: MarkerId(doc.id),
          onTap: () {},
          position: latLng,
          infoWindow: InfoWindow(
              title: data['location_tag'] + ' ' + '£' + data['cost'].toString(),
              snippet: 'Tap for details',
              onTap: () {
                showDialogCustom(context, data);
              }),
        );
      }));
    });
  }

  Future<void> loadLocations() async {
    final userLocations =
        FirebaseFirestore.instance.collection('userLocations');
    final documents = await userLocations
        .where('username', isEqualTo: auth.currentUser!.email!)
        .get();

    setState(() {
      _markers.clear();
      _markers.addAll(documents.docs.map((doc) {
        final data = doc.data();
        GeoPoint geoPoint = data['lat_lng'];
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        return Marker(
          icon: myIcon,
          markerId: MarkerId(doc.id),
          position: latLng,
          onTap: () {},
          infoWindow: InfoWindow(
              title: data['location_tag'] + ' ' + '£' + data['cost'].toString(),
              snippet: 'Tap for details',
              onTap: () {
                showDialogCustom(context, data);
              }),
        );
      }));
    });

    if (_markers.isNotEmpty) {
      final bounds =
          _calculateBounds(_markers.map((marker) => marker.position).toList());
      final GoogleMapController mapController = await _controller.future;
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      _scaffoldKey.currentState!.closeDrawer();
    }
  }

  Widget getActionsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUI()),
          );
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        child: const Text(
          'Log In',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> serviceandLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == locationLib.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != locationLib.PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    serviceandLocation().then((value) {
      moveToCurrentLocation();
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(50, 50)), 'assets/icon.png')
        .then((onValue) {
      myIcon = onValue;
    });
    if (mounted) {
      setState(() {
        userEmail = 'Admin Account';
        // floatingAction = FloatingActionButton.extended(
        //   onPressed: () {
        //     setState(() {
        //       if (checkForNewLocation) {
        //         checkForNewLocation = false;
        //       } else if (checkForNewLocation == false) {
        //         checkForNewLocation = true;
        //       }
        //     });
        //   },
        //   label: const Text('Add Toilet'),
        //   icon: const Icon(Icons.add_circle_outline_rounded),
        // );
        userWidget = InkResponse(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.person),
            ),
          ),
        );
      });
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.5058831, -0.0837391),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> moveToCurrentLocation() async {
    location.getLocation().then((value) async {
      print(value.longitude.toString());
      LatLng currentLocation = LatLng(value.latitude!, value.longitude!);
      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              accountEmail: const Text(''),
              currentAccountPicture: const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person),
              ),
              accountName: AutoSizeText(
                userEmail,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.share_location_rounded, color: Colors.black),
              title: const Text('All Toilets'),
              onTap: () {
                setState(() {
                  _markers = [];
                  loadAllLocations();
                });
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.location_off_rounded, color: Colors.black),
              title: const Text('Clear Locations'),
              onTap: () {
                setState(() {
                  _markers = [];
                });
              },
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      appBar: AppBar(
        leading: userWidget,
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Center(
              child: Text(
                'Admin Account',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
        elevation: 1,
        title: DefaultTextStyle(
          style: GoogleFonts.pacifico(fontSize: 20),
          child: ClipOval(
            child: Image.asset(
              "assets/OIG.jpeg",
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: floatingAction,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            onLongPress: (value) {
              _onLongPress(context);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: Set<Marker>.from(_markers),
            onCameraMove: (CameraPosition position) {
              if (checkForNewLocation) _currentPosition = position.target;
            },
            onCameraIdle: () async {
              if (_currentPosition != null && checkForNewLocation) {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                    _currentPosition!.latitude, _currentPosition!.longitude,
                    localeIdentifier: "en");
                if (placemarks.isNotEmpty) {
                  Placemark placemark = placemarks[0];
                  setState(() {
                    _address =
                        '${placemark.street}, ${placemark.administrativeArea}, ${placemark.country}';
                    print(_address);
                  });
                }
              }
            },
            mapType: currentMapType,
            zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (checkForNewLocation)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_address.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          checkForNewLocation = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LocationForm(
                                    address: _address,
                                    latlong: _currentPosition!,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_address.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _address,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const Icon(Icons.location_pin, size: 50),
                ],
              ),
            )
          else
            Container(),
        ],
      ),
    );
  }
}
