import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout.dart';
import 'workout_widget.dart';

import 'utils.dart';

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

  final FirebaseAuth auth = FirebaseAuth.fromApp(app);

  final Firestore firestore = Firestore(app: app);
  await firestore.settings(
      persistenceEnabled: true, timestampsInSnapshotsEnabled: true);
  runApp(new MaterialApp(
    title: 'Gym Notebook',
    theme: ThemeData(
      primarySwatch: Colors.orange,
    ),
    home: AppWidget(app, auth, firestore),
  ));
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(value: null));
  }
}

class AppWidget extends StatefulWidget {
  final FirebaseApp app;
  final FirebaseAuth auth;
  final Firestore firestore;

  AppWidget(this.app, this.auth, this.firestore);

  @override
  AppWidgetState createState() => AppWidgetState(auth.currentUser());
}

class AppWidgetState extends State<AppWidget> {
  FirebaseUser user;
  bool loading = true;

  AppWidgetState(Future<FirebaseUser> currentUser) {
    currentUser.then((FirebaseUser currentUser) {
      setState(() {
        user = currentUser;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingWidget();
    }

    if (user != null) {
      return HomeWidget(user: user, firestore: widget.firestore);
    }

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
            child: RaisedButton(
                child: Text('Sign in with Google'),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });

                  try {
                    user = await _handleGoogleSignin();

                    DocumentReference userRef =
                        widget.firestore.document('/users/${user.uid}');
                    await userRef.setData(<String, dynamic>{
                      'name': user.displayName,
                      'email': user.email,
                    }, merge: true);
                  } catch (e) {
                    debugger();
                    print(e);
                  } finally {
                    setState(() {
                      loading = false;
                    });
                  }
                }))
      ],
    ));
  }

  Future<FirebaseUser> _handleGoogleSignin() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser user = await widget.auth.signInWithCredential(credential);

    return user;
  }
}

class HomeWidget extends StatelessWidget {
  final FirebaseUser user;
  final Firestore firestore;

  HomeWidget({this.user, this.firestore});

  CollectionReference get workouts => firestore.collection('workouts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Workouts'),
        ),
        body: WorkoutList(workouts.where('user', isEqualTo: user.uid)),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            DateTime date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                lastDate: DateTime.utc(3000));

            if (date != null) {
              await Workout.create(user.uid, date);
            }
          },
          tooltip: 'Add workout',
          child: Icon(Icons.add),
        ));
  }
}

class WorkoutList extends StatelessWidget {
  final Query workoutsQuery;
  WorkoutList(this.workoutsQuery);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: workoutsQuery.snapshots(),
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
