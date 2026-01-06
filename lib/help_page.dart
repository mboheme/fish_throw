import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIDE & OBJETS'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Comment jouer'),
                _buildHelpItem(
                  Icons.touch_app,
                  Colors.white,
                  'Lancer le poisson',
                  'Appuyez sur le poisson et tirez vers l\'arrière pour viser. Relâchez pour lancer !',
                ),
                _buildHelpItem(
                  Icons.explore,
                  Colors.cyan,
                  'Exploration',
                  'Au début, faites glisser l\'écran pour voir le niveau. Cliquez sur "PASSER" pour commencer.',
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Obstacles & Objets'),
                _buildHelpItem(
                  Icons.stop,
                  Colors.blueGrey[800]!,
                  'Mur Normal',
                  'Un obstacle solide. Le poisson rebondit légèrement dessus.',
                ),
                _buildHelpItem(
                  Icons.bolt,
                  Colors.purpleAccent,
                  'Mur Rebondissant',
                  'Propulse le poisson avec beaucoup plus de force lors de l\'impact !',
                ),
                _buildHelpItem(
                  Icons.layers_clear,
                  Colors.grey,
                  'Mur Fragile',
                  'Se détruit au premier contact et rapporte des points bonus.',
                ),
                _buildHelpItem(
                  Icons.blur_on,
                  Colors.cyanAccent,
                  'Booster (Bulle)',
                  'Relance instantanément le poisson vers l\'avant et vers le haut.',
                ),
                _buildHelpItem(
                  Icons.shopping_basket,
                  Colors.yellow,
                  'Le Panier',
                  'C\'est l\'objectif ! Mettez le poisson dedans pour gagner la partie.',
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Survie'),
                _buildHelpItem(
                  Icons.waves,
                  Colors.blue,
                  'L\'eau',
                  'Si vous tombez dans l\'eau, vous perdez une vie et des points.',
                ),
                _buildHelpItem(
                  Icons.favorite,
                  Colors.red,
                  'Les Vies',
                  'Vous avez 3 vies. La partie s\'arrête quand vous n\'en avez plus.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, Color color, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
