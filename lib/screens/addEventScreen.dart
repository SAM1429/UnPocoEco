import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final currentUser = FirebaseAuth.instance.currentUser;

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final locController = TextEditingController();
  final timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                autocorrect: true,
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextFormField(
                controller: descController,
                decoration:
                    const InputDecoration(labelText: 'Event Description'),
              ),
              TextFormField(
                controller: locController,
                decoration: const InputDecoration(labelText: 'Event location'),
              ),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Event time'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final name = nameController.text;
                      final desc = descController.text;
                      final location = locController.text;
                      final timings = timeController.text;
                      final email = currentUser?.email;

                      final event = {
                        'name': name,
                        'description': desc,
                        'location': location,
                        'timings': timings,
                        'email': email,
                      };

                      await FirebaseFirestore.instance
                          .collection('events')
                          .add(event);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}
