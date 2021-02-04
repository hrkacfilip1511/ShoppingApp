import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/orderCard.dart';
import 'package:e_shop/Models/address.dart';
import 'package:e_shop/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

String getOrderId="";
class OrderDetails extends StatelessWidget {
final String orderID;
OrderDetails({Key key, this.orderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getOrderId = orderID;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                .collection(EcommerceApp.collectionOrders)
                .document(orderID).get(),
            builder: (c, snapshot){
              Map dataMap;
              if(snapshot.hasData){
                dataMap = snapshot.data.data;
              }
              return snapshot.hasData
                  ? Container(
                child: Column(
                  children: [
                    StatusBanner(status: dataMap[EcommerceApp.isSuccess],),
                    SizedBox(height: 10.0,),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Text(
                            "Cijena: " + dataMap[EcommerceApp.totalAmount].toString() + " KM",
                            style: TextStyle(
                              fontSize: 19.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 2.0,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("ID narudžbe: " + getOrderId,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      ),
                    ),
                    Divider(
                      height: 2.0,
                      color: Colors.black,
                    ),

                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Naručeno: " + DateFormat("dd MMMM, yyyy - hh:mm aa")
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"]))),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Divider(
                      height: 2.0,
                      color: Colors.black,
                    ),

                    FutureBuilder<QuerySnapshot>(
                      future: EcommerceApp.firestore.collection("items")
                          .where("shortInfo", whereIn: dataMap[EcommerceApp.productID])
                          .getDocuments(),
                      builder: (c, dataSnapshot){
                        return dataSnapshot.hasData
                            ? OrderCard(
                          itemCount: dataSnapshot.data.documents.length,
                          data: dataSnapshot.data.documents,
                        )
                            : Center(child: circularProgress(),);
                      },
                    ),
                    Divider(),
                    FutureBuilder<DocumentSnapshot>(
                      future: EcommerceApp.firestore
                        .collection(EcommerceApp.collectionUser)
                        .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                        .collection(EcommerceApp.subCollectionAddress)
                        .document(dataMap[EcommerceApp.addressID])
                        .get(),
                      builder: (c, snap){
                        return snap.hasData
                            ? ShippingDetails(model: AddressModel.fromJson(snap.data.data),)
                            : Center(child: circularProgress(),);
                      },
                    ),

                  ],
                ),
              )
                  : Center(child: circularProgress(),);
            },
          ),
        ),
      ),
    );
  }
}



class StatusBanner extends StatelessWidget {

  final bool status;
  StatusBanner({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "uspješno" : msg = "neuspješno";

    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [Colors.red, Colors.orange]
        ),
      ),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*GestureDetector(
            onTap: () {
              SystemNavigator.pop(); //Izlaz iz app
            },
            child: Container(
              child: Icon(
                Icons.arrow_drop_down,
              ),
            ),
          ),*/
          SizedBox(width: 20.0,),
          Text("Narudžba izvršena " + msg,
          style: TextStyle(
            color: Colors.white
          ),
          ),
          SizedBox(width: 5.0,),
          CircleAvatar(
            radius: 10.0,
            backgroundColor: Colors.green,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.white,
                size: 14.0,
              ),
            ),
          ),
          SizedBox(width: 15.0,),

        ],
      ),
    );
  }
}




class PaymentDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}



class ShippingDetails extends StatelessWidget {

  final AddressModel model;
  ShippingDetails({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (BuildContext context) {
             return Padding(
              padding: EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Colors.red, Colors.orange]
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  label: Text("Dijeli",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  onPressed:  () {
                    Share.share(getOrderId);
                  },
                ),
              ),
            );
          }
        ),
        SizedBox(height: 20.0,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
          child: Text(
              "Detalji kupovine",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
          width: screenWidth,
          child: Table(
            children: [
              TableRow(
                children: [
                  KeyText(msg: "Ime",),
                  Text(model.name),
                ],
              ),
              TableRow(
                children: [
                  KeyText(msg: "Grad",),
                  Text(model.city),
                ],
              ),
              TableRow(
                children: [
                  KeyText(msg: "Adresa",),
                  Text(model.flatNumber),
                ],
              ),
              TableRow(
                children: [
                  KeyText(msg: "Broj mobitela",),
                  Text(model.phoneNumber),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(

            child: InkWell(
              onTap: () {
                confirmedUserOrder(context, getOrderId);
              },
              child: Container(
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Colors.red, Colors.orange]
                  ),
                ),
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                child: Center(
                  child: Text("Potvrđeno",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  confirmedUserOrder(BuildContext context, String mOrderId) {
    EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                .collection(EcommerceApp.collectionOrders)
                .document(mOrderId).delete();
    getOrderId = "";

    Route route = MaterialPageRoute(builder: (c) => StoreHome());
    Navigator.pushReplacement(context, route);
    Fluttertoast.showToast(msg: "Narudžba je primljena.");
  }
}



