import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/session_entities.dart';
import '../presentation/controllers/session_controller.dart';

final activeSessionProvider =
    NotifierProvider<SessionController, SessionState?>(
  SessionController.new,
);
