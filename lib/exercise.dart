import 'package:flutter/material.dart';

class Exercise {
  final String name;

  Exercise([this.name = '']);
}

class ExerciseSet {
  final ExerciseWeight weight;
  final int reps;

  ExerciseSet(this.weight, this.reps);
}

class ExerciseWeight {
  final int weight;
  final WeightUnit units;

  ExerciseWeight(this.weight, [this.units = WeightUnit.lbs]);
}

enum WeightUnit { lbs, kg }

class ExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  ExerciseWidget(this.exercise);

  @override
  ExerciseWidgetState createState() => ExerciseWidgetState();
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              child: TextFormField(
                initialValue: widget.exercise.name,
                decoration: InputDecoration(
                  labelText: 'Exercise name',
                  hintText: 'Bench press',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
