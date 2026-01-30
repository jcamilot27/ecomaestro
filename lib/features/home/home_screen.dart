import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/element_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final elements = ElementConfig.allElements;

    return Scaffold(
      body: Stack(
        children: [
          // Background representing all elements
          const _ElementalBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'CAMINO HACIA LA MAESTRÍA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      fontSize: 16,
                    ),
                  ),
                  background: const SizedBox.shrink(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _ElementCard(
                      config: elements[index],
                      delay: (index * 150).ms,
                    );
                  }, childCount: elements.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),
                      Text(
                        'Domina cada elemento para alcanzar la perfección en el idioma.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ElementalBackground extends StatelessWidget {
  const _ElementalBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F), Colors.black],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _BlurCircle(
              color: const Color(0xFF00B0FF).withValues(alpha: 0.05),
              size: 300,
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: _BlurCircle(
              color: const Color(0xFFFF5252).withValues(alpha: 0.05),
              size: 300,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _BlurCircle(
              color: const Color(0xFF8D6E63).withValues(alpha: 0.05),
              size: 300,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _BlurCircle(
              color: const Color(0xFFB3E5FC).withValues(alpha: 0.05),
              size: 300,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.5, 1.5),
          duration: 10.seconds,
          curve: Curves.easeInOut,
        );
  }
}

class _ElementCard extends StatelessWidget {
  final ElementConfig config;
  final Duration delay;

  const _ElementCard({required this.config, required this.delay});

  @override
  Widget build(BuildContext context) {
    return InkWell(
          onTap: () {
            if (config.element == AppLearningElement.water) {
              context.push(config.route);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'El elemento ${config.name} estará disponible pronto.',
                  ),
                  backgroundColor: config.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  config.primaryColor.withValues(alpha: 0.2),
                  config.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: config.primaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: config.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      config.icon,
                      size: 100,
                      color: config.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: config.primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            config.icon,
                            color: config.primaryColor,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          config.name.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: config.primaryColor,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config.topic,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          config.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        )
        .shimmer(
          delay: 2.seconds,
          duration: 2.seconds,
          color: config.primaryColor.withValues(alpha: 0.2),
        );
  }
}
