import 'package:cuenta/helpers/api_exception.dart';
import 'package:cuenta/model/admin/videojuego_model.dart';
import 'package:cuenta/presentation/shared/error_retry_widget.dart';
import 'package:cuenta/presentation/shared/images/images_widget.dart';
import 'package:cuenta/services/admin/videojuegos/videojuegos_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool loading = true;
  String? error;
  VideojuegoModel? data;

  @override
  void initState() {
    super.initState();
    getDetail();
  }

  Future<void> getDetail() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await VideojuegosService.getDetail(widget.id);

      if (!mounted) return;

      setState(() {
        data = response;
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
    return Scaffold(body: SafeArea(child: _buildBody()));
  }

  Widget _buildBody() {
    if (loading) {
      return Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        child: _content(_placeholder()),
      );
    }

    if (error != null) {
      return ErrorRetryWidget(message: error!, onRetry: getDetail);
    }

    return _content(data ?? _placeholder());
  }

  VideojuegoModel _placeholder() {
    return VideojuegoModel.fromJson(const {
      'nombre': 'Nombre del videojuego',
      'calificacion': 'Calificación',
      'precio': 'Precio',
      'genero': 'Género',
      'plataforma': 'Plataforma',
      'descripcion': 'Descripción del videojuego.',
      'desarrolladora': 'Desarrolladora',
      'pais_origen': 'País de origen',
      'dlcs': [
        {'nombre': 'DLC', 'imagen': ''},
      ],
    });
  }

  Widget _content(VideojuegoModel videojuego) {
    final theme = Theme.of(context);

    final sliderItems = <SliderImage>[
      SliderImage(
        url: videojuego.imagen,
        label: videojuego.nombre,
        subtitle: 'Videojuego',
      ),
      ...videojuego.dlcs.map(
        (dlc) => SliderImage(
          url: dlc.imagen,
          label: dlc.nombre,
          subtitle: 'DLC',
        ),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageSlider(key: ValueKey(videojuego.id), items: sliderItems),
          const SizedBox(height: 16),
          Text(
            videojuego.nombre,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (videojuego.genero.isNotEmpty) _chip(videojuego.genero),
              if (videojuego.plataforma.isNotEmpty)
                _chip(videojuego.plataforma),
              if (videojuego.calificacion.isNotEmpty)
                _chip('Calificación: ${videojuego.calificacion}'),
              if (videojuego.precio.isNotEmpty)
                _chip('Precio: ${videojuego.precio} USD'),
              if (videojuego.desarrolladora.isNotEmpty)
                _chip(videojuego.desarrolladora),
            ],
          ),
          const SizedBox(height: 16),
          Text(videojuego.descripcion, textAlign: TextAlign.justify),
          const SizedBox(height: 20),
          Text(
            'País de origen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(videojuego.paisOrigen),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(label: Text(label));
  }
}
