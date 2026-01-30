import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final String id;
  final String title;
  final String content;
  final String level; // Beginner, Intermediate, Advanced
  final String category; // News, Fiction, Business
  final int estimatedDurationSeconds;
  final String? audioUrl; // URL for native reference audio

  const Story({
    required this.id,
    required this.title,
    required this.content,
    required this.level,
    required this.category,
    required this.estimatedDurationSeconds,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    level,
    category,
    estimatedDurationSeconds,
    audioUrl,
  ];
}
