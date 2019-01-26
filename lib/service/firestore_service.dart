import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exercise.dart';

class FirestoreService {
  // Stream<QuerySnapshot> getWorkouts() {
  //   Stream<QuerySnapshot> snapshots =
  //       Firestore.instance.collection('workouts').snapshots();
  // }

  // Future<Workout> createWorkout(DateTime date) {
  //   final TransactionHandler createTransaction = (Transaction tx) async {
  //     final DocumentSnapshot ds = await tx.get(Firestore.instance.collection('workouts').document());
  //
  //     final Workout workout = new Workout(ds.documentID, date);
  //     final Map<String, dynamic> data = workout.toMap();
  //
  //     await tx.set(ds.reference, data);
  //
  //     return data;
  //   }
  //
  //   return Firestore.instance.runTransaction(createTransaction).then((mapData) {
  //     return
  //   })
  // }
  //
  // Future<Exercise> createExercise() {
  //
  // }
  //
  // Future<WorkoutEntry> createEntry(Workout workout, Exercise exercise, String ) {
  //
  // }
}
