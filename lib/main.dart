import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'game_painter.dart';
import 'leaderboard_page.dart';
import 'help_page.dart';

void main() {
  runApp(const FishThrowApp());
}

class FishThrowApp extends StatelessWidget {
  const FishThrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lancer de poisson',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _pseudoController = TextEditingController(text: "Joueur 1");
  final TextEditingController _pseudo2Controller = TextEditingController(text: "Joueur 2");
  Difficulty _difficulty = Difficulty.medium;
  bool _startAid = true;
  bool _isMultiplayer = false;
  List<ScoreEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString('leaderboard');
    if (scoresJson != null) {
      final List<dynamic> decoded = jsonDecode(scoresJson);
      setState(() {
        _leaderboard = decoded.map((item) => ScoreEntry.fromJson(item)).toList();
        _leaderboard.sort((a, b) => b.score.compareTo(a.score));
      });
    }
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_leaderboard.map((e) => e.toJson()).toList());
    await prefs.setString('leaderboard', encoded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001220), Color(0xFF002540)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'FISH THROW',
                    style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person),
                      Switch(
                        value: _isMultiplayer,
                        onChanged: (v) => setState(() => _isMultiplayer = v),
                        activeColor: Colors.orange,
                      ),
                      const Icon(Icons.people),
                      const SizedBox(width: 10),
                      Text(_isMultiplayer ? "Mode 2 Joueurs (Local)" : "Mode Solo"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _pseudoController,
                      decoration: InputDecoration(
                        labelText: _isMultiplayer ? 'Pseudo Joueur 1' : 'Pseudo',
                        border: const OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                  ),
                  if (_isMultiplayer) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _pseudo2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Pseudo Joueur 2',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text('Difficulté:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    children: Difficulty.values.map((d) {
                      return ChoiceChip(
                        label: Text(d.label),
                        selected: _difficulty == d,
                        onSelected: (selected) {
                          if (selected) setState(() => _difficulty = d);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: CheckboxListTile(
                      title: const Text("Texte d'aide", style: TextStyle(fontSize: 14)),
                      value: _startAid,
                      activeColor: Colors.orange,
                      onChanged: (val) => setState(() => _startAid = val ?? true),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            pseudo: _pseudoController.text,
                            pseudo2: _isMultiplayer ? _pseudo2Controller.text : null,
                            difficulty: _difficulty,
                            startAid: _startAid,
                          ),
                        ),
                      );
                      if (result is List<ScoreEntry>) {
                        setState(() {
                          _leaderboard.addAll(result);
                          _leaderboard.sort((a, b) => b.score.compareTo(a.score));
                        });
                        await _saveScores();
                      } else if (result is ScoreEntry) {
                        setState(() {
                          _leaderboard.add(result);
                          _leaderboard.sort((a, b) => b.score.compareTo(a.score));
                        });
                        await _saveScores();
                      }
                    },
                    child: const Text('JOUER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaderboardPage(leaderboard: _leaderboard),
                            ),
                          );
                        },
                        icon: const Icon(Icons.emoji_events, color: Colors.amber),
                        label: const Text('SCORES', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.help_outline, color: Colors.cyanAccent),
                        label: const Text('AIDE', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String pseudo;
  final String? pseudo2;
  final Difficulty difficulty;
  final bool startAid;

  const GameScreen({
    super.key,
    required this.pseudo,
    this.pseudo2,
    required this.difficulty,
    required this.startAid,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Offset fishPos = Offset.zero;
  Offset fishVel = Offset.zero;
  bool isDragging = false;
  bool gameLaunched = false;
  Offset dragStart = Offset.zero;
  Offset dragCurrent = Offset.zero;

  List<Wall> walls = [];
  List<Offset> boosters = [];
  List<Instruction> instructions = [];
  String? currentInstruction;
  
  Offset goal = const Offset(5500, 350);
  final double fishRadius = 18;
  
  int currentPlayer = 1;
  int throws1 = 0, score1 = 0, lives1 = 3;
  int throws2 = 0, score2 = 0, lives2 = 3;
  
  bool hasWon = false;
  bool hasLost = false;
  bool turnFinished = false;
  
  double cameraX = 0;
  bool _initialized = false;
  Size _screenSize = Size.zero;

  bool isPreviewing = false;
  int previewPhase = 0; 
  bool isUserTouchingPreview = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _ticker.start();
  }

  void _generateLevel(Size size) {
    walls.clear();
    boosters.clear();
    instructions.clear();
    hasWon = false;
    hasLost = false;
    turnFinished = false;
    gameLaunched = false;
    fishPos = Offset(size.width / 2, size.height / 2);
    fishVel = Offset.zero;
    cameraX = 0;
    
    isPreviewing = true;
    previewPhase = 0;

    String currentName = currentPlayer == 1 ? widget.pseudo : widget.pseudo2!;
    instructions.addAll([
      Instruction("Au tour de $currentName !", 0),
      Instruction("Attrape et lance le poisson !", 400),
      Instruction("Mode ${widget.difficulty.label} (+${widget.difficulty.basePoints} pts/mur)", 1000),
    ]);

    final random = Random();
    int sections = 15;
    double startPadding = fishPos.dx + 400;

    for (int section = 0; section < sections; section++) {
      double startX = startPadding + section * 400;
      int baseDensity = (widget.difficulty.densityMultiplier * (random.nextInt(2) + 1)).round();
      if (widget.difficulty == Difficulty.hard) baseDensity += 1;

      for (int i = 0; i < baseDensity; i++) {
        double w = 20.0 + random.nextDouble() * 30;
        double h = 80.0 + random.nextDouble() * 150;
        double x = startX + random.nextDouble() * 250;
        double y = random.nextDouble() * (size.height - 150);
        
        WallType type = WallType.normal;
        if (section > 2 && random.nextDouble() > 0.7) type = WallType.bouncy;
        if (section > 5 && random.nextDouble() > 0.8) type = WallType.fragile;
        
        walls.add(Wall(Rect.fromLTWH(x, y, w, h), type));
      }
      if (random.nextDouble() > 0.5 / widget.difficulty.densityMultiplier) {
        boosters.add(Offset(startX + 200, 100 + random.nextDouble() * (size.height - 250)));
      }
    }
    goal = Offset(startPadding + sections * 400.0, size.height / 2);
  }

  void _tick(Duration elapsed) {
    if (!_initialized) return;

    if (isPreviewing) {
      if (!isUserTouchingPreview) {
        setState(() {
          if (previewPhase == 0) {
            cameraX += 12; 
            if (cameraX >= goal.dx - _screenSize.width / 2) {
              cameraX = goal.dx - _screenSize.width / 2;
              previewPhase = 1;
            }
          } else {
            cameraX -= 25; 
            if (cameraX <= 0) {
              cameraX = 0;
              isPreviewing = false;
            }
          }
        });
      }
      return;
    }

    if (isDragging || hasWon || hasLost || !gameLaunched || turnFinished) return;

    setState(() {
      fishVel += Offset(0, 0.25 * widget.difficulty.speedMultiplier);
      fishPos += fishVel;
      fishVel *= (0.985);

      if (fishPos.dx > _screenSize.width / 2) {
        cameraX = fishPos.dx - _screenSize.width / 2;
      }

      currentInstruction = null;
      for (var ins in instructions) {
        if (fishPos.dx >= ins.triggerX && fishPos.dx < ins.triggerX + 800) {
          currentInstruction = ins.text;
        }
      }

      final fishRect = Rect.fromCircle(center: fishPos, radius: fishRadius);
      for (int i = walls.length - 1; i >= 0; i--) {
        if (walls[i].rect.overlaps(fishRect)) {
          final wall = walls[i];
          if (fishPos.dx < wall.rect.left || fishPos.dx > wall.rect.right) {
            fishVel = Offset(-fishVel.dx * (wall.type == WallType.bouncy ? 1.2 : 0.6), fishVel.dy);
          } else {
            fishVel = Offset(fishVel.dx, -fishVel.dy * (wall.type == WallType.bouncy ? 1.2 : 0.6));
          }
          if (wall.type == WallType.fragile) {
            walls.removeAt(i);
            int gain = widget.difficulty.basePoints;
            if (currentPlayer == 1) score1 += gain; else score2 += gain;
          }
          break;
        }
      }

      for (int i = boosters.length - 1; i >= 0; i--) {
        if ((fishPos - boosters[i]).distance < fishRadius + 20) {
          fishVel = Offset(20 * widget.difficulty.speedMultiplier, -6);
          boosters.removeAt(i);
          if (currentPlayer == 1) score1 += 100; else score2 += 100;
        }
      }

      if ((fishPos - goal).distance < 60) {
        int winBonus = max(0, (1000 * widget.difficulty.speedMultiplier).round() - ((currentPlayer == 1 ? throws1 : throws2) * 40));
        if (currentPlayer == 1) score1 += winBonus; else score2 += winBonus;
        
        if (widget.pseudo2 != null && currentPlayer == 1) {
          turnFinished = true;
        } else {
          hasWon = true;
        }
      }

      double waterLevel = _screenSize.height - 60;
      if (fishPos.dy > waterLevel - fishRadius) {
        if (currentPlayer == 1) {
          lives1--;
          if (lives1 <= 0) {
            if (widget.pseudo2 != null) turnFinished = true; else hasLost = true;
          } else {
            _respawn();
          }
        } else {
          lives2--;
          if (lives2 <= 0) hasLost = true; else _respawn();
        }
      }

      if (fishPos.dy < -500 || fishPos.dx < cameraX - 100) {
        _respawn();
      }
    });
  }

  void _respawn() {
    fishPos = Offset(cameraX + _screenSize.width / 2, _screenSize.height / 2);
    fishVel = Offset.zero;
    gameLaunched = false;
  }

  void _nextPlayer() {
    setState(() {
      currentPlayer = 2;
      _generateLevel(_screenSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001220),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!_initialized) {
            _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
            _generateLevel(_screenSize);
            _initialized = true;
          }
          
          double progress = isPreviewing 
              ? (cameraX / (goal.dx - _screenSize.width / 2)).clamp(0.0, 1.0)
              : (fishPos.dx / goal.dx).clamp(0.0, 1.0);

          String currentPseudo = currentPlayer == 1 ? widget.pseudo : widget.pseudo2!;
          int currentLives = currentPlayer == 1 ? lives1 : lives2;
          int currentScore = currentPlayer == 1 ? score1 : score2;
          int currentThrows = currentPlayer == 1 ? throws1 : throws2;

          return Stack(
            children: [
              GestureDetector(
                onPanStart: (details) {
                  if (hasWon || hasLost || turnFinished) return;
                  if (isPreviewing) {
                    isUserTouchingPreview = true;
                    return;
                  }
                  Offset localPos = details.localPosition + Offset(cameraX, 0);
                  if ((localPos - fishPos).distance < 100) {
                    setState(() {
                      isDragging = true;
                      dragStart = details.localPosition;
                      dragCurrent = details.localPosition;
                    });
                  }
                },
                onPanUpdate: (details) {
                  if (isPreviewing && isUserTouchingPreview) {
                    setState(() {
                      cameraX = (cameraX - details.delta.dx).clamp(0.0, goal.dx - _screenSize.width / 2);
                    });
                  } else if (isDragging) {
                    setState(() => dragCurrent = details.localPosition);
                  }
                },
                onPanEnd: (details) {
                  if (isPreviewing) {
                    isUserTouchingPreview = false;
                    return;
                  }
                  if (isDragging) {
                    setState(() {
                      Offset diff = dragStart - dragCurrent;
                      fishVel = diff * (0.15 * widget.difficulty.speedMultiplier);
                      isDragging = false;
                      if (!gameLaunched && diff.distance > 5) gameLaunched = true;
                      if (currentPlayer == 1) throws1++; else throws2++;
                    });
                  }
                },
                child: CustomPaint(
                  painter: GamePainter(
                    fishPos: fishPos,
                    fishRadius: fishRadius,
                    walls: walls,
                    boosters: boosters,
                    goal: goal,
                    isDragging: isDragging,
                    dragStart: dragStart,
                    dragCurrent: dragCurrent,
                    cameraX: cameraX,
                    fishVel: fishVel,
                  ),
                  child: Container(),
                ),
              ),
              
              Positioned(
                top: 40, left: 20, right: 20,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentPseudo, style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(3, (index) => Icon(
                                Icons.favorite,
                                color: index < currentLives ? Colors.red : Colors.grey,
                                size: 24,
                              )),
                            ),
                          ],
                        ),
                        if (widget.pseudo2 != null)
                          Text("TOUR JOUEUR $currentPlayer", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$currentScore pts', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                            Text('Lancers: $currentThrows', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 10, width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(decoration: BoxDecoration(color: isPreviewing ? Colors.cyan.withOpacity(0.5) : Colors.orange.withOpacity(0.5), borderRadius: BorderRadius.circular(5))),
                          ),
                          Align(alignment: Alignment(progress * 2 - 1, 0), child: Container(width: 14, height: 14, decoration: BoxDecoration(color: isPreviewing ? Colors.cyan : Colors.orange, shape: BoxShape.circle))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isPreviewing)
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const Text("Mode Exploration - Glissez pour explorer", style: TextStyle(fontSize: 14)),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() { isPreviewing = false; cameraX = 0; }),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                        child: const Text("PASSER"),
                      ),
                    ],
                  ),
                ),

              if (turnFinished)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange, width: 3)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Fin du tour de ${widget.pseudo} !", style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 10),
                        Text("Score : $score1", style: const TextStyle(fontSize: 32, color: Colors.amber)),
                        const SizedBox(height: 20),
                        ElevatedButton(onPressed: _nextPlayer, child: Text("AU TOUR DE ${widget.pseudo2!.toUpperCase()}")),
                      ],
                    ),
                  ),
                ),

              if (hasWon || hasLost)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16), border: Border.all(color: hasWon ? Colors.amber : Colors.red, width: 3)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(hasWon ? 'PARTIE TERMINÉE !' : 'GAME OVER', style: TextStyle(fontSize: 32, color: hasWon ? Colors.amber : Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        if (widget.pseudo2 != null) ...[
                          Text("${widget.pseudo} : $score1 pts", style: const TextStyle(fontSize: 20)),
                          Text("${widget.pseudo2} : $score2 pts", style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 10),
                          Text(score1 > score2 ? "VICTOIRE DE ${widget.pseudo.toUpperCase()} !" : (score2 > score1 ? "VICTOIRE DE ${widget.pseudo2!.toUpperCase()} !" : "ÉGALITÉ !"), 
                            style: const TextStyle(fontSize: 22, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ] else ...[
                          Text('Score final : $score1', style: const TextStyle(fontSize: 24)),
                        ],
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            List<ScoreEntry> scores = [ScoreEntry(pseudo: widget.pseudo, score: score1, throws: throws1, difficultyLabel: widget.difficulty.label)];
                            if (widget.pseudo2 != null) scores.add(ScoreEntry(pseudo: widget.pseudo2!, score: score2, throws: throws2, difficultyLabel: widget.difficulty.label));
                            Navigator.pop(context, scores);
                          },
                          child: const Text('RETOUR AU MENU'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (widget.startAid && !gameLaunched && !hasWon && !hasLost && !turnFinished && !isPreviewing)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Text("C'est à toi $currentPseudo !", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const Icon(Icons.touch_app, size: 50, color: Colors.white54),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
