import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/wideButton.dart';
import 'package:e_shop/Models//address.dart';
import 'package:e_shop/Counters/changeAddresss.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'addAddress.dart';

class Address extends StatefulWidget
{
  final double totalAmount;
  const Address({Key key, this.totalAmount}): super(key: key);
  @override
  _AddressState createState() => _AddressState();
}


class _AddressState extends State<Address>
{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Izaberite adresu",
                    style: TextStyle(
                      color: Colors.black, fontSize: 17.0,
                    ),
                  ),
                ),
              ),
            ),
            Consumer<AddressChanger>(builder: (context, address, c){
              return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                  .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                  .collection(EcommerceApp.subCollectionAddress).snapshots(),

                  builder: (context, snapshot){
                    return !snapshot.hasData
                        ? Center(child: circularProgress(),)
                        : snapshot.data.documents.length == 0
                        ? noAddressCard()
                        : ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index){
                            return AddressCard(
                              currentIndex: address.count,
                              value: index,
                              addressId: snapshot.data.documents[index].documentID,
                              totalAmount: widget.totalAmount,
                              model: AddressModel.fromJson(snapshot.data.documents[index].data),
                            );
                          },
                    );
                  },
                ),
              );
            })
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Dodaj novu adresu'),
          backgroundColor: Colors.orangeAccent,
          icon: Icon(
            Icons.add_location,
          ),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (c) => AddAddress());
            Navigator.pushReplacement(context, route);
          },
        ),
      ),
    );
  }

  noAddressCard() {
    return Card(
      color: Colors.orangeAccent,
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error,color: Colors.white,),
            Text("Nemate spremljenu adresu."),
            Divider(color: Colors.blue,),
            Text("Molimo dodajte adresu."),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;
  final String addressId;
  final double totalAmount;
  final int currentIndex;
  final int value;

  AddressCard({Key key, this.model, this.addressId, this.totalAmount, this.currentIndex, this.value}) : super(key: key);
  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Provider.of<AddressChanger>(context, listen: false).displayResult(widget.value);
      },
      child: Card(
        color: Colors.orangeAccent,
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex,
                  value: widget.value,
                  activeColor: Colors.blueGrey,
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false).displayResult(val);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: screenwidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(msg: "Ime",),
                              Text(widget.model.name),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Grad",),
                              Text(widget.model.city),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Adresa i kućni broj",),
                              Text(widget.model.flatNumber),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(msg: "Broj mobitela",),
                              Text(widget.model.phoneNumber),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.value == Provider.of<AddressChanger>(context).count
            ? WideButton(
              message: "Dalje",
              onPressed: () {
                Route route = MaterialPageRoute(builder: (c) => PaymentPage(
                  addressId: widget.addressId,
                  totalAmount: widget.totalAmount,
                ));
                Navigator.push(context, route);
              },
            ) : Container(),
          ],
        ),
      ),
    );
  }
}





class KeyText extends StatelessWidget {
  final String msg;
  KeyText({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(
        color: Colors.black,
      ),
    );
  }
}
