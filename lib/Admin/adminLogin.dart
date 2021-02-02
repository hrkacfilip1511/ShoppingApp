//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';




class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.red, Colors.orange]),
          ),
        ),
        title: Text("Grocery App",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Signatra",
            fontSize: 35.0,
          ),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{
  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Colors.red, Colors.orange]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/adminn.png",
                height: 220.0,
                width: 220.0,

              ),
            ),
            SizedBox(height: 10.0,),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: "ID",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.person,
                    hintText: "Lozinka",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              onPressed: () {
                _adminIDTextEditingController.text.isNotEmpty
                    && _passwordTextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorAlertDialog(message: "Molimo, unesite email i lozinku",);
                    }
                );
              },
              color: Colors.pink,
              child: Text("Prijava",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50.0),
            Container(
              height: 8.0,
              width: _screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 20.0,
            ),
            FlatButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>AuthenticScreen())),
              icon: Icon(
                Icons.error,
                color: Colors.white,
              ),
              label: Text("Nisam admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }
  loginAdmin() {
    Firestore.instance.collection("admins").getDocuments().then((snapshot){
      snapshot.documents.forEach((result) {
        if (result.data["id"] != _adminIDTextEditingController.text.trim()) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your ID is not correct."),));
        }
        if (result.data["password"] != _passwordTextEditingController.text.trim()) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your password is not correct."),));
        }
        else{
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Welcome  Dear Admin, " + result.data["name"]),));

          setState(() {
            _adminIDTextEditingController.text = "";
            _passwordTextEditingController.text = "";
          });

          Route route = MaterialPageRoute(builder: (c) => UploadPage());
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }
}
