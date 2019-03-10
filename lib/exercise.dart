import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  String id;
  DocumentReference reference;

  String name;
  String notes;

  Exercise(this.name);

  Exercise.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {
    name = map['name'];
    notes = map['notes'];
  }

  Exercise.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data,
            id: snapshot.documentID, reference: snapshot.reference);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'notes': notes};
  }

  Future<void> save() async {
    reference.updateData(toMap());
  }
}

class ExerciseSet {
  ExerciseWeight weight;
  num reps;

  ExerciseSet(this.weight, this.reps);

  Map<String, dynamic> toMap() {
    return {
      'weight': {'weight': weight.weight, 'units': weight.units.toString()},
      'reps': reps
    };
  }

  ExerciseSet.fromMap(Map<String, dynamic> map) {
    WeightUnit weightUnit =
        map['weight']['units'] == 'kg' ? WeightUnit.kg : WeightUnit.lbs;
    weight = ExerciseWeight(map['weight']['weight'], weightUnit);
    reps = map['reps'];
  }

  ExerciseSet.from(ExerciseSet exerciseSet) : this.fromMap(exerciseSet.toMap());
}

class ExerciseWeight {
  num weight;
  WeightUnit units;

  ExerciseWeight(this.weight, [this.units = WeightUnit.lbs]);
}

enum WeightUnit { lbs, kg, plate }

class ExerciseWidget extends StatefulWidget {
  final DocumentSnapshot _exerciseSnapshot;
  ExerciseWidget(this._exerciseSnapshot);

  @override
  ExerciseWidgetState createState() => ExerciseWidgetState();
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  final _formKey = GlobalKey<FormState>();
  Exercise _exercise;

  ExerciseWidgetState() {
    _exercise = Exercise.fromSnapshot(widget._exerciseSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              child: TextFormField(
                initialValue: _exercise.name,
                decoration: InputDecoration(
                  labelText: 'Exercise name',
                  hintText: 'Bench press',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
