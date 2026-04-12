enum FitnessLevel {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
    }
  }

  String get value {
    switch (this) {
      case FitnessLevel.beginner:
        return 'beginner';
      case FitnessLevel.intermediate:
        return 'intermediate';
      case FitnessLevel.advanced:
        return 'advanced';
    }
  }

  static FitnessLevel fromValue(String value) {
    return FitnessLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FitnessLevel.beginner,
    );
  }
}

enum PrimaryGoal {
  buildMuscle,
  loseFat,
  gainStrength,
  improveEndurance,
  generalFitness,
  stayActive;

  String get label {
    switch (this) {
      case PrimaryGoal.buildMuscle:
        return 'Build Muscle';
      case PrimaryGoal.loseFat:
        return 'Lose Fat';
      case PrimaryGoal.gainStrength:
        return 'Gain Strength';
      case PrimaryGoal.improveEndurance:
        return 'Improve Endurance';
      case PrimaryGoal.generalFitness:
        return 'General Fitness';
      case PrimaryGoal.stayActive:
        return 'Stay Active';
    }
  }

  String get value {
    switch (this) {
      case PrimaryGoal.buildMuscle:
        return 'buildMuscle';
      case PrimaryGoal.loseFat:
        return 'loseFat';
      case PrimaryGoal.gainStrength:
        return 'gainStrength';
      case PrimaryGoal.improveEndurance:
        return 'improveEndurance';
      case PrimaryGoal.generalFitness:
        return 'generalFitness';
      case PrimaryGoal.stayActive:
        return 'stayActive';
    }
  }

  static PrimaryGoal fromValue(String value) {
    return PrimaryGoal.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PrimaryGoal.generalFitness,
    );
  }
}

enum UnitSystem {
  lbsMi,
  kgKm;

  String get label {
    switch (this) {
      case UnitSystem.lbsMi:
        return 'lbs / mi';
      case UnitSystem.kgKm:
        return 'kg / km';
    }
  }

  String get value {
    switch (this) {
      case UnitSystem.lbsMi:
        return 'lbs_mi';
      case UnitSystem.kgKm:
        return 'kg_km';
    }
  }

  static UnitSystem fromValue(String value) {
    return UnitSystem.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UnitSystem.lbsMi,
    );
  }
}

enum ThemePreference {
  system,
  light,
  dark;

  String get label {
    switch (this) {
      case ThemePreference.system:
        return 'System';
      case ThemePreference.light:
        return 'Light';
      case ThemePreference.dark:
        return 'Dark';
    }
  }

  String get value {
    switch (this) {
      case ThemePreference.system:
        return 'system';
      case ThemePreference.light:
        return 'light';
      case ThemePreference.dark:
        return 'dark';
    }
  }

  static ThemePreference fromValue(String value) {
    return ThemePreference.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ThemePreference.system,
    );
  }
}

class UserProfile {
  final String id;
  final String? username;
  final String avatarId;
  final String? bio;
  final FitnessLevel fitnessLevel;
  final int streakCount;
  final int totalWorkoutsCompleted;
  final int emberXp;
  final PrimaryGoal primaryGoal;
  final UnitSystem unitSystem;
  final int defaultRestTimerSeconds;
  final ThemePreference theme;
  final bool notificationsEnabled;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.avatarId,
    required this.bio,
    required this.fitnessLevel,
    required this.streakCount,
    required this.totalWorkoutsCompleted,
    required this.emberXp,
    required this.primaryGoal,
    required this.unitSystem,
    required this.defaultRestTimerSeconds,
    required this.theme,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String?,
      avatarId: (map['avatar_id'] as String?) ?? '1',
      bio: map['bio'] as String?,
      fitnessLevel: FitnessLevel.fromValue(
        (map['fitness_level'] as String?) ?? 'beginner',
      ),
      streakCount: (map['streak_count'] as int?) ?? 0,
      totalWorkoutsCompleted: (map['total_workouts_completed'] as int?) ?? 0,
      emberXp: (map['ember_xp'] as int?) ?? 0,
      primaryGoal: PrimaryGoal.fromValue(
        (map['primary_goal'] as String?) ?? 'generalFitness',
      ),
      unitSystem: UnitSystem.fromValue(
        (map['unit_system'] as String?) ?? 'lbs_mi',
      ),
      defaultRestTimerSeconds:
          (map['default_rest_timer_seconds'] as int?) ?? 60,
      theme: ThemePreference.fromValue(
        (map['theme'] as String?) ?? 'system',
      ),
      notificationsEnabled: (map['notifications_enabled'] as bool?) ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime(2025, 1, 1),
    );
  }

  UserProfile copyWith({
    String? username,
    String? avatarId,
    String? bio,
    FitnessLevel? fitnessLevel,
    PrimaryGoal? primaryGoal,
    UnitSystem? unitSystem,
    int? defaultRestTimerSeconds,
    ThemePreference? theme,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      bio: bio ?? this.bio,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      streakCount: streakCount,
      totalWorkoutsCompleted: totalWorkoutsCompleted,
      emberXp: emberXp,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      unitSystem: unitSystem ?? this.unitSystem,
      defaultRestTimerSeconds:
          defaultRestTimerSeconds ?? this.defaultRestTimerSeconds,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
    );
  }
}