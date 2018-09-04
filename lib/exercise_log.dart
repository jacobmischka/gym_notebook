import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise.dart';

class ExerciseLog {
  final Exercise exercise;
  final List<LogEntry> entries;

  ExerciseLog(this.exercise, this.entries);
}

class LogEntry {
  final List<ExerciseSet> sets;
  final DateTime date;

  LogEntry(this.date, this.sets);
}

class ExerciseLogWidget extends StatelessWidget {
  final ExerciseLog _exerciseLog;
  ExerciseLogWidget(this._exerciseLog);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_exerciseLog.exercise.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _exerciseLog.entries.length,
        itemBuilder: (context, i) => _buildEntry(_exerciseLog.entries[i]),
      ),
    );
  }

  Widget _buildEntry(LogEntry logEntry) {
    return ListTile(
        title: Text(DateFormat("EEEE, MMMM d").format(logEntry.date)),
        subtitle: Text(logEntry.sets
            .map((set) => '${set.weight.weight}x${set.reps}')
            .join(', ')));
  }
}
