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

  ExerciseWeight(this.weight, [this.units = WeightUnit.kg]);
}

enum WeightUnit { lbs, kg }

class ExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  ExerciseWidget(this.exercise);

  @override
  ExerciseWidgetState createState() => new ExerciseWidgetState(exercise);
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  final TextEditingController _nameController;

  ExerciseWidgetState(Exercise exercise)
      : _nameController = TextEditingController(text: exercise.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Exercise name',
                hintText: 'Bench press',
              ),
              controller: _nameController,
            ),
          ),
        ],
      ),
    );
  }
}
