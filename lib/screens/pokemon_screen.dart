import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final _controller = TextEditingController(text: 'pikachu');
  final _player = AudioPlayer();
  bool _loading = false;
  bool _playing = false;
  String? _error;
  Map<String, dynamic>? _pokemon;

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe el nombre de un Pokemon.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _pokemon = null;
    });
    try {
      final data = await ApiService.getPokemon(name);
      setState(() => _pokemon = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _playCry() async {
    final cries = _pokemon?['cries'] as Map<String, dynamic>?;
    final url = cries?['latest'] as String?;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este Pokemon no tiene sonido disponible.')),
      );
      return;
    }
    try {
      setState(() => _playing = true);
      await _player.play(UrlSource(url));
      _player.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playing = false);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _playing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo reproducir el sonido.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscador de Pokemon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: const InputDecoration(
                labelText: 'Nombre del Pokemon',
                hintText: 'Ej: pikachu',
                prefixIcon: Icon(Icons.catching_pokemon),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center),
            if (_pokemon != null && !_loading) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final name = (_pokemon!['name'] ?? '').toString();
    final baseExp = _pokemon!['base_experience'];
    final sprites = _pokemon!['sprites'] as Map<String, dynamic>;
    final other = sprites['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;
    final img = artwork?['front_default'] ?? sprites['front_default'];
    final abilities = (_pokemon!['abilities'] as List)
        .map((a) => (a['ability']?['name'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              name.toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (img != null)
              Image.network(
                img.toString(),
                height: 200,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.catching_pokemon, size: 120),
              )
            else
              const Icon(Icons.catching_pokemon, size: 120),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFEF5350)),
                  const SizedBox(width: 8),
                  Text('Experiencia base: ${baseExp ?? "N/D"}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Habilidades:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: abilities
                  .map((a) => Chip(
                        avatar: const Icon(Icons.flash_on, size: 18),
                        label: Text(a),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _playing ? null : _playCry,
                icon: Icon(_playing ? Icons.volume_up : Icons.play_arrow),
                label: Text(_playing ? 'Reproduciendo...' : 'Reproducir sonido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
