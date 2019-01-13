import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Workout(this.date, this.entries, [this.startTime, this.endTime, this.notes]);

  Workout.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {
    fetchEntries(reference.collection('entries'));
    date = map['date']?.toDate();
    startTime = map['startTime']?.toDate();
    endTime = map['endTime']?.toDate();
    notes = map['notes'];
  }

  Workout.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, id: snapshot.documentID, reference: snapshot.reference);

  void fetchEntries(CollectionReference reference) async {
    QuerySnapshot snapshot = await reference.getDocuments();
    this.entries = snapshot.documents.map((DocumentSnapshot snapshot) =>
        WorkoutEntry.fromSnapshot(snapshot)).toList();
  }
}

class WorkoutEntry {
  String id;
  DocumentReference reference;

  Exercise exercise;
  List<ExerciseSet> sets;
  String notes;

  WorkoutEntry(this.exercise, this.sets, [this.notes]);

  WorkoutEntry.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {

    fetchExercise(map['exercise']);
    sets = map['sets'].map((exerciseSetMap) {
      WeightUnit units = exerciseSetMap['weight']['units'] == 'kg' ? WeightUnit.kg : WeightUnit.lbs;
      ExerciseWeight weight = ExerciseWeight(exerciseSetMap['weight']['weight'], units);

      return ExerciseSet(weight, exerciseSetMap['reps']);
    }).toList();
    // (Map<String, dynamic> map) {
    notes = map['notes'];
  }

  WorkoutEntry.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, id: snapshot.documentID, reference: snapshot.reference);

  Future<void> fetchExercise(DocumentReference reference) async {
    DocumentSnapshot snapshot = await reference.get();
    this.exercise = Exercise(snapshot['name']);
  }
}

class WorkoutWidget extends StatefulWidget {
  final Workout _workout;
  WorkoutWidget(this._workout);

  @override
  WorkoutWidgetState createState() => WorkoutWidgetState();
}

class WorkoutWidgetState extends State<WorkoutWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(DateFormat("EEEE, MMMM d").format(widget._workout.date))),
        body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget._workout.entries.length,
            itemBuilder: (context, i) => _buildEntry(context, widget._workout.entries[i])
        )
    );
  }

  Widget _buildEntry(BuildContext context, WorkoutEntry entry) {
    return ListTile(
        title: Text(entry.exercise?.name)
    );
  }
}

class WorkoutEntryWidget extends StatefulWidget {
  final WorkoutEntry _workoutEntry;
  WorkoutEntryWidget(this._workoutEntry);

  @override
  WorkoutEntryWidgetState createState() => WorkoutEntryWidgetState();
}

class WorkoutEntryWidgetState extends State<WorkoutEntryWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._workoutEntry.exercise?.name)),
      body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget._workoutEntry.sets.length,
                itemBuilder: (context, i) =>
                    _buildEntry(widget._workoutEntry.sets[i]),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
              ),
            ],
          ),
          onChanged: _handleFormChange),
    );
  }

  Widget _buildEntry(ExerciseSet exerciseSet) {
    return Row(
      children: <Widget>[
        TextFormField(
            decoration: InputDecoration(
              labelText: 'Weight',
            ),
            keyboardType: TextInputType.number),
        TextFormField(
            decoration: InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number),
      ],
    );
  }

  void _handleFormChange() {}
}

class WorkoutSessionWidget extends StatefulWidget {
  final Workout _workout;
  WorkoutSessionWidget(this._workout);

  @override
  WorkoutSessionWidgetState createState() => WorkoutSessionWidgetState();
}

class WorkoutSessionWidgetState extends State<WorkoutSessionWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(DateFormat("EEEE, MMMM d").format(widget._workout.date))),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget._workout.entries.length,
              itemBuilder: (context, i) =>
                  _buildEntry(widget._workout.entries[i]),
            ),
            TextFormField(
              initialValue: widget._workout.notes,
              decoration: InputDecoration(
                labelText: 'Notes',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(WorkoutEntry logEntry) {
    return ListTile(
        title: Text(logEntry.exercise.name),
        subtitle: Text(logEntry.sets
            .map((set) => '${set.weight.weight}x${set.reps}')
            .join(', ')));
  }
}
