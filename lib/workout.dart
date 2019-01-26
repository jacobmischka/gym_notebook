import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';

class Workout {
  String id;
  DocumentReference reference;

  List<WorkoutEntry> entries = [];
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String notes;

  Workout(this.date, [this.entries, this.startTime, this.endTime, this.notes]);

  Workout.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {
    date = map['date'];
    startTime = map['startTime'];
    endTime = map['endTime'];
    notes = map['notes'];
  }

  Workout.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data,
            id: snapshot.documentID, reference: snapshot.reference);

  Future<void> fetchEntries() async {
    CollectionReference entriesRef = reference.collection('entries');
    if (entriesRef == null) {
    } else {
      QuerySnapshot snapshot = await entriesRef.getDocuments();
      entries = List.from(
          await Future.wait(
              snapshot.documents.map((DocumentSnapshot snapshot) async {
            DocumentSnapshot exerciseSnapshot =
                await snapshot.data['exercise'].get();
            Exercise exercise = Exercise(exerciseSnapshot.data['name']);
            return WorkoutEntry.fromSnapshot(snapshot, exercise);
          }).toList()),
          growable: true);
    }
  }

  Future<void> save() async {
    await reference.updateData(<String, dynamic>{
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes
    });
  }

  Future<void> addEntry(Exercise exercise) async {
    DocumentReference entryReference = await reference
        .collection('entries')
        .add(<String, dynamic>{
      'exercise': exercise.reference,
      'notes': '',
      'sets': []
    });
    var entry = WorkoutEntry.fromSnapshot(await entryReference.get(), exercise);
    entries.add(entry);
  }

  Future<void> removeEntry(WorkoutEntry entry) async {
    await entry.reference.delete();
    entries.remove(entry);
  }
}

class WorkoutEntry {
  String id;
  DocumentReference reference;

  Exercise exercise;
  List<ExerciseSet> sets;
  String notes;

  WorkoutEntry(this.exercise, this.sets, [this.notes]);

  WorkoutEntry.fromMap(Map<String, dynamic> map,
      {this.id, this.reference, this.exercise}) {
    sets = map['sets']
        .map((exerciseSetMap) {
          WeightUnit units = exerciseSetMap['weight']['units'] == 'kg'
              ? WeightUnit.kg
              : WeightUnit.lbs;
          ExerciseWeight weight =
              ExerciseWeight(exerciseSetMap['weight']['weight'], units);

          return ExerciseSet(weight, exerciseSetMap['reps']);
        })
        .toList()
        .cast<ExerciseSet>();
    notes = map['notes'];
  }

  WorkoutEntry.fromSnapshot(DocumentSnapshot snapshot, Exercise exercise)
      : this.fromMap(snapshot.data,
            id: snapshot.documentID,
            reference: snapshot.reference,
            exercise: exercise);

  Future<void> fetchExercise(DocumentReference reference) async {
    DocumentSnapshot snapshot = await reference.get();
    exercise = Exercise(snapshot['name']);
  }

  Widget exerciseName() {
    return Text(exercise.name);
  }

  Future<void> save() async {
    reference.updateData(<String, dynamic>{
      'sets': sets.map((exerciseSet) => exerciseSet.toMap()).toList(),
      'notes': notes
    });
  }
}
