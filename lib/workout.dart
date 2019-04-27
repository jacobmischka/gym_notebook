import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';
import 'utils.dart';

class Workout {
  String id;
  DocumentReference reference;

  String user;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<WorkoutEntry> entries = [];
  String notes;

  Workout(this.date, [this.entries, this.startTime, this.endTime, this.notes]);

  Workout.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {
    user = map['user'];
    date = map['date']?.toDate();
    if (map['startTime'] != null) {
      startTime = TimeOfDay.fromDateTime(map['startTime'].toDate());
    }
    if (map['endTime'] != null) {
      endTime = TimeOfDay.fromDateTime(map['endTime'].toDate());
    }
    notes = map['notes'];
  }

  Workout.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data,
            id: snapshot.documentID, reference: snapshot.reference);

  Future<void> fetchEntries() async {
    CollectionReference entriesRef = reference.collection('entries');
    if (entriesRef != null) {
      QuerySnapshot snapshot = await entriesRef.getDocuments();
      entries = List.from(
          await Future.wait(
              snapshot.documents.map((DocumentSnapshot snapshot) async {
            DocumentSnapshot exerciseSnapshot =
                await snapshot.data['exercise'].get();
            Exercise exercise = Exercise.fromSnapshot(exerciseSnapshot);
            return WorkoutEntry.fromSnapshot(snapshot, exercise);
          }).toList()),
          growable: true);

      entries.sort((a, b) {
        if (a.order == null && b.order == null) {
          return 0;
        }

        if (a.order != null && b.order != null) {
          return a.order.compareTo(b.order);
        }

        if (a.order == null) {
          return 1;
        }

        if (b.order == null) {
          return -1;
        }

        return 0;
      });
    }
  }

  static Future<Workout> create(String userId, DateTime date) async {
    Firestore firestore = await getFirestore();

    DocumentReference reference = await firestore
        .collection('workouts')
        .add(<String, dynamic>{'user': userId, 'date': date});
    return Workout.fromSnapshot(await reference.get());
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user,
      'date': date,
      'startTime': startTime != null
          ? DateTime(
              date.year, date.month, date.day, startTime.hour, startTime.minute)
          : null,
      'endTime': endTime != null
          ? DateTime(
              date.year, date.month, date.day, endTime.hour, endTime.minute)
          : null,
      'notes': notes
    };
  }

  Future<void> save() async {
    await reference.updateData(toMap());
  }

  Future<void> delete() async {
    await reference.delete();
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
    // Ideally we wouldn't refetch everything here, but just adding to the list didn't seem to be working.
    // Would like to look into this later but debugging Firebase auth is a pain.
    return fetchEntries();
  }

  Future<void> reorderEntry(int oldIndex, int newIndex) {
    entries.insert(newIndex, entries.removeAt(oldIndex));
    return orderEntries();
  }

  Future<void> orderEntries() {
    List<Future> futures = [];
    for (var i = 0; i < entries.length; i++) {
      entries[i].order = i;
      futures.add(entries[i].save());
    }

    return Future.wait(futures);
  }

  Future<void> removeEntry(WorkoutEntry entry) async {
    entries.remove(entry);

    try {
      await entry.reference.delete();
    } catch (e) {
      debugPrint('Deleting entry failed');
      debugPrint(e);
      entries.add(entry);
    }
  }
}

class WorkoutEntry {
  String id;
  DocumentReference reference;

  Exercise exercise;
  List<ExerciseSet> sets;
  String notes;
  int order;

  WorkoutEntry(this.exercise, this.sets, [this.notes, this.order]);

  WorkoutEntry.fromMap(Map<String, dynamic> map,
      {this.id, this.reference, this.exercise}) {
    sets = map['sets']
        .map((exerciseSetMap) {
          ExerciseWeight weight = ExerciseWeight(
              exerciseSetMap['weight']['weight'],
              unitsFromString(exerciseSetMap['weight']['units']));

          return ExerciseSet(weight, exerciseSetMap['reps']);
        })
        .toList()
        .cast<ExerciseSet>();
    notes = map['notes'];
    order = map['order'];
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
      'notes': notes,
      'order': order
    });
  }

  Future<void> addSet(ExerciseSet exerciseSet) {
    sets.add(exerciseSet);
    return save();
  }

  Future<void> removeSet(ExerciseSet exerciseSet) {
    sets.remove(exerciseSet);
    return save();
  }
}
