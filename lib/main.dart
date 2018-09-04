import 'package:flutter/material.dart';

import 'exercise.dart';
import 'workout.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gym Notebook',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: WorkoutWidget(
        Workout(
          DateTime.utc(2018, 9, 1),
          <WorkoutEntry>[
            WorkoutEntry(
              Exercise('Bench'),
              <ExerciseSet>[
                ExerciseSet(ExerciseWeight(0), 10),
                ExerciseSet(ExerciseWeight(5), 10),
                ExerciseSet(ExerciseWeight(10), 10),
                ExerciseSet(ExerciseWeight(15), 10),
              ],
            ),
            WorkoutEntry(
              Exercise('Squat'),
              <ExerciseSet>[
                ExerciseSet(ExerciseWeight(200), 4),
                ExerciseSet(ExerciseWeight(200), 4),
                ExerciseSet(ExerciseWeight(200), 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
