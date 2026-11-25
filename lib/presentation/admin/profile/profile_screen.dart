import 'package:cuenta/helpers/api_exception.dart';
import 'package:cuenta/model/usuario_model.dart';
import 'package:cuenta/presentation/shared/error_retry_widget.dart';
import 'package:cuenta/services/admin/profile/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  String? error;
  UsuarioModel? profile;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await ProfileService().getProfile();

      if (!mounted) return;

      setState(() {
        profile = response;
        loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.message;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'Ocurrió un error inesperado.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Skeletonizer(
            enabled: true,
            enableSwitchAnimation: true,
            child: _content(_placeholder()),
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: ErrorRetryWidget(message: error!, onRetry: getProfile),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _content(profile ?? _placeholder()),
      ),
    );
  }

  UsuarioModel _placeholder() {
    return UsuarioModel.fromJson(const {
      'id': 0,
      'username': 'usuario',
      'email': 'usuario@correo.com',
      'nombre': 'Nombre',
      'apellido': 'Apellido',
      'telefono': '000-000-0000',
      'ciudad': 'Ciudad',
    });
  }

  Widget _content(UsuarioModel profile) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.person,
              size: 70,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '@${profile.username}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _item(
                context: context,
                icon: Icons.person,
                label: 'Usuario',
                value: profile.username,
              ),
              const Divider(),
              _item(
                context: context,
                icon: Icons.badge,
                label: 'Nombre completo',
                value: profile.fullName,
              ),
              const Divider(),
              _item(
                context: context,
                icon: Icons.email,
                label: 'Correo electrónico',
                value: profile.email,
              ),
              const Divider(),
              _item(
                context: context,
                icon: Icons.phone,
                label: 'Teléfono',
                value: profile.telefono,
              ),
              const Divider(),
              _item(
                context: context,
                icon: Icons.location_city,
                label: 'Ciudad',
                value: profile.ciudad,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: colorScheme.primary, size: 26),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
