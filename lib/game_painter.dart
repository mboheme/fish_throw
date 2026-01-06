import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';

class GamePainter extends CustomPainter {
  final Offset fishPos;
  final double fishRadius;
  final List<Wall> walls;
  final List<Offset> boosters;
  final Offset goal;
  final bool isDragging;
  final Offset dragStart;
  final Offset dragCurrent;
  final double cameraX;
  final Offset fishVel;

  GamePainter({
    required this.fishPos,
    required this.fishRadius,
    required this.walls,
    required this.boosters,
    required this.goal,
    required this.isDragging,
    required this.dragStart,
    required this.dragCurrent,
    required this.cameraX,
    required this.fishVel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(-cameraX, 0);

    // Draw Water (Eau en bas)
    final waterPaint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    // On dessine l'eau sur toute la longueur du niveau
    // On considère que l'eau commence à size.height - 50 (par exemple)
    double waterLevel = size.height - 60;
    canvas.drawRect(
      Rect.fromLTWH(cameraX, waterLevel, size.width, 60),
      waterPaint,
    );
    
    // Draw waves details
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double i = cameraX; i < cameraX + size.width; i += 40) {
      canvas.drawArc(
        Rect.fromLTWH(i, waterLevel - 5, 40, 10),
        0,
        pi,
        false,
        wavePaint,
      );
    }

    // Draw Goal (Basket/Panier)
    final goalPaint = Paint()..color = Colors.yellow;
    final basketRect = Rect.fromCenter(center: goal, width: 80, height: 60);
    canvas.drawRect(basketRect, goalPaint..style = PaintingStyle.stroke..strokeWidth = 4);
    
    // Basket net
    final netPaint = Paint()..color = Colors.white30..strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(basketRect.left + i * 20, basketRect.top),
        Offset(basketRect.left + i * 20 - 10, basketRect.bottom + 20),
        netPaint,
      );
    }

    // Draw Boosters
    for (var booster in boosters) {
      final bPaint = Paint()..color = Colors.cyanAccent;
      canvas.drawCircle(booster, 15, bPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(booster, 15, bPaint..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // Draw Walls
    for (var wall in walls) {
      Paint wPaint;
      switch (wall.type) {
        case WallType.bouncy:
          wPaint = Paint()..color = Colors.purpleAccent;
          break;
        case WallType.fragile:
          wPaint = Paint()..color = Colors.grey.withOpacity(0.7);
          break;
        default:
          wPaint = Paint()..color = Colors.blueGrey[800]!;
      }
      canvas.drawRRect(RRect.fromRectAndRadius(wall.rect, const Radius.circular(4)), wPaint);
    }

    // Draw Fish
    canvas.save();
    canvas.translate(fishPos.dx, fishPos.dy);
    double angle = atan2(fishVel.dy, fishVel.dx);
    if (isDragging) angle = atan2(dragStart.dy - dragCurrent.dy, dragStart.dx - dragCurrent.dx);
    canvas.rotate(angle);

    final fishPaint = Paint()..color = Colors.orange;
    canvas.drawCircle(Offset.zero, fishRadius, fishPaint);
    // Tail
    Path tail = Path();
    tail.moveTo(-fishRadius, 0);
    tail.lineTo(-fishRadius - 12, -10);
    tail.lineTo(-fishRadius - 12, 10);
    tail.close();
    canvas.drawPath(tail, fishPaint);
    // Eye
    canvas.drawCircle(const Offset(8, -5), 3, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(9, -5), 1.5, Paint()..color = Colors.black);
    canvas.restore();

    // Draw Aim Line
    if (isDragging) {
      final aimPaint = Paint()
        ..color = Colors.white70
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      Offset startInWorld = fishPos;
      Offset direction = (dragStart - dragCurrent) * 0.15;
      
      Path path = Path();
      path.moveTo(startInWorld.dx, startInWorld.dy);
      
      Offset tempPos = startInWorld;
      Offset tempVel = direction;
      for (int i = 0; i < 20; i++) {
        tempVel += const Offset(0, 0.25);
        tempPos += tempVel;
        path.lineTo(tempPos.dx, tempPos.dy);
      }
      canvas.drawPath(path, aimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
