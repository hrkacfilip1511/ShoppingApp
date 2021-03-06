import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Models/address.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final cName = TextEditingController();
  final cPhoneNumber = TextEditingController();
  final cAddress = TextEditingController();
  final cCity = TextEditingController();
  //final cState = TextEditingController();
  //final cPinCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if(formKey.currentState.validate()){
              final model = AddressModel(
                name: cName.text.trim(),
              //  state: cState.text.trim(),
                //pincode: cPinCode.text,
                phoneNumber: cPhoneNumber.text,
                flatNumber: cAddress.text,
                city: cCity.text.trim(),
              ).toJson();
              EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                  .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                  .collection(EcommerceApp.subCollectionAddress).document(DateTime.now().millisecondsSinceEpoch.toString())
                  .setData(model)
                  .then((value) {
                    final snack = SnackBar(content: Text("Adresa je uspješno dodana."));
                    FocusScope.of(context).requestFocus(FocusNode());
                    formKey.currentState.reset();
              });
              Route route = MaterialPageRoute(builder: (c) =>Address());
              Navigator.pushReplacement(context, route);
            }
          },
          label: Text("Gotovo"),
          backgroundColor: Colors.orangeAccent,
          icon: Icon(
            Icons.check_circle_outline,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Dodaj novu adresu",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "Ime i prezime",
                      controller: cName,
                    ),
                    MyTextField(
                      hint: "Grad",
                      controller: cCity,
                    ),
                    /*MyTextField(
                      hint: "Država",
                      controller: cState,
                    ),*/
                    MyTextField(
                      hint: "Adresa",
                      controller: cAddress,
                    ),
                    MyTextField(
                      hint: "Broj mobitela",
                      controller: cPhoneNumber,
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  MyTextField({Key key, this.hint, this.controller,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val) => val.isEmpty ? "Polje ne može ostati prazno" : null,
      ),
    );
  }
}
