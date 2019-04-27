import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';
import 'exercise.dart';
import 'buttons.dart';
import 'workout.dart';
import 'utils.dart';

class ExerciseHistoryWidget extends StatefulWidget {
  final Exercise exercise;

  ExerciseHistoryWidget(this.exercise);

  @override
  ExerciseHistoryWidgetState createState() =>
      ExerciseHistoryWidgetState(exercise);
}

class ExerciseHistoryWidgetState extends State<ExerciseHistoryWidget> {
  List<Workout> workouts = [];
  bool loading = true;

  ExerciseHistoryWidgetState(Exercise exercise) {
    getApp().then((app) async {
      Firestore firestore = Firestore(app: app);
      FirebaseAuth auth = FirebaseAuth.fromApp(app);
      FirebaseUser user = await auth.currentUser();
      QuerySnapshot workoutsSnapshot = await firestore
          .collection('workouts')
          .where('user', isEqualTo: user.uid)
          .getDocuments();

      List<Workout> allWorkouts =
          workoutsSnapshot.documents.map((DocumentSnapshot snapshot) {
        return Workout.fromSnapshot(snapshot);
      }).toList();

      await Future.wait(allWorkouts.map((workout) => workout.fetchEntries()));

      setState(() {
        workouts = allWorkouts
            .where((workout) => workout.entries.any((WorkoutEntry entry) {
                  return entry.exercise.id == exercise.id;
                }))
            .toList();

        workouts.sort((a, b) => b.date.compareTo(a.date));

        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('${widget.exercise.name} history')),
        body: loading
            ? LoadingWidget()
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: workouts.length,
                itemBuilder: (context, i) => _buildEntry(workouts[i])));
  }

  Widget _buildEntry(Workout workout) {
    WorkoutEntry entry = workout.entries
        .firstWhere((entry) => entry.exercise.id == widget.exercise.id);

    return ListTile(
        title: Text(entry.sets
            .map((set) =>
                '${nf.format(set.weight.weight)}x${nf.format(set.reps)}')
            .join(', ')),
        subtitle: Text(
          dateFormat.format(workout.date),
        ),
        trailing: ShowNotesButton(entry.notes, entry.exercise.name));
  }
}
