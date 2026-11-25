import 'package:cuenta/config/router/router_model.dart';
import 'package:cuenta/presentation/admin/profile/profile_screen.dart';
import 'package:cuenta/presentation/admin/screen_admin.dart';
import 'package:cuenta/presentation/admin/videojuegos/detail_screen.dart';
import 'package:flutter/material.dart';

final routerConfigAdmin = <RouterModel>[
  RouterModel(
    name: 'Videojuegos',
    screen: (context, state) => const VideojuegosScreen(),
    title: 'Videojuegos',
    patch: '/admin/videojuegos',
    icon: Icons.sports_esports,
    description: '',
  ),
  RouterModel(
    name: 'Detalle del videojuego',
    screen: (context, state) =>
        DetailScreen(id: state.pathParameters['id'] ?? ''),
    title: 'Videojuego',
    patch: '/admin/videojuegos/:id',
    icon: Icons.sports_esports,
    description: '',
    inDrawer: false,
  ),
  RouterModel(
    name: 'Perfil',
    screen: (context, state) => ProfileScreen(),
    title: 'Perfil',
    patch: '/admin/profile',
    icon: Icons.person,
    description: '',
  ),
];
