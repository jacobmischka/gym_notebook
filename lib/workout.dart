import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'exercise.dart';
import 'table_defs.dart';

class Workout {
  int id;
  List<WorkoutEntry> entries;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String notes;

  Workout({this.date, this.entries, this.notes = ''});
}

class WorkoutEntry {
  int id;
  int workoutId;
  Exercise exercise;
  List<ExerciseSet> sets;
  String notes;

  WorkoutEntry(
      {this.id, this.workoutId, this.exercise, this.sets, this.notes = ''});

  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnWorkoutId: workoutId,
      columnExerciseId: exercise.id,
      columnNotes: notes
    };
  }

  WorkoutEntry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    workoutId = map[columnWorkoutId];
    // Hm unsure
    // exerciseId = map[columnExerciseId];
    notes = map[columnNotes];
  }
}

class WorkoutEntryProvider {
  Database db;
  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          create table $tableExercises (
            $columnId integer primary key autoincrement,
            $columnWorkoutId integer,
            $columnExerciseId integer,
            $columnNotes text
          );
      ''');
    });
  }

  Future<WorkoutEntry> insert(WorkoutEntry workoutEntry) async {
    workoutEntry.id =
        await db.insert(tableWorkoutEntries, workoutEntry.toMap());
    return workoutEntry;
  }

  Future<WorkoutEntry> fetch(int id) async {
    // TODO
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
      appBar: AppBar(title: Text(widget._workoutEntry.exercise.name)),
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
