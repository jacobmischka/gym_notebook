import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'exercise.dart';
import 'workout.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'gym-notebook',
    options: const FirebaseOptions(
      googleAppID: '',
      apiKey: '',
      databaseURL: '',
    ),
  );
  runApp(new MaterialApp(
    title: 'Gym Notebook',
    theme: ThemeData(
      primarySwatch: Colors.orange,
    ),
    home: HomeWidget(app: app),
  ));
}

class HomeWidget extends StatefulWidget {
  final FirebaseApp app;
  HomeWidget({this.app});

  final List<Workout> _workouts = <Workout>[];

  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  DatabaseReference _workoutsRef;
  StreamSubscription<Event> _workoutsSubscription;

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(1000000000);
    _workoutsRef = database.reference().child('workouts');
    _workoutsSubscription = _workoutsRef.onChildAdded.listen((Event event) {
      print('Workout added: ${event.snapshot.value}');
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget._workouts.length,
        itemBuilder: (context, i) => _buildWorkout(widget._workouts[i]),
      ),
    );
  }

  Widget _buildWorkout(Workout workout) {
    return ListTile(
        title: Text(DateFormat("EEEE, MMMM d").format(workout.date)));
  }
}
