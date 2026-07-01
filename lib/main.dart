import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme.dart';
import 'screens/gender_screen.dart';
import 'screens/age_screen.dart';
import 'screens/universities_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/pokemon_screen.dart';
import 'screens/wordpress_screen.dart';
import 'screens/about_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('es');
  runApp(const CajaHerramientasApp());
}

class CajaHerramientasApp extends StatelessWidget {
  const CajaHerramientasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caja de Herramientas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}

/// Descripcion de cada herramienta del menu principal.
class _Tool {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() builder;

  const _Tool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<_Tool> get _tools => [
        _Tool(
          title: 'Genero',
          subtitle: 'Predice el genero por nombre',
          icon: Icons.wc,
          color: const Color(0xFF5C6BC0),
          builder: () => const GenderScreen(),
        ),
        _Tool(
          title: 'Edad',
          subtitle: 'Estima la edad por nombre',
          icon: Icons.cake,
          color: const Color(0xFF26A69A),
          builder: () => const AgeScreen(),
        ),
        _Tool(
          title: 'Universidades',
          subtitle: 'Universidades por pais',
          icon: Icons.school,
          color: const Color(0xFF8D6E63),
          builder: () => const UniversitiesScreen(),
        ),
        _Tool(
          title: 'Clima RD',
          subtitle: 'Clima de hoy en Rep. Dominicana',
          icon: Icons.wb_sunny,
          color: const Color(0xFFFFA726),
          builder: () => const WeatherScreen(),
        ),
        _Tool(
          title: 'Pokemon',
          subtitle: 'Busca un Pokemon',
          icon: Icons.catching_pokemon,
          color: const Color(0xFFEF5350),
          builder: () => const PokemonScreen(),
        ),
        _Tool(
          title: 'Noticias',
          subtitle: 'Ultimas noticias (WordPress)',
          icon: Icons.article,
          color: const Color(0xFF42A5F5),
          builder: () => const WordpressScreen(),
        ),
        _Tool(
          title: 'Acerca de',
          subtitle: 'Datos de contacto',
          icon: Icons.person,
          color: const Color(0xFF66BB6A),
          builder: () => const AboutScreen(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja de Herramientas'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildToolCard(context, _tools[index]),
                childCount: _tools.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF1E88E5)],
        ),
      ),
      child: Column(
        children: [
          // Foto de una caja de herramientas (esta app sirve para varias cosas).
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1581147036324-c1c9bf03185b?auto=format&fit=crop&w=800&q=60',
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 170,
                  color: Colors.white24,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              },
              errorBuilder: (context, error, stack) => Container(
                height: 170,
                color: AppTheme.accent,
                child: const Center(
                  child: Icon(Icons.handyman, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Una herramienta para cada tarea',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona una opcion para comenzar',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _Tool tool) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => tool.builder()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: tool.color.withValues(alpha: 0.15),
                child: Icon(tool.icon, size: 32, color: tool.color),
              ),
              const SizedBox(height: 12),
              Text(
                tool.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                tool.subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
