import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe un nombre.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final data = await ApiService.getAge(name);
      setState(() => _result = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Devuelve etiqueta, imagen (emoji), color y mensaje segun la edad.
  _AgeStage _stageFor(int age) {
    if (age < 18) {
      return const _AgeStage(
        label: 'Joven',
        emoji: '🧒',
        color: Color(0xFF43A047),
        message: 'Es una persona joven, con mucha energia por delante.',
      );
    } else if (age < 60) {
      return const _AgeStage(
        label: 'Adulto',
        emoji: '🧑',
        color: Color(0xFF1E88E5),
        message: 'Es una persona adulta, en plena etapa productiva.',
      );
    } else {
      return const _AgeStage(
        label: 'Anciano',
        emoji: '🧓',
        color: Color(0xFF8E24AA),
        message: 'Es una persona anciana, llena de sabiduria y experiencia.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estimar Edad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _predict(),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la persona',
                        hintText: 'Ej: meelad',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _predict,
                        icon: const Icon(Icons.search),
                        label: const Text('Estimar edad'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center),
            if (_result != null && !_loading) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final age = _result!['age'];
    if (age == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No se pudo estimar la edad para ese nombre.'),
        ),
      );
    }
    final stage = _stageFor(age as int);
    return Card(
      color: stage.color.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: stage.color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 90)),
            const SizedBox(height: 8),
            Text(
              (_result!['name'] ?? '').toString().toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '$age años',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: stage.color,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                stage.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: stage.color,
            ),
            const SizedBox(height: 12),
            Text(
              stage.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeStage {
  final String label;
  final String emoji;
  final Color color;
  final String message;
  const _AgeStage({
    required this.label,
    required this.emoji,
    required this.color,
    required this.message,
  });
}
