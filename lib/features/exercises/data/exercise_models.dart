import 'dart:convert';

enum ExerciseCategory {
  strength,
  stretch,
  cardio,
  mobility;

  String get label {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.stretch:
        return 'Stretch';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.mobility:
        return 'Mobility';
    }
  }

  static ExerciseCategory fromValue(String value) {
    return ExerciseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExerciseCategory.strength,
    );
  }
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }

  static ExerciseDifficulty? fromValue(String? value) {
    if (value == null) return null;
    return ExerciseDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExerciseDifficulty.beginner,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final ExerciseDifficulty? difficulty;
  final List<String> muscleGroups;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final String instructions;
  final String? breathingCues;
  final List<String> dos;
  final List<String> donts;
  final int xpReward;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.muscleGroups,
    required this.secondaryMuscles,
    required this.equipment,
    required this.instructions,
    required this.breathingCues,
    required this.dos,
    required this.donts,
    required this.xpReward,
  });

  /// Asset slug for the exercise image.
  /// e.g. "Barbell Squat" → "assets/exercises/barbell_squat.png"
  String get imageAssetPath {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    return 'assets/exercises/$slug.png';
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    List<String> parseArray(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.cast<String>();
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded.cast<String>();
        } catch (_) {}
        return [];
      }
      return [];
    }

    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ExerciseCategory.fromValue(
        (map['category'] as String?) ?? 'strength',
      ),
      difficulty: ExerciseDifficulty.fromValue(map['difficulty'] as String?),
      muscleGroups: parseArray(map['muscle_groups']),
      secondaryMuscles: parseArray(map['secondary_muscles']),
      equipment: parseArray(map['equipment']),
      instructions: (map['instructions'] as String?) ?? '',
      breathingCues: map['breathing_cues'] as String?,
      dos: parseArray(map['dos']),
      donts: parseArray(map['donts']),
      xpReward: (map['xp_reward'] as int?) ?? 0,
    );
  }
}

/// Maps muscle group names to SVG path IDs on the front/back diagram.
/// Each muscle group can highlight multiple SVG regions.
class MuscleHighlightMap {
  static const Map<String, List<String>> frontIds = {
    'Chest': ['pec_major_left', 'pec_major_right'],
    'Front Deltoids': ['front_delt_left', 'front_delt_right'],
    'Shoulders': ['front_delt_left', 'front_delt_right'],
    'Biceps': ['bicep_left', 'bicep_right'],
    'Triceps': ['tricep_left', 'tricep_right'],
    'Forearms': ['forearm_front_left', 'forearm_front_right'],
    'Abs': ['abs_upper', 'abs_mid', 'abs_lower'],
    'Core': ['abs_upper', 'abs_mid', 'abs_lower', 'oblique_left', 'oblique_right'],
    'Obliques': ['oblique_left', 'oblique_right'],
    'Quads': ['quad_left', 'quad_right'],
    'Quadriceps': ['quad_left', 'quad_right'],
    'Hip Flexors': ['hip_flexor_left', 'hip_flexor_right'],
    'Adductors': ['adductor_left', 'adductor_right'],
    'Calves': ['calf_left', 'calf_right'],
    'Tibialis': ['tibialis_left', 'tibialis_right'],
    'Neck': ['neck_front'],
    'Traps': ['trapezius_left', 'trapezius_right'],
    'Trapezius': ['trapezius_left', 'trapezius_right'],
  };

  static const Map<String, List<String>> backIds = {
    'Traps': ['trap_upper_left', 'trap_upper_right', 'trap_mid_left', 'trap_mid_right'],
    'Trapezius': ['trap_upper_left', 'trap_upper_right', 'trap_mid_left', 'trap_mid_right'],
    'Rear Deltoids': ['rear_delt_left', 'rear_delt_right'],
    'Shoulders': ['rear_delt_left', 'rear_delt_right'],
    'Triceps': ['tricep_left', 'tricep_right'],
    'Lats': ['lat_left'],
    'Latissimus Dorsi': ['lat_left'],
    'Lower Back': ['lower_back_left', 'lower_back_right'],
    'Glutes': ['glute_max_left', 'glute_max_right', 'glute_med_left', 'glute_med_right'],
    'Hamstrings': ['hamstring_left', 'hamstring_right'],
    'Calves': ['calf_left', 'calf_right'],
    'Forearms': ['forearm_back_left', 'forearm_back_right'],
    'Adductors': ['adductor_left', 'adductor_right'],
    'Rhomboids': ['trap_mid_left', 'trap_mid_right'],
    'Back': ['lat_left', 'lower_back_left', 'lower_back_right', 'trap_mid_left', 'trap_mid_right'],
  };

  static List<String> getFrontIds(List<String> muscles) {
    final ids = <String>{};
    for (final muscle in muscles) {
      ids.addAll(frontIds[muscle] ?? []);
    }
    return ids.toList();
  }

  static List<String> getBackIds(List<String> muscles) {
    final ids = <String>{};
    for (final muscle in muscles) {
      ids.addAll(backIds[muscle] ?? []);
    }
    return ids.toList();
  }
}