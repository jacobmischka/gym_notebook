import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'exercise.dart';

class Workout {
  String id;
  DocumentReference reference;

  FutureOr<List<WorkoutEntry>> entries = [];
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String notes;

  Workout(this.date, this.entries, [this.startTime, this.endTime, this.notes]);

  Workout.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {
    entries = fetchEntries(reference.collection('entries'));
    date = map['date']?.toDate();
    startTime = map['startTime']?.toDate();
    endTime = map['endTime']?.toDate();
    notes = map['notes'];
  }

  Workout.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data,
            id: snapshot.documentID, reference: snapshot.reference);

  Future<List<WorkoutEntry>> fetchEntries(CollectionReference reference) async {
    QuerySnapshot snapshot = await reference.getDocuments();
    return snapshot.documents
        .map((DocumentSnapshot snapshot) => WorkoutEntry.fromSnapshot(snapshot))
        .toList();
  }

  Future<void> save() async {
    reference.updateData(<String, dynamic>{
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes
    });

    // entries.forEach((entry) => entry.save());
  }
}

class WorkoutEntry {
  String id;
  DocumentReference reference;

  FutureOr<Exercise> exercise;
  List<ExerciseSet> sets;
  String notes;

  WorkoutEntry(this.exercise, this.sets, [this.notes]);

  WorkoutEntry.fromMap(Map<String, dynamic> map, {this.id, this.reference}) {
    exercise = fetchExercise(map['exercise']);
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

  WorkoutEntry.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data,
            id: snapshot.documentID, reference: snapshot.reference);

  Future<Exercise> fetchExercise(DocumentReference reference) async {
    DocumentSnapshot snapshot = await reference.get();
    return Exercise(snapshot['name']);
  }

  Widget exerciseName() {
    return FutureBuilder<Exercise>(
        future: exercise,
        builder: (BuildContext context, AsyncSnapshot<Exercise> snapshot) {
          if (!snapshot.hasData) return const Text('...');

          return Text(snapshot.data.name);
        });
  }

  Future<void> save() async {
    reference.updateData(<String, dynamic>{
      'sets': sets.map((exerciseSet) => exerciseSet.toMap()),
      'notes': notes
    });
  }
}

class WorkoutWidget extends StatefulWidget {
  final DocumentSnapshot _workoutSnapshot;
  WorkoutWidget(this._workoutSnapshot);

  @override
  WorkoutWidgetState createState() => WorkoutWidgetState();
}

class WorkoutWidgetState extends State<WorkoutWidget> {
  final _formKey = GlobalKey<FormState>();
  Workout _workout;

  WorkoutWidgetState() {
    _workout = Workout.fromSnapshot(widget._workoutSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(DateFormat("EEEE, MMMM d").format(_workout.date))),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Flexible(
              child: FutureBuilder<List<WorkoutEntry>>(
                  future: _workout.entries,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<WorkoutEntry>> snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');

                    return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, i) =>
                            _buildEntry(context, snapshot.data[i]));
                  }),
            ),
            TextFormField(
              initialValue: _workout.notes,
              decoration: InputDecoration(
                labelText: 'Notes',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, WorkoutEntry workoutEntry) {
    return ListTile(
        title: workoutEntry.exerciseName(),
        subtitle: Text(workoutEntry.sets
            .map((set) => '${set.weight.weight}x${set.reps}')
            .join(', ')),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkoutEntryWidget(workoutEntry)));
        });
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
  WorkoutEntry _workoutEntry;
  WorkoutEntryWidgetState() {
    _workoutEntry = widget._workoutEntry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _workoutEntry.exerciseName()),
      body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Flexible(
                  child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _workoutEntry.sets.length,
                itemBuilder: (context, i) => _buildSet(_workoutEntry.sets, i),
              )),
              TextFormField(
                  initialValue: widget._workoutEntry.notes,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                  ),
                  onSaved: (String value) {
                    _workoutEntry.notes = value;
                  }),
            ],
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: _handleSave,
          tooltip: 'Save workout entry',
          child: Icon(Icons.save)),
    );
  }

  Widget _buildSet(List<ExerciseSet> exerciseSets, int index) {
    var exerciseSet = exerciseSets[index];

    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
              initialValue: exerciseSet.weight.weight.toString(),
              decoration: InputDecoration(
                labelText: 'Weight',
              ),
              keyboardType: TextInputType.number,
              onSaved: (String value) {
                exerciseSet.weight.weight = int.parse(value);
              }),
        ),
        Expanded(
          child: TextFormField(
              initialValue: exerciseSet.reps.toString(),
              decoration: InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              onSaved: (String value) {
                exerciseSet.reps = int.parse(value);
              }),
        ),
      ],
    );
  }

  void _handleSave() {
    var form = _formKey.currentState;
    form.save();
    _workoutEntry.save();
  }
}
