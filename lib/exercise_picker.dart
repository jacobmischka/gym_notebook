import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';

class ExercisePickerWidget extends StatefulWidget {
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
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                        controller: controller,
                        onChanged: handleSearchTextChanged,
                        decoration: InputDecoration(labelText: 'Search')),
                  ),
                  Expanded(
                      child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            var reference = await exercisesReference.add(
                                <String, dynamic>{'name': controller.text});
                            var exercise =
                                Exercise.fromSnapshot(await reference.get());

                            Navigator.pop(context, exercise);
                          }))
                ],
              ),
            ),
            Flexible(
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
