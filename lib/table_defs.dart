import 'dart:async';

final String tableExercises = 'excercises';
final String tableExerciseSets = 'exercise_sets';
final String tableWorkoutEntries = 'workout_entries';

final String columnId = '_id';
final String columnName = 'name';
final String columnNotes = 'notes';
final String columnWeight = 'weight';
final String columnUnits = 'units';
final String columnReps = 'reps';
final String columnWorkoutId = 'workout_id';
final String columnExerciseId = 'exercise_id';
final String columnDate = 'date';
final String columnStartTime = 'start_time';
final String columnEndTime = 'end_time';

abstract class GymLogProvider<T> {
  Future open(String path);
  Future<T> insert(T t);
  Future<T> fetch(int id);
  Future<int> delete(int id);
  Future<int> update(T t);
  Future close();
}
