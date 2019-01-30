import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout.dart';
import 'workout_widget.dart';

import 'utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'gym-notebook',
    options: const FirebaseOptions(
        googleAppID: '1:543633183977:android:2d6be5981c34378b',
        gcmSenderID: '543633183977',
        apiKey: 'AIzaSyBeA_LxpKMKITkPwbTEE7dyS7uctcN4p60',
        projectID: 'gym-notebook'),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  final FirebaseUser user = await _auth.signInAnonymously();

  runApp(new MaterialApp(
    title: 'Gym Notebook',
    theme: ThemeData(
      primarySwatch: Colors.orange,
    ),
    home: HomeWidget(app: app, user: user, firestore: firestore),
  ));
}

Future<FirebaseUser> handleGoogleSignin() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return user;
}

class HomeWidget extends StatelessWidget {
  final FirebaseApp app;
  final FirebaseUser user;
  final Firestore firestore;

  HomeWidget({this.app, this.user, this.firestore});

  CollectionReference get workouts => firestore.collection('workouts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Workouts'),
        ),
        body: WorkoutList(workouts),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            DateTime date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                lastDate: DateTime.utc(3000));
            await Workout.create(date);
          },
          tooltip: 'Add workout',
          child: Icon(Icons.add),
        ));
  }
}

class WorkoutList extends StatelessWidget {
  final CollectionReference workouts;
  WorkoutList(this.workouts);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: workouts.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

          snapshot.data.documents
              .sort((a, b) => b['date'].compareTo(a['date']));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, i) =>
                _buildWorkout(context, snapshot.data.documents[i]),
          );
        });
  }

  Widget _buildWorkout(BuildContext context, DocumentSnapshot snapshot) {
    Widget subtitle;
    if (snapshot['startTime'] != null || snapshot['endTime'] != null) {
      String startTime = snapshot['startTime'] != null
          ? timeFormat.format(snapshot['startTime'].toDate())
          : '??';
      String endTime = snapshot['endTime'] != null
          ? timeFormat.format(snapshot['endTime'].toDate())
          : '??';
      subtitle = Text('$startTime – $endTime');
    }
    return ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(dateFormat.format(snapshot['date']?.toDate())),
        subtitle: subtitle,
        onTap: () {
          Workout workout = Workout.fromSnapshot(snapshot);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WorkoutWidget(workout)));
        });
  }
}
