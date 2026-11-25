import 'package:flutter/material.dart';

class SliderImage {
  final String url;
  final String label;
  final String subtitle;

  const SliderImage({
    required this.url,
    required this.label,
    this.subtitle = '',
  });
}

class ImageSlider extends StatefulWidget {
  final List<SliderImage> items;
  final double height;

  const ImageSlider({super.key, required this.items, this.height = 320});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasMany = items.length > 1;
    final current = _currentPage.clamp(0, items.length - 1);
    final item = items[current];

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: _SliderPicture(url: items[index].url),
                    ),
                  );
                },
              ),
              if (hasMany)
                Positioned(
                  left: 4,
                  child: IconButton.filledTonal(
                    tooltip: 'Anterior',
                    onPressed: current > 0 ? () => _goTo(current - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                ),
              if (hasMany)
                Positioned(
                  right: 4,
                  child: IconButton.filledTonal(
                    tooltip: 'Siguiente',
                    onPressed: current < items.length - 1
                        ? () => _goTo(current + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (item.subtitle.isNotEmpty)
          Text(
            item.subtitle.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        if (hasMany) ...[
          const SizedBox(height: 4),
          Text(
            '${current + 1} / ${items.length}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 6,
            children: List.generate(items.length, (index) {
              final active = index == current;

              return GestureDetector(
                onTap: () => _goTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _SliderPicture extends StatelessWidget {
  final String url;

  const _SliderPicture({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

    return Image.network(
      url,
      fit: BoxFit.contain,
      width: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return const Center(child: Icon(Icons.image_not_supported, size: 48));
  }
}
