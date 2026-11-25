import 'package:cuenta/config/router/router_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerRoutes = routerConfigAdmin
        .where((res) => res.inDrawer)
        .toList();
    final currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.last.matchedLocation;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _member(
                  context,
                  code: '0192127',
                  name: 'Julian Pedraza',
                  email: 'jcpedrazav@ufpso.edu.co',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _member(
                  context,
                  code: '0212278',
                  name: 'Eduardo Gutierrez',
                  email: 'ejgutierrezdepd@ufpso.edu.co',
                ),
              ],
            ),
          ),
          ...drawerRoutes.where((res) => res.inDrawer).map((res) {
            final isSelected = currentLocation == res.patch;

            return ListTile(
              selected: isSelected,
              selectedTileColor: Colors.grey[300],
              title: Text(res.name),
              leading: Icon(res.icon),
              onTap: () {
                Navigator.pop(context);
                if (!isSelected) {
                  context.go(res.patch);
                }
              },
            );
          }),
          const Spacer(),
          ListTile(
            title: const Text('Cerrar Sesión'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              Navigator.pop(context);
              const FlutterSecureStorage flutterSecureStorage =
                  FlutterSecureStorage();
              await flutterSecureStorage.delete(key: 'token');
              if (!context.mounted) return;
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _member(
    BuildContext context, {
    required String code,
    required String name,
    required String email,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Text(name.substring(0, 1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$code - $name',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(email, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
