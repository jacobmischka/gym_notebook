import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'table_defs.dart';

class Exercise {
  int id;
  String name;

  Exercise([this.name = '']);

  // Unsure if this is how I'll actually do it but I wanted to commit something
  Map<String, dynamic> toMap() {
    return <String, dynamic>{columnName: name};
  }

  Exercise.fromMap(Map<String, dynamic> map) {
    name = map[columnName];
  }
}

class ExerciseProvider {
  Database db;
  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          create table $tableExercises (
            $columnId integer primary key autoincrement,
            $columnName text
            );
          ''');
    });
  }

  Future<Exercise> insert(Exercise exercise) async {
    exercise.id = await db.insert(tableExercises, exercise.toMap());
    return exercise;
  }

  Future<Exercise> getExercise(int id) async {
    List<Map> maps = await db.query(tableExercises,
        columns: [columnId, columnName],
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
  final ExerciseWeight weight;
  final int reps;

  ExerciseSet(this.weight, this.reps);
}

class ExerciseWeight {
  final int weight;
  final WeightUnit units;

  ExerciseWeight(this.weight, [this.units = WeightUnit.lbs]);
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
