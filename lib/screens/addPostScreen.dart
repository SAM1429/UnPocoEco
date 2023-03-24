import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import './homeScreen.dart';
import './addEventScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => AddPostState();
}

class AddPostState extends State<AddPost> {
  TextEditingController captionControler = TextEditingController();
  File? file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleChooseFromGallery() async {
    Navigator.pop(context);
    PickedFile? file = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);

    if (file != null)
      setState(() {
        this.file = File(file.path);
      });
  }

//so if this option is chosen we add it to the file paramenter of picked file type and then is if is not null we change the state of the file variable which is sike caue now if the state of the file is changed when it re renders the widget tree the change will show in the widget build mehtos and not value wont be null.phew so much expalnation. not random and very important.

  handleTakePhoto() async {
    Navigator.pop(context);
    PickedFile? file = await ImagePicker()
        .getImage(source: ImageSource.camera, maxWidth: 600, maxHeight: 600);

    if (file != null)
      setState(() {
        this.file = File(file.path);
      });
  }

// this is executed when the icon button is pressed and pops up a dialog box here we show 3 options kinda like a switch case
  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create Post'),
            children: [
              SimpleDialogOption(
                child: const Text('Photo with Camera'),
                onPressed: () => handleTakePhoto(),
              ),
              SimpleDialogOption(
                child: const Text('Image from Gallery'),
                onPressed: () => handleChooseFromGallery(),
              ),
              SimpleDialogOption(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  //method is executed nothing has been uploaded yet so in the spalsh screen on the click of the camera icon we call the dialog function

  Scaffold buildSplashScreen() {
    return Scaffold(
      body: Card(
        elevation: 20,
        child: Container(
          color: Theme.of(context).primaryColorLight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text('Add New Post!',
                      style: TextStyle(
                        fontSize: 20,
                      )),
                ),
              ),
              Center(
                child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: FloatingActionButton(
                      onPressed: () => selectImage(context),
                      child: const Icon(Icons.camera_alt_outlined),
                      foregroundColor: Theme.of(context).primaryColorDark,
                      splashColor: Theme.of(context).primaryColorLight,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));

    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String? mediaUrl, required String description}) {
    final curentUser = FirebaseAuth.instance.currentUser;
    if (curentUser != null) {
      final userId = curentUser.uid;
      postsRef.doc(userId).collection("usersPosts").doc(postId).set({
        "postId": postId,
        "ownerId": userId,
        "emailId": curentUser.email,
        "mediaUrl": mediaUrl,
        "description": description,
        "likes": {}
      });

      captionControler.clear();
      setState(() {
        file = null;
        isUploading = false;
        postId = Uuid().v4();
      });
    }
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      description: captionControler.text,
    );
  }

  //in build upload form we display the the appbar with the post option and also the column in the body containing the preview  image and caption

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => clearImage(),
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              shadowColor: Theme.of(context).accentColor,
              elevation: 500,
            ),
            child: Text(
              'Post',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontStyle: FontStyle.normal,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? LinearProgressIndicator() : Text(""),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 220,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(file!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              width: 250,
              child: TextField(
                controller: captionControler,
                decoration: InputDecoration(
                  hintText: 'Add a caption..',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//splash screen if null else we exceute this build upload form functions
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison

    final user = FirebaseAuth.instance.currentUser!;

    return this.file == null ? buildSplashScreen() : buildUploadForm();
  }
}
