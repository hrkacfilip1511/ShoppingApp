import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Authentication/login.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/searchBox.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;


class UploadPage extends StatefulWidget
{
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>
{
  bool get wantKeepAlive => true;
  File file;
  TextEditingController _descriptionTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _shortTextEditingController = TextEditingController();
  String productID = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;
  @override
  Widget build(BuildContext context) {
    return file == null ? displayAdminHomeScreen() : displayUploadFormScreen();
  }
  displayAdminHomeScreen() {
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
            fontFamily: "Vidaloka-Regular",
            fontSize: 35.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
         icon: Icon( Icons.note_add),
          onPressed: () => takeImage(context),
        ),
        actions: [
          FlatButton(
            child: Text("Odjava",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold
            ),
            ),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (c) => AuthenticScreen());
              Navigator.pushReplacement(context, route);
            },
          ),
        ],
      ),
     // body: getAdminHomeScreenBody(),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(pinned: true, delegate: SearchBoxDelegate()),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("items").limit(15).orderBy("publishedDate", descending: true).snapshots(),
            builder: (context, dataSnapshot){
              return !dataSnapshot.hasData ? SliverToBoxAdapter(child: Center(child: circularProgress(),),) :
              SliverStaggeredGrid.countBuilder(
                crossAxisCount: 1,
                staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                itemBuilder: (context, index){
                  ItemModel model = ItemModel.fromJson(dataSnapshot.data.documents[index].data);
                  return sourceInfo(model, context);
                },
                itemCount: dataSnapshot.data.documents.length,
              );
            },
          ),
        ],
      ),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [Colors.red, Colors.orange]),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          ],
        )
      ),
    );
  }
  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (com) {
        return SimpleDialog(
          title: Text("Način biranja slike",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          ),
          children: [
            SimpleDialogOption(
              child: Text("Kamera",
               style: TextStyle(
                 color: Colors.black,
               ),
              ),
              onPressed: capturePhotoWithCamera,
            ),
            SimpleDialogOption(
              child: Text("Izaberite iz galerije",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: pickPhotoFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Izlaz",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }
  capturePhotoWithCamera() async { //funkcija za pristup kameri na emulatoru
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 680.0, maxWidth: 970.0);

    setState(() {
      file = imageFile;
    });
  }
  pickPhotoFromGallery() async{ //funkcija za pristup slika u galeriji na emulatoru
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      file = imageFile;
    });
  }
  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.red, Colors.orange]),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: clearFormInfo,
        ),
        title: Text("Novi artikl",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        ),
        actions: [
          FlatButton(
            onPressed: uploading ? null :  () {
              uploadImageAndSaveItemInfo();
            },
            child: Text("Dodaj", style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),

          ),
          ListTile(
            leading: Icon(Icons.mode_edit, color: Colors.green,),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepOrangeAccent),
                controller: _titleTextEditingController,
                decoration: InputDecoration(
                  hintText: "Količina",
                  hintStyle: TextStyle(color: Colors.pink),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),
          ListTile(
            leading: Icon(Icons.title, color: Colors.green,),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepOrangeAccent),
                controller: _shortTextEditingController,
                decoration: InputDecoration(
                  hintText: "Naziv artikla",
                  hintStyle: TextStyle(color: Colors.pink),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),
          ListTile(
            leading: Icon(Icons.description, color: Colors.green,),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.deepOrangeAccent),
                controller: _descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Opis",
                  hintStyle: TextStyle(color: Colors.pink),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),
          ListTile(
            leading: Icon(Icons.euro_symbol, color: Colors.green,),
            title: Container(
              width: 250.0,
              child: TextField(
                keyboardType: TextInputType.number, //da na tipkovnici mozemo samo brojeve kucat
                style: TextStyle(color: Colors.deepOrangeAccent),
                controller: _priceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Cijena",
                  hintStyle: TextStyle(color: Colors.pink),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),
        ],

      ),
    );
  }
  clearFormInfo() {
    setState(() {
      file = null;
      _descriptionTextEditingController.clear();
      _priceTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortTextEditingController.clear();
    });
  }
  uploadImageAndSaveItemInfo() async{
    setState(() {
      uploading = true;
    });
    uploadItemImage(file);
    String imageDownloadUrl = await uploadItemImage(file);

    saveItemInfo(imageDownloadUrl);
  }
  Future<String> uploadItemImage(mFileImage) async{
    final StorageReference storageReference = FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask uploadTask = storageReference.child("product_$productID.jpg").putFile(mFileImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  saveItemInfo(String downloadUrl) {
    final itemsReference = Firestore.instance.collection("items");
    itemsReference.document(productID).setData({ //spremanje podataka na Cloud Firestore
      "shortInfo": _shortTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "price": int.parse(_priceTextEditingController.text),
      "publishedDate": DateTime.now(),
      "status": "avaliable",
      "thumbnailUrl": downloadUrl,
      "title": _titleTextEditingController.text.trim(),
    });
    setState(() {
      file = null;
      uploading = false;
      productID = DateTime.now().millisecondsSinceEpoch.toString();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortTextEditingController.clear();
      _priceTextEditingController.clear();
    });
  }
}
