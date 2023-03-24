import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './addPostScreen.dart';

final Reference storageRef = FirebaseStorage.instance.ref();
final postsRef = FirebaseFirestore.instance.collection('posts');
final usersPosts = FirebaseFirestore.instance.collectionGroup('usersPosts');

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text(user.email.toString()),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/landing');
            },
            child: const Text(
              'SignOut',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/addpost'),
            icon: const Icon(Icons.add_box_outlined),
            color: Theme.of(context).accentColor,
            iconSize: 30,
          ),
        ],
      ),
      drawer: Drawer(
          backgroundColor: Theme.of(context).accentColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                ListTile(
                  title: const Text(
                    'Schedule events',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/eventScreen');
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: const Text(
                    'Global News!',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/globalNews');
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersPosts.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('snapshot has error'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              final description = data['description'];
              final mediaUrl = data['mediaUrl'];
              final emailId = data['emailId'];
              final postId = data['postId'];

              return Card(
                shadowColor: Colors.black,
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              emailId,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                            if (emailId == user.email)
                              IconButton(
                                onPressed: () async {
                                  postsRef
                                      .doc(user.uid)
                                      .collection('usersPosts')
                                      .doc(postId)
                                      .delete();
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColorDark,
                                width: 2.0),
                            borderRadius: const BorderRadius.all(
                              Radius.zero,
                            ),
                          ),
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: Image.network(
                              mediaUrl,
                              fit: BoxFit.cover,
                            ),
                          )),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
