import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise.dart';

class Workout {
  final List<WorkoutEntry> entries;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String notes;

  Workout(this.date, this.entries, [this.notes = '']);
}

class WorkoutEntry {
  final Exercise exercise;
  final List<ExerciseSet> sets;
  final String notes;

  WorkoutEntry(this.exercise, this.sets, [this.notes = '']);
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
