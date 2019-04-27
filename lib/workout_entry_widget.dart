import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'workout.dart';
import 'exercise.dart';
import 'utils.dart';
import 'decorations.dart';

import 'exercise_history_widget.dart';

class WorkoutEntryWidget extends StatefulWidget {
  final WorkoutEntry _workoutEntry;
  WorkoutEntryWidget(this._workoutEntry);

  @override
  WorkoutEntryWidgetState createState() =>
      WorkoutEntryWidgetState(_workoutEntry);
}

class WorkoutEntryWidgetState extends State<WorkoutEntryWidget> {
  final _formKey = GlobalKey<FormState>();
  WorkoutEntry _workoutEntry;
  WorkoutEntryWidgetState(this._workoutEntry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _workoutEntry.exerciseName(), actions: <Widget>[
        IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Workout history',
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ExerciseHistoryWidget(_workoutEntry.exercise)));
            })
      ]),
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
                initialValue: _workoutEntry.notes,
                maxLines: 3,
                decoration: notesDecoration,
                onSaved: (String value) {
                  _workoutEntry.notes = value;
                }),
          ],
        ),
        onChanged: _handleSave,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              ExerciseSet newSet = _workoutEntry.sets.length > 0
                  ? ExerciseSet.from(_workoutEntry.sets.last)
                  : ExerciseSet(ExerciseWeight(0), 0);

              _workoutEntry.addSet(newSet);
            });
          },
          tooltip: 'Add entry',
          child: Icon(Icons.add)),
    );
  }

  Widget _buildSet(List<ExerciseSet> exerciseSets, int index) {
    var exerciseSet = exerciseSets[index];

    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
                initialValue: nf.format(exerciseSet.weight.weight),
                decoration: InputDecoration(
                  labelText: 'Weight',
                ),
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  exerciseSet.weight.weight = num.parse(value);
                }),
          ),
          Expanded(
            child: PopupMenuButton<WeightUnit>(
              child: Text(describeEnum(exerciseSet.weight.units)),
              initialValue: exerciseSet.weight.units,
              onSelected: (WeightUnit unit) {
                setState(() {
                  exerciseSet.weight.units = unit;
                });
              },
              itemBuilder: (BuildContext context) => WeightUnit.values
                  .map((unit) => PopupMenuItem<WeightUnit>(
                      value: unit, child: Text(describeEnum(unit))))
                  .toList(),
            ),
          ),
          Expanded(
            child: TextFormField(
                initialValue: nf.format(exerciseSet.reps),
                decoration: InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  exerciseSet.reps = double.parse(value);
                }),
          ),
        ],
      ),
      trailing: IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Delete set',
          onPressed: () {
            setState(() {
              _workoutEntry.removeSet(exerciseSet);
            });
          }),
    );
  }

  Future<void> _handleSave() async {
    var form = _formKey.currentState;
    form.save();
    await _workoutEntry.save();
    setState(() {});
  }
}
