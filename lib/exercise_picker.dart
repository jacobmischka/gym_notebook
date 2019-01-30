import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';

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

  ExercisePickerWidgetState() {
    exercisesReference = Firestore.instance.collection('exercises');
  }

  @override
  void initState() {
    super.initState();

    fetchExercises();
  }

  Future<void> fetchExercises() async {
    final snapshot = await exercisesReference.getDocuments();
    final documents = snapshot.documents;

    setState(() {
      for (DocumentSnapshot snapshot in documents) {
        _exercises.add(Exercise.fromSnapshot(snapshot));
      }

      _filteredExercises = _exercises;
    });
  }

  handleSearchTextChanged(String value) {
    setState(() {
      if (value.length == 0) {
        _filteredExercises = _exercises;
      } else {
        _filteredExercises =
            _exercises.where((e) => e.name.contains(value)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Exercise selector')),
        body: Column(
          children: <Widget>[
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                          var exercise =
                              Exercise.fromSnapshot(await reference.get());

                          Navigator.pop(context, exercise);
                        })
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ));
  }
}
