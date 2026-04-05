import 'dart:math';

class SplashData {
  SplashData._();

  static const List<String> _taglines = [
    'Ignite your potential.',
    'Every rep counts.',
    'Strength starts here.',
    'Show up. Lift. Repeat.',
    'Your best set is next.',
    'Built one session at a time.',
    'No excuses. Just results.',
    'Train with purpose.',
  ];

  static final _random = Random();

  static String randomTagline() =>
      _taglines[_random.nextInt(_taglines.length)];
}