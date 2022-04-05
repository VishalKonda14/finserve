import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/models/sharedmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListWithEmail extends StatefulWidget {
  const ListWithEmail({Key? key}) : super(key: key);

  @override
  State<ListWithEmail> createState() => _ListWithEmailState();
}

class _ListWithEmailState extends State<ListWithEmail> {
  List<Details> userDetailsList = [];
  final phonecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getExistingData();
    super.initState();
  }

  static bool validateEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  static String? validatePhoneNumber(String val) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regExp = RegExp(pattern);
    debugPrint('${regExp.hasMatch(val)}');
    if (val.isEmpty) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(val)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Duplicate Data"),
      content: const Text("Email/Phone already exists, enter new data."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void getExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var existingData = jsonDecode(prefs.getString('data') ?? '[]');
      if (existingData != null) {
        debugPrint('existing data: ${jsonEncode(existingData)}');
        List<Details> tempData = [];
        await existingData.forEach((v) {
          Details userDetails = Details.fromJson(v);
          tempData.add(userDetails);
        });
        setState(() {
          userDetailsList = tempData;
        });
      }
      debugPrint('init existing data: ${jsonEncode(userDetailsList)}');
    } catch (e) {
      debugPrint('getExistingData(), error:${e.toString()}');
    }
  }

  void save() async {
    bool formValid = _formKey.currentState!.validate();
    debugPrint('data stored $formValid');
    if (formValid) {
      try {
        bool checkIfExists = false;
        for (int i = 0; i < userDetailsList.length; i++) {
          if (phonecontroller.text == userDetailsList[i].phonenumber ||
              emailcontroller.text == userDetailsList[i].email) {
            checkIfExists = true;
          }
        }
        if (!checkIfExists) {
          final prefs = await SharedPreferences.getInstance();
          Details userDetails = Details();
          userDetails.email = emailcontroller.text;
          userDetails.phonenumber = phonecontroller.text;
          setState(() {
            userDetailsList.add(userDetails);
          });
          debugPrint(
              'userDetails length: ${userDetailsList.length} == encoded Data: ${jsonEncode(userDetailsList)}');

          prefs.setString('data', jsonEncode(userDetailsList));
          emailcontroller.clear();
          phonecontroller.clear();
          debugPrint('data stored');
        } else {
          showAlertDialog(context);
        }
      } catch (e) {
        debugPrint('error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Container(
              height: height * 0.2,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                controller: emailcontroller,
                validator: (email) {
                  return validateEmail(email!.trim()) ? null : 'invalid email';
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hintText: 'Email '),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextFormField(
                controller: phonecontroller,
                keyboardType: TextInputType.number,
                validator: (val) {
                  return validatePhoneNumber(val!.trim());
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hintText: 'Phone Number'),
              ),
            ),
            FlatButton(
              onPressed: save,
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
            ),
            if (userDetailsList.isNotEmpty)
              SizedBox(
                height: height * 0.5,
                child: ListView.builder(
                    itemCount: userDetailsList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${userDetailsList[index].email}"),
                          Text('Phn.No: ${userDetailsList[index].phonenumber}'),
                          const Divider(),
                        ],
                      );
                    }),
              )
          ],
        ),
      ),
    );
  }
}
