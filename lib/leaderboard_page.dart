import 'package:flutter/material.dart';
import 'models.dart';

class LeaderboardPage extends StatefulWidget {
  final List<ScoreEntry> leaderboard;

  const LeaderboardPage({super.key, required this.leaderboard});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String _selectedDifficulty = "Tous";

  @override
  Widget build(BuildContext context) {
    final filteredScores = _selectedDifficulty == "Tous"
        ? widget.leaderboard
        : widget.leaderboard.where((s) => s.difficultyLabel == _selectedDifficulty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEILLEURS SCORES'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001220), Color(0xFF002540)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Filter bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: ["Tous", "Facile", "Moyen", "Difficile"].map((diff) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(diff),
                        selected: _selectedDifficulty == diff,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDifficulty = diff);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filteredScores.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun score pour cette catégorie...',
                          style: TextStyle(fontSize: 18, color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredScores.length,
                        itemBuilder: (context, index) {
                          final entry = filteredScores[index];
                          return Card(
                            color: Colors.white.withOpacity(0.05),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index < 3 ? Colors.amber : Colors.blueGrey,
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                              ),
                              title: Text(entry.pseudo),
                              subtitle: Text('${entry.throws} lancers • ${entry.difficultyLabel}'),
                              trailing: Text(
                                '${entry.score} pts',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
