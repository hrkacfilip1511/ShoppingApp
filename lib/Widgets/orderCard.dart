import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Orders/OrderDetailsPage.dart';
import 'package:e_shop/Models/item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';

int counter = 0;
class OrderCard extends StatelessWidget {
  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderID;

  OrderCard({Key key, this.itemCount, this.data, this.orderID}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: () {
        Route route;
        if(counter == 0){
          counter = counter + 1;
          route = MaterialPageRoute(builder: (c) => OrderDetails(orderID: orderID));
        }
        Navigator.push(context, route);
      },
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.orange,
        ),
        padding: EdgeInsets.all(3.0),
        margin: EdgeInsets.all(3.0),
        height: itemCount * 140.0,
        child: ListView.builder(
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (c, index){
            ItemModel model = ItemModel.fromJson(data[index].data);
            return sourceOrderInfo(model, context);
          },
        ),
      ),
    );
  }
}



Widget sourceOrderInfo(ItemModel model, BuildContext context,
    {Color background})
{
  width =  MediaQuery.of(context).size.width;

  return  Container(
    color: Colors.white,
    height: 140.0,
    width: width,
    child: Row(
      children: [
        Image.network(model.thumbnailUrl, width: 100.0, height: 100.0,),
        SizedBox(width: 1.0,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.0),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(model.title, style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(model.shortInfo, style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.0,
                      ),),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0,),
              Row(
                children: [
                  SizedBox(width: 10.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     /* Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: Row(
                          children: [
                            Text("Cijena: " + (model.price).toString() ,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.red,
                                //decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(" KM ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.red,
                                // decoration: TextDecoration.lineThrough,
                              ),
                            ),

                          ],
                        ),
                      ),*/

                    ],
                  ),
                ],
              ),
              Flexible(
                child: Container(),
              ),
              Divider(
                height: 5.0,
                color: Colors.brown,
              ),

            ],
          ),
        ),
      ],
    ),
  );
}
