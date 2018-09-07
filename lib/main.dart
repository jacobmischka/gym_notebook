import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise.dart';
import 'workout.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Gym Notebook',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: HomeWidget());
  }
}

class HomeWidget extends StatefulWidget {
  final List<Workout> _workouts = <Workout>[];

  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget._workouts.length,
      itemBuilder: (context, i) => _buildWorkout(widget._workouts[i]),
    ));
  }

  Widget _buildWorkout(Workout workout) {
    return ListTile(
        title: Text(DateFormat("EEEE, MMMM d").format(workout.date)));
  }
}
