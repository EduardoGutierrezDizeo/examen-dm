import 'package:cuenta/helpers/api_exception.dart';
import 'package:cuenta/model/admin/videojuego_model.dart';
import 'package:cuenta/presentation/shared/error_retry_widget.dart';
import 'package:cuenta/services/admin/videojuegos/videojuegos_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({super.key});

  @override
  State<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  bool loading = true;
  String? error;
  List<VideojuegoModel> videojuegos = [];

  @override
  void initState() {
    super.initState();
    getVideojuegos();
  }

  Future<void> getVideojuegos() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await VideojuegosService.getVideojuegos();

      if (!mounted) return;

      setState(() {
        videojuegos = response;
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

  void sendToDetail(String id) {
    context.push('/admin/videojuegos/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (loading) {
      final placeholder = VideojuegoModel.fromJson(const {
        'nombre': 'Nombre del videojuego',
        'genero': 'Género',
        'calificacion': 'Calificación',
      });

      return Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        child: _videojuegosList(
          List<VideojuegoModel>.filled(8, placeholder),
        ),
      );
    }

    if (error != null) {
      return ErrorRetryWidget(message: error!, onRetry: getVideojuegos);
    }

    if (videojuegos.isEmpty) {
      return const Center(child: Text('No hay videojuegos disponibles'));
    }

    return _videojuegosList(videojuegos);
  }

  Widget _videojuegosList(List<VideojuegoModel> videojuegos) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: videojuegos.length,
      separatorBuilder: (_, __) {
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        return _videojuegoTile(videojuegos[index]);
      },
    );
  }

  Widget _videojuegoTile(VideojuegoModel videojuego) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => sendToDetail(videojuego.id.toString()),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImageCustom(src: videojuego.imagen),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      videojuego.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Género: ${videojuego.genero}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Calificación: ${videojuego.calificacion}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Center(
                child: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageCustom extends StatelessWidget {
  final String src;

  const ImageCustom({super.key, required this.src});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 110,
        child: src.isEmpty
            ? Container(
                color: placeholderColor,
                child: const Icon(Icons.image_not_supported, size: 35),
              )
            : Image.network(
                src,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: placeholderColor,
                    child: const Icon(Icons.image_not_supported, size: 35),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return Container(
                    color: placeholderColor,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
