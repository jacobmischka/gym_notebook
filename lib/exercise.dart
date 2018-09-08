import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'table_defs.dart';

class Exercise {
  int id;
  String name;
  String notes;

  Exercise({this.id, this.name = '', this.notes = ''});

  // Unsure if this is how I'll actually do it but I wanted to commit something
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnId: id,
      columnName: name,
      columnNotes: notes
    };
  }

  Exercise.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    notes = map[columnNotes];
  }
}

class ExerciseProvider extends GymLogProvider<Exercise> {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          create table $tableExercises (
            $columnId integer primary key autoincrement,
            $columnName text,
            $columnNotes text
          );
      ''');
    });
  }

  Future<Exercise> insert(Exercise exercise) async {
    exercise.id = await db.insert(tableExercises, exercise.toMap());
    return exercise;
  }

  Future<Exercise> fetch(int id) async {
    List<Map> maps = await db.query(tableExercises,
        columns: [columnId, columnName, columnNotes],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return new Exercise.fromMap(maps.first);
    }

    return null;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableExercises, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Exercise exercise) async {
    return await db.update(tableExercises, exercise.toMap(),
        where: '$columnId = ?', whereArgs: [exercise.id]);
  }

  Future close() async => db.close();
}

class ExerciseSet {
  int id;
  ExerciseWeight weight;
  int reps;

  ExerciseSet({this.id, this.weight, this.reps});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnId: id,
      columnWeight: weight.weight,
      columnUnits: weight.units.toString(),
      columnReps: reps
    };
  }

  ExerciseSet.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    weight = ExerciseWeight(weight: map[columnWeight], units: map[columnUnits]);
    reps = map[columnReps];
  }
}

class ExerciseSetProvider extends GymLogProvider<ExerciseSet> {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          create table $tableExerciseSets (
            $columnId integer primary key autoincrement,
            $columnWeight real,
            $columnUnits text,
            $columnReps integer
          );
      ''');
    });
  }

  Future<ExerciseSet> insert(ExerciseSet exerciseSet) async {
    exerciseSet.id = await db.insert(tableExerciseSets, exerciseSet.toMap());
    return exerciseSet;
  }

  Future<ExerciseSet> fetch(int id) async {
    List<Map> maps = await db.query(
      tableExerciseSets,
      columns: [columnId, columnWeight, columnUnits, columnReps],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return new ExerciseSet.fromMap(maps.first);
    }

    return null;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableExerciseSets, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(ExerciseSet exerciseSet) async {
    return await db.update(tableExerciseSets, exerciseSet.toMap(),
        where: '$columnId = ?', whereArgs: [exerciseSet.id]);
  }

  Future close() async => db.close();
}

class ExerciseWeight {
  int weight;
  WeightUnit units;

  ExerciseWeight({this.weight, this.units = WeightUnit.lbs});
}

enum WeightUnit { lbs, kg }

class ExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  ExerciseWidget(this.exercise);

  @override
  ExerciseWidgetState createState() => ExerciseWidgetState();
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  final _formKey = GlobalKey<FormState>();

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
                initialValue: widget.exercise.name,
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
