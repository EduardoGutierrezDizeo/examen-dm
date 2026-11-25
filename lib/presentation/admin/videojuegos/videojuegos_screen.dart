import 'package:cuenta/presentation/admin/videojuegos/consult_screen.dart';
import 'package:flutter/material.dart';

class VideojuegosScreen extends StatelessWidget {
  const VideojuegosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: ConsultScreen());
  }
}
