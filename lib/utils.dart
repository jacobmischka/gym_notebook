library gym_notebook.utils;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants.dart';
import 'exercise.dart';

DateFormat dateFormat = DateFormat("EEEE, MMMM d");
DateFormat timeFormat = DateFormat.jm();
NumberFormat nf = NumberFormat.compact();

Future<FirebaseApp> getApp() {
  return FirebaseApp.appNamed(APP_NAME);
}

Future<Firestore> getFirestore() async {
  return Firestore(app: await getApp());
}

WeightUnit unitsFromString(String s) {
  return WeightUnit.values.firstWhere((unit) => unit.toString() == s) ??
      WeightUnit.lbs;
}

Future<bool> showDeleteDialog(BuildContext context,
    {String title, String content}) {
  return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(content ??
                'Are you sure you want to delete? This cannot be undone.'),
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
}
