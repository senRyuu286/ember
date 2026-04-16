class ExerciseFilters {
  final String? muscle;
  final String? equipment;
  final bool stretchesOnly;

  const ExerciseFilters({
    this.muscle,
    this.equipment,
    this.stretchesOnly = false,
  });

  ExerciseFilters copyWith({
    String? muscle,
    String? equipment,
    bool? stretchesOnly,
    bool clearMuscle = false,
    bool clearEquipment = false,
  }) {
    return ExerciseFilters(
      muscle: clearMuscle ? null : (muscle ?? this.muscle),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      stretchesOnly: stretchesOnly ?? this.stretchesOnly,
    );
  }

  bool get hasActiveFilters =>
      muscle != null || equipment != null || stretchesOnly;

  int get activeCount {
    int count = 0;
    if (muscle != null) count++;
    if (equipment != null) count++;
    if (stretchesOnly) count++;
    return count;
  }
}
