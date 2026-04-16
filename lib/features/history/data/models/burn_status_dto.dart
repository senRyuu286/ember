enum BurnStatusDto { workoutDone, restDay, inactive }

extension BurnStatusDtoX on BurnStatusDto {
  static BurnStatusDto fromRaw(String value) {
    switch (value) {
      case 'workout_done':
        return BurnStatusDto.workoutDone;
      case 'rest_day':
        return BurnStatusDto.restDay;
      default:
        return BurnStatusDto.inactive;
    }
  }

  String get raw {
    switch (this) {
      case BurnStatusDto.workoutDone:
        return 'workout_done';
      case BurnStatusDto.restDay:
        return 'rest_day';
      case BurnStatusDto.inactive:
        return 'inactive';
    }
  }
}
