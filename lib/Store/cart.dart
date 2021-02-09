//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Counters/totalMoney.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CartPage extends StatefulWidget {
  final String addressId;
  final double totalAmount;

  CartPage({Key key, this.addressId, this.totalAmount}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmount;

  @override
  void initState() {
    super.initState();
    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).display(0);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if(EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList).length == 1){
            Fluttertoast.showToast(msg: "Košarica je prazna");
          }
          else{
            Route route = MaterialPageRoute(builder: (c) => PaymentPage());
            Navigator.pushReplacement(context, route);
          }
        },
        label: Text("Spremi",
        style: TextStyle(
          //color: Colors.orangeAccent,
        ),
        ),
        backgroundColor: Colors.blueGrey,
        icon: Icon(
          Icons.check,
          color: Colors.green,
        ),
      ),
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(builder: (context, amountProvider, cartProvider, c){
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: cartProvider.count == 0
                      ? Container(
                    /*child: Text("Ukupna cijena: KM ${amountProvider.totalAmount.toString()} ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),*/
                  )
                      : Container(), /* Text("Ukupna cijena: KM ${amountProvider.totalAmount.toString()} ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),*/
                ),
              );
            },),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: EcommerceApp.firestore.collection("items")
              .where("shortInfo", whereIn: EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList)).snapshots(),
            builder: (context, snapshot){
              return !snapshot.hasData
                  ? SliverToBoxAdapter(child: Center(child: circularProgress(),),)
                  : snapshot.data.documents.length == 0
                  ? beginbuildingCart()
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (context,index)
                              {
                                ItemModel model = ItemModel.fromJson(snapshot.data.documents[index].data);
                                if(index == 0){
                                  totalAmount = 0;
                                  totalAmount = model.price + totalAmount;
                                }
                                else{
                                  totalAmount = model.price + totalAmount;
                                }
                                if (snapshot.data.documents.length - 1 == index){
                                  WidgetsBinding.instance.addPostFrameCallback((t){
                                    Provider.of<TotalAmount>(context, listen: false).display(totalAmount);
                                  });
                                }
                                return sourceInfo(model, context, removeCartFunction: () => removeItemFromCart(model.shortInfo));
                              },
                              childCount: snapshot.hasData ? snapshot.data.documents.length : 0,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
  beginbuildingCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Colors.lightBlueAccent,
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sentiment_dissatisfied),
              SizedBox(height: 10.0,),
              Text("Košarica je prazna"),
            ],
          ),
        ),
      ),
    );
  }

  removeItemFromCart(String shortInfoAsId) {
    List tempCartList = EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
    tempCartList.remove(shortInfoAsId);

    EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
        .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .updateData({
      EcommerceApp.userCartList: tempCartList,
    }).then((v){
      Fluttertoast.showToast(msg: "Artikl uspješno izbrisan");
      EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, tempCartList);

      Provider.of<CartItemCounter>(context, listen: false).displayResult();

      totalAmount = 0;
    });
  }
  addOrderDetails() {
    writeOrderDetailsForUser({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID),
      EcommerceApp.productID: EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList),
      EcommerceApp.paymentDetails: "Gotovinsko plaćanje",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    });
    writeOrderDetailsForAdmin({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID),
      EcommerceApp.productID: EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList),
      EcommerceApp.paymentDetails: "Gotovinsko plaćanje",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    }).whenComplete(() => {
      emptyCartNow(),
    });
  }
  emptyCartNow() {
    EcommerceApp.sharedPreferences.setStringList("userCart", ["garbageValue"]);
    List tempList = EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
    Firestore.instance.collection("users").document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID)).updateData({
      EcommerceApp.userCartList: tempList,
    }).then((value) => {
      EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, tempList),
      Provider.of<CartItemCounter>(context, listen: false).displayResult(),
    });
    Fluttertoast.showToast(msg: "Uspješno ste naručili");
    Route route = MaterialPageRoute(builder: (c) =>StoreHome());
    Navigator.pushReplacement(context, route);
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
        .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .collection(EcommerceApp.collectionOrders)
        .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) + data['orderTime']).setData(data);
  }
  Future writeOrderDetailsForAdmin(Map<String, dynamic> data) async {
    await EcommerceApp.firestore
        .collection(EcommerceApp.collectionOrders)
        .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) + data['orderTime']).setData(data);
  }

}
