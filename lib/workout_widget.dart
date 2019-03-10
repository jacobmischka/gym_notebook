import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise.dart';
import 'exercise_picker.dart';
import 'workout.dart';
import 'workout_entry_widget.dart';

import 'utils.dart';
import 'decorations.dart';

class WorkoutWidget extends StatefulWidget {
  final Workout workout;

  WorkoutWidget(this.workout);

  @override
  WorkoutWidgetState createState() => WorkoutWidgetState(workout);
}

class WorkoutWidgetState extends State<WorkoutWidget> {
  final _formKey = GlobalKey<FormState>();
  Workout _workout;

  WorkoutWidgetState(workout) {
    _workout = workout;
  }

  @override
  void initState() {
    super.initState();

    _workout.fetchEntries().then((_x) {
      setState(() {});
    });
  }

  Widget _buildEntry(WorkoutEntry workoutEntry) {
    return ListTile(
        key: Key(workoutEntry.id),
        title: workoutEntry.exerciseName(),
        subtitle: Text(workoutEntry.sets
            .map((set) =>
                '${nf.format(set.weight.weight)}x${nf.format(set.reps)}')
            .join(', ')),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkoutEntryWidget(workoutEntry)));
        },
        trailing: IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete entry',
            onPressed: () async {
              var future = _workout.removeEntry(workoutEntry);
              setState(() {});
              await future;
              setState(() {});
            }));
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    await _workout.reorderEntry(oldIndex, newIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat("EEEE, MMMM d").format(_workout.date)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete workout',
              onPressed: _handleDelete)
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: _handleSave,
        child: Column(
          children: <Widget>[
            Flexible(
              child: Container(
                color: Colors.grey[200],
                child: ReorderableListView(
                    padding: const EdgeInsets.all(16.0),
                    onReorder: _handleReorder,
                    children:
                        _workout.entries.map<Widget>(_buildEntry).toList()),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Colors.grey[300], blurRadius: 24.0)
                    ],
                    border: Border(top: BorderSide(width: 1.0))),
                child: Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(flex: 2),
                      Flexible(
                        flex: 3,
                        child: FlatButton(
                            child: Text(_workout.startTime == null
                                ? 'Start time'
                                : _workout.startTime.format(context)),
                            onPressed: () async {
                              var startTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      _workout.startTime ?? TimeOfDay.now());

                              if (startTime != null) {
                                _workout.startTime = startTime;
                                _workout.save();
                                setState(() {});
                              }
                            }),
                      ),
                      Spacer(flex: 1),
                      const Text('–'),
                      Spacer(flex: 1),
                      Flexible(
                        flex: 3,
                        child: FlatButton(
                            child: Text(_workout.endTime == null
                                ? 'End time'
                                : _workout.endTime.format(context)),
                            onPressed: () async {
                              var endTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      _workout.endTime ?? TimeOfDay.now());
                              if (endTime != null) {
                                _workout.endTime = endTime;
                                _workout.save();
                                setState(() {});
                              }
                            }),
                      ),
                      Spacer(flex: 2),
                    ],
                  ),
                  TextFormField(
                    initialValue: _workout.notes,
                    maxLines: 3,
                    decoration: notesDecoration,
                    onSaved: (String value) {
                      _workout.notes = value;
                    },
                  )
                ])),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _addEntry(context);
          },
          tooltip: 'Add entry',
          child: Icon(Icons.add)),
    );
  }

  Future<void> _handleSave() async {
    var form = _formKey.currentState;
    form.save();
    await _workout.save();
    setState(() {});
  }

  Future<void> _handleDelete() async {
    bool confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Delete workout?'),
              actions: <Widget>[
                FlatButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                FlatButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    })
              ]);
        });
    if (confirmed) {
      await _workout.delete();
      Navigator.pop(context);
    }
  }

  Future<void> _addEntry(context) async {
    Exercise exercise = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExercisePickerWidget(_workout.user)));

    if (exercise != null) {
      await _workout.addEntry(exercise);
      setState(() {});
    }
  }
}
