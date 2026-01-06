import 'package:flutter/material.dart';
import 'dart:convert';

enum WallType { normal, bouncy, fragile }

enum Difficulty {
  easy(speedMultiplier: 0.7, densityMultiplier: 0.5, label: "Facile", basePoints: 10),
  medium(speedMultiplier: 1.0, densityMultiplier: 1.0, label: "Moyen", basePoints: 25),
  hard(speedMultiplier: 1.3, densityMultiplier: 2.0, label: "Difficile", basePoints: 50);

  final double speedMultiplier;
  final double densityMultiplier;
  final String label;
  final int basePoints;

  const Difficulty({
    required this.speedMultiplier,
    required this.densityMultiplier,
    required this.label,
    required this.basePoints,
  });
}

class Wall {
  Rect rect;
  WallType type;
  int health;

  Wall(this.rect, this.type, {this.health = 1});
}

class Instruction {
  final String text;
  final double triggerX;

  Instruction(this.text, this.triggerX);
}

class ScoreEntry {
  final String pseudo;
  final int score;
  final int throws;
  final String difficultyLabel;

  ScoreEntry({
    required this.pseudo,
    required this.score,
    required this.throws,
    required this.difficultyLabel,
  });

  Map<String, dynamic> toJson() => {
    'pseudo': pseudo,
    'score': score,
    'throws': throws,
    'difficultyLabel': difficultyLabel,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    pseudo: json['pseudo'],
    score: json['score'],
    throws: json['throws'],
    difficultyLabel: json['difficultyLabel'] ?? "Moyen",
  );
}
