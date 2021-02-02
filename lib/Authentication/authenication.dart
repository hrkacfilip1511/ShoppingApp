import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'package:e_shop/Config/config.dart';


class AuthenticScreen extends StatefulWidget {
  @override
  _AuthenticScreenState createState() => _AuthenticScreenState();
}

class _AuthenticScreenState extends State<AuthenticScreen> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.lock, color: Colors.white),
                text: "Prijava",
              ),
              Tab(
                icon: Icon(Icons.person, color: Colors.white),
                text: "Registracija",
              ),
            ],
            indicatorColor: Colors.black,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.orange, Colors.red],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                tileMode: TileMode.clamp,
            ),
          ),
          child: TabBarView(
            children: [
              Login(),
              Register(),
          ],
        ),
        ),
      ),
    );
  }
}
