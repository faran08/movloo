import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'auxilaryFiles/ErrorDialog.dart';

class SignUI extends StatefulWidget {
  @override
  _SignUIState createState() => _SignUIState();
}

class _SignUIState extends State<SignUI> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void navigatorPop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                controller: _tabController,
                tabs: const [
                  Tab(
                    child: Text(
                      'Log In',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  LoginTab(
                    tabController: _tabController,
                    inputContext: context,
                  ),
                  SignUpTab(
                    tabController: _tabController,
                    inputContext: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginTab extends StatefulWidget {
  LoginTab(
      {super.key, required this.tabController, required this.inputContext});
  @override
  _LoginTabState createState() => _LoginTabState();
  TabController tabController;
  BuildContext inputContext;
}

class _LoginTabState extends State<LoginTab> {
  final _auth = FirebaseAuth.instance;
  TextEditingController loginUser = TextEditingController();
  TextEditingController loginPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: loginUser,
            decoration: InputDecoration(
              hintText: "Email",
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
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              // Use a regular expression to validate the email format
              String pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: TextFormField(
            controller: loginPassword,
            decoration: InputDecoration(
              hintText: "Password",
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
            obscureText: true,
            style: const TextStyle(color: Colors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            EasyLoading.show(
              maskType: EasyLoadingMaskType.clear,
              status: 'Signing In...',
            );
            // Perform Firebase Log In
            try {
              _auth
                  .signInWithEmailAndPassword(
                email: loginUser.text, // Use user-entered email
                password: loginPassword.text, // Use user-entered password
              )
                  .then((value) {
                EasyLoading.dismiss();
                Navigator.of(widget.inputContext).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              }).onError((error, stackTrace) {
                EasyLoading.dismiss();
                showDialog(
                  context: context,
                  builder: (context) => ErrorDialog(
                    errorMessage: error.toString(),
                  ),
                );
              });
            } catch (e) {
              EasyLoading.dismiss();
              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  errorMessage: e.toString(),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.grey.shade100,
            elevation: 1,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(0),
            child: Text('Log in'),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.red,
            backgroundColor: Colors.grey.shade100,
            elevation: 1,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(0),
            child: Text('Forgot Username/ Password'),
          ),
        )
      ],
    );
  }
}

class SignUpTab extends StatefulWidget {
  SignUpTab(
      {super.key, required this.tabController, required this.inputContext});
  @override
  State<SignUpTab> createState() => _SignUpTabState();
  TabController tabController;
  BuildContext inputContext;
}

class _SignUpTabState extends State<SignUpTab> {
  final _auth = FirebaseAuth.instance;

  TextEditingController logupUser = TextEditingController();

  TextEditingController logupPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: logupUser,
            decoration: InputDecoration(
              hintText: "Email",
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
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              // Use a regular expression to validate the email format
              String pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: TextFormField(
            controller: logupPassword,
            decoration: InputDecoration(
              hintText: "Password",
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
            obscureText: true,
            style: const TextStyle(color: Colors.black),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            EasyLoading.show(
              maskType: EasyLoadingMaskType.clear,
              status: 'Sign Up under progress...',
            );
// Perform Firebase Sign Up
            try {
              final user = await _auth.createUserWithEmailAndPassword(
                email: logupUser.text, // Use user-entered email
                password: logupPassword.text, // Use user-entered password
              );
              EasyLoading.dismiss();
              Fluttertoast.showToast(
                  msg: 'User created, please sign In',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.black,
                  fontSize: 16.0);
              widget.tabController.animateTo(0);
            } catch (e) {
              EasyLoading.dismiss();
              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  errorMessage: e.toString(),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.grey.shade100,
            elevation: 1,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Sign up'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.red,
            backgroundColor: Colors.grey.shade100,
            elevation: 1,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Terms and Conditions'),
        )
      ],
    );
  }
}
