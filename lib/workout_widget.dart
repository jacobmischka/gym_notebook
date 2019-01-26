import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise.dart';
import 'exercise_picker.dart';
import 'workout.dart';
import 'workout_entry_widget.dart';

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
              child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _workout.entries.length,
                  itemBuilder: (context, i) {
                    WorkoutEntry workoutEntry = _workout.entries[i];
                    return ListTile(
                        title: workoutEntry.exerciseName(),
                        subtitle: Text(workoutEntry.sets
                            .map((set) => '${set.weight.weight}x${set.reps}')
                            .join(', ')),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WorkoutEntryWidget(workoutEntry)));
                        },
                        trailing: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () async {
                              await _workout.removeEntry(workoutEntry);
                              setState(() {});
                            }));
                  }),
            ),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _addEntry(context);
                }),
            TextFormField(
              initialValue: _workout.notes,
              decoration: InputDecoration(
                labelText: 'Notes',
              ),
              onSaved: (String value) {
                _workout.notes = value;
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _handleSave,
          tooltip: 'Save entry',
          child: Icon(Icons.save)),
    );
  }

  Future<void> _handleSave() async {
    var form = _formKey.currentState;
    form.save();
    await _workout.save();
    setState(() {});
  }

  Future<void> _addEntry(context) async {
    Exercise exercise = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ExercisePickerWidget()));

    await _workout.addEntry(exercise);

    setState(() {});
  }
}
