import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/reading_bloc.dart';

import '../widgets/energy_core.dart';
import '../widgets/modern_mic_button.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReadingBloc>()..add(LoadReadingSession()),
      child: const _ReadingView(),
    );
  }
}

class _ReadingView extends StatefulWidget {
  const _ReadingView();

  @override
  State<_ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends State<_ReadingView> {
  bool _showSummary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'FLUIDEZ ACUÁTICA',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          const _WaterBackground(),
          BlocConsumer<ReadingBloc, ReadingState>(
            listenWhen: (previous, current) =>
                previous.currentIndex != current.currentIndex ||
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == ReadingStatus.initial) {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (context.mounted &&
                      context.read<ReadingBloc>().state.status ==
                          ReadingStatus.initial) {
                    context.read<ReadingBloc>().add(StartListening());
                  }
                });
              }

              if (state.status == ReadingStatus.success) {
                _showBubbleMessage(
                  context,
                  'Energía Verbal: ${(state.fluencyScore * 100).toInt()}%',
                );
              }

              if (state.status == ReadingStatus.sessionCompleted) {
                Future.delayed(const Duration(milliseconds: 1200), () {
                  if (mounted) {
                    setState(() {
                      _showSummary = true;
                    });
                  }
                });
              }

              if (state.status == ReadingStatus.failure &&
                  state.errorMessage != null) {
                _showBubbleMessage(
                  context,
                  'Error: ${state.errorMessage}',
                  isError: true,
                );
              }
            },
            builder: (context, state) {
              if (_showSummary) {
                return _buildSessionSummary(context, state);
              }

              return Stack(
                children: [
                  // Main content centered
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 80,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Energy Core (Centralized Thermometer)
                          SizedBox(
                            height: 350,
                            child: Center(
                              child:
                                  state.status == ReadingStatus.sessionCompleted
                                  ? _buildExplosion(state)
                                  : EnergyCore(
                                      progress:
                                          (state.currentIndex + 1) /
                                          state.totalTexts,
                                      fluencyLevel: state.fluencyScore,
                                      isListening:
                                          state.status ==
                                          ReadingStatus.listening,
                                    ),
                            ),
                          ),

                          // Reading Card with fluid animation
                          Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 48,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00B0FF,
                                      ).withValues(alpha: 0.1),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: _buildHighlightedText(
                                  context,
                                  state.currentText,
                                  state,
                                ),
                              )
                              .animate(key: ValueKey(state.currentText))
                              .fadeIn(duration: 600.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                curve: Curves.easeOutBack,
                              )
                              .custom(
                                duration: 3.seconds,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      4 * math.sin(value * 2 * math.pi),
                                    ),
                                    child: child,
                                  );
                                },
                              )
                              .shimmer(
                                delay: 200.ms,
                                duration: 2.seconds,
                                color: const Color(
                                  0xFF00E5FF,
                                ).withValues(alpha: 0.3),
                              ),

                          // Give some space for the button at the bottom
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Control Area
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: state.status == ReadingStatus.success
                          ? FloatingActionButton.extended(
                              onPressed: () =>
                                  context.read<ReadingBloc>().add(NextText()),
                              label: Text(
                                "SIGUIENTE",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              backgroundColor: const Color(0xFF00B0FF),
                              foregroundColor: Colors.white,
                            ).animate().fadeIn().scale()
                          : ModernMicButton(
                              isListening:
                                  state.status == ReadingStatus.listening,
                              onTap: () {
                                if (state.status == ReadingStatus.listening) {
                                  context.read<ReadingBloc>().add(
                                    StopReading(),
                                  );
                                } else {
                                  context.read<ReadingBloc>().add(
                                    StartListening(),
                                  );
                                }
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExplosion(ReadingState state) {
    return const EnergyCore(
          progress: 1.0,
          fluencyLevel: 1.0,
          isListening: false,
        )
        .animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(4, 4),
          duration: 1000.ms,
          curve: Curves.easeInExpo,
        )
        .blur(
          begin: const Offset(0, 0),
          end: const Offset(30, 30),
          duration: 1000.ms,
        )
        .fadeOut(delay: 800.ms, duration: 200.ms);
  }

  Widget _buildSessionSummary(BuildContext context, ReadingState state) {
    double averageScore = 0;
    if (state.sessionScores.isNotEmpty) {
      averageScore =
          state.sessionScores.reduce((a, b) => a + b) /
          state.sessionScores.length;
    }

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
                Icons.water_drop_rounded,
                size: 100,
                color: Color(0xFF00E5FF),
              )
              .animate()
              .scale(delay: 200.ms, duration: 800.ms, curve: Curves.elasticOut)
              .shimmer(duration: 2.seconds),
          const SizedBox(height: 32),
          Text(
            "¡FLUYE COMO EL AGUA!",
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Tu fluidez es refrescante",
            style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Text(
                  "${(averageScore * 100).toInt()}%",
                  style: GoogleFonts.outfit(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
                Text(
                  "PUNTUACIÓN DE FLUIDEZ",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showSummary = false;
                      });
                      context.read<ReadingBloc>().add(LoadReadingSession());
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00B0FF)),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "REPETIR",
                      style: TextStyle(color: Color(0xFF00B0FF)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: const Color(0xFF00B0FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "FINALIZAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String target,
    ReadingState state,
  ) {
    final recognizedWords = state.recognizedText
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ');

    List<InlineSpan> spans = [];
    final originalWords = target.split(' ');

    for (int i = 0; i < originalWords.length; i++) {
      String cleanWord = originalWords[i].toLowerCase().replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );

      Color color;
      FontWeight weight;

      if (recognizedWords.contains(cleanWord)) {
        color = const Color(0xFF00E5FF); // Watery Cyan
        weight = FontWeight.bold;
      } else {
        bool isFuzzy = false;
        for (final w in recognizedWords) {
          if (cleanWord.length > 3 && _levenshtein(cleanWord, w) <= 2) {
            isFuzzy = true;
            break;
          }
        }

        if (isFuzzy) {
          color = Colors.amberAccent;
          weight = FontWeight.w600;
        } else {
          color = Colors.white24;
          weight = FontWeight.normal;
        }
      }

      spans.add(
        TextSpan(
          text: "${originalWords[i]} ",
          style: GoogleFonts.outfit(
            fontSize: 28,
            height: 1.4,
            color: color,
            fontWeight: weight,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: 600.ms,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: RichText(
        key: ValueKey<String>(target),
        textAlign: TextAlign.center,
        text: TextSpan(children: spans),
      ),
    );
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) v0[i] = i;

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j < t.length + 1; j++) v0[j] = v1[j];
    }

    return v1[t.length];
  }

  void _showBubbleMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isError
                            ? Colors.redAccent.withValues(alpha: 0.9)
                            : const Color(0xFF1E1E1E).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isError
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            color: isError
                                ? Colors.white
                                : const Color(0xFF00E5FF),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              message,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack)
                    .then(delay: 2.seconds)
                    .fadeOut(duration: 400.ms)
                    .slideY(begin: 0, end: -0.5),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 2800), () {
      overlayEntry.remove();
    });
  }
}

class _WaterBackground extends StatelessWidget {
  const _WaterBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF001220), // Very dark blue
                Color(0xFF002A4D), // Dark water blue
                Color(0xFF001220),
              ],
            ),
          ),
        ),
        // Decorative bubbles/waves
        Positioned(
          top: -100,
          right: -50,
          child:
              Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00B0FF).withValues(alpha: 0.05),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: 50, duration: 4.seconds),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child:
              Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.03),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveX(begin: 0, end: 60, duration: 6.seconds),
        ),
      ],
    );
  }
}
