import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final List<String> _masteryLevels = const [
    "Susurro Inicial",
    "Balbuceo Curioso",
    "Voz Tímida",
    "Voz Clara",
    "Hablante Resonante",
    "Eco Fiel",
    "Eco Armónico",
    "Resonancia Cristalina",
    "Voz Soberana",
    "Eco Maestro",
  ];

  @override
  Widget build(BuildContext context) {
    // Mock current level
    const int currentLevelIndex = 2; // "Voz Tímida"

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Voz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Profile
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white10,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

            Text(
              "Estudiante",
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn().moveY(begin: 10, end: 0),

            Text(
              "Nivel Actual: ${_masteryLevels[currentLevelIndex]}",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),

            const SizedBox(height: 48),

            // Mastery Path
            Text(
              "Camino a la Maestría",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _masteryLevels.length,
              itemBuilder: (context, index) {
                final isUnlocked = index <= currentLevelIndex;
                final isCurrent = index == currentLevelIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      // Connector Line (Visual only, simplistic)
                      SizedBox(
                        width: 40,
                        child: Column(
                          children: [
                            Container(
                              width: 2,
                              height: 15,
                              color: index == 0
                                  ? Colors.transparent
                                  : Colors.grey[800],
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnlocked
                                    ? (isCurrent
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.grey[600])
                                    : Colors.grey[900],
                                border: Border.all(
                                  color: isUnlocked
                                      ? Colors.transparent
                                      : Colors.grey[800]!,
                                  width: 2,
                                ),
                              ),
                              child: isUnlocked
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                            Container(
                              width: 2,
                              height: 15,
                              color: index == _masteryLevels.length - 1
                                  ? Colors.transparent
                                  : Colors.grey[800],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Card
                      Expanded(
                        child:
                            Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.1)
                                        : Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isCurrent
                                        ? Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.5),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _masteryLevels[index],
                                        style: GoogleFonts.inter(
                                          fontWeight: isUnlocked
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isUnlocked
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      if (isCurrent)
                                        const Text(
                                          "ACTUAL",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.greenAccent,
                                          ),
                                        )
                                      else if (!isUnlocked)
                                        const Icon(
                                          Icons.lock,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                    ],
                                  ),
                                )
                                .animate(delay: (index * 100).ms)
                                .fadeIn()
                                .slideX(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
