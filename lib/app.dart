import 'package:ember/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ember extends StatefulWidget {
  const Ember({super.key});

  @override
  State<Ember> createState() => _WorkoutAppState();
}

class _WorkoutAppState extends State<Ember> {
  @override
  void initState() {
    super.initState();
    _testSignUp();
  }

  Future<void> _testSignUp() async {
    final repo = AuthRepository(Supabase.instance.client);
    final response = await repo.signUp(
      email: 'sampleemail@email.com',
      password: 'password123',
    );
    print(response.user?.id); // Should print a UUID
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}