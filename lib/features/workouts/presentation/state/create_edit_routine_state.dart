import 'package:ember/features/workouts/data/workout_models.dart';

class CreateEditRoutineState {
  final String title;
  final String description;
  final List<RoutineExercise> exercises;
  final bool isSaving;

  const CreateEditRoutineState({
    this.title = '',
    this.description = '',
    this.exercises = const [],
    this.isSaving = false,
  });

  CreateEditRoutineState copyWith({
    String? title,
    String? description,
    List<RoutineExercise>? exercises,
    bool? isSaving,
  }) {
    return CreateEditRoutineState(
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  bool get isValid => title.trim().isNotEmpty && exercises.isNotEmpty;
}
