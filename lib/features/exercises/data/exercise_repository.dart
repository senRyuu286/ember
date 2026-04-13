import 'package:supabase_flutter/supabase_flutter.dart';
import 'exercise_models.dart';

class ExerciseRepository {
  final SupabaseClient _client;

  ExerciseRepository(this._client);

  Future<List<Exercise>> getAllExercises() async {
    final response = await _client
        .from('exercises')
        .select(
          'id, name, category, difficulty, muscle_groups, secondary_muscles, '
          'equipment, instructions, breathing_cues, dos, donts, xp_reward',
        )
        .order('name', ascending: true);

    return (response as List)
        .map((row) => Exercise.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }
}