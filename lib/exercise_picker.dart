import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';
import 'utils.dart';

class ExercisePickerWidget extends StatefulWidget {
  final String userId;

  ExercisePickerWidget(this.userId);

  @override
  ExercisePickerWidgetState createState() => ExercisePickerWidgetState();
}

class ExercisePickerWidgetState extends State<ExercisePickerWidget> {
  CollectionReference exercisesReference;
  TextEditingController controller = new TextEditingController();
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];

  @override
  void initState() {
    super.initState();

    fetchExercises();
  }

  Future<void> fetchExercises() async {
    if (exercisesReference == null) {
      Firestore firestore = await getFirestore();
      exercisesReference = firestore.collection('exercises');
    }

    final snapshot = await exercisesReference.getDocuments();
    setState(() {
      _exercises = snapshot.documents
          .map((snapshot) => Exercise.fromSnapshot(snapshot))
          .toList();
      _exercises.sort((a, b) => a.name.compareTo(b.name));
      _filteredExercises = _exercises;
    });
  }

  handleSearchTextChanged(String value) {
    setState(() {
      if (value.length == 0) {
        _filteredExercises = _exercises;
      } else {
        _filteredExercises = _exercises
            .where((e) => e.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise selector')),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                  controller: controller,
                  onChanged: handleSearchTextChanged,
                  decoration: InputDecoration(labelText: 'Search')),
            ),
            IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () async {
                  var reference = await exercisesReference
                      .add(<String, dynamic>{
                    'creator': widget.userId,
                    'name': controller.text
                  });
                  var exercise = Exercise.fromSnapshot(await reference.get());

                  Navigator.pop(context, exercise);
                })
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: _filteredExercises.length,
          itemBuilder: (context, index) {
            var exercise = _filteredExercises[index];
            return new ListTile(
              title: Text(exercise.name),
              onTap: () {
                Navigator.pop(context, exercise);
              },
            );
          }),
    );
  }
}
