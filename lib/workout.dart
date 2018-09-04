import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise.dart';

class Workout {
  final List<WorkoutEntry> entries;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  Workout(this.date, this.entries);
}

class WorkoutEntry {
  final Exercise exercise;
  final List<ExerciseSet> sets;
  final String notes;

  WorkoutEntry(this.exercise, this.sets, [this.notes = '']);
}

class WorkoutWidget extends StatelessWidget {
  final Workout _workout;
  WorkoutWidget(this._workout);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(DateFormat("EEEE, MMMM d").format(_workout.date))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _workout.entries.length,
        itemBuilder: (context, i) => _buildEntry(_workout.entries[i]),
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
