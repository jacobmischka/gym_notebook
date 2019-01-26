import 'package:flutter/material.dart';

import 'workout.dart';
import 'exercise.dart';

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
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _workoutEntry.sets.add(ExerciseSet(ExerciseWeight(0), 0));
                    });
                  }),
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

  Future<void> _handleSave() async {
    var form = _formKey.currentState;
    form.save();
    await _workoutEntry.save();
    setState(() {});
  }
}
