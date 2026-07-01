import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
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
      final data = await ApiService.getGender(name);
      setState(() => _result = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  bool get _isMale => _result?['gender'] == 'male';
  bool get _isFemale => _result?['gender'] == 'female';

  Color get _bgColor {
    if (_isMale) return const Color(0xFF1E88E5); // azul
    if (_isFemale) return const Color(0xFFEC407A); // rosa
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final onColored = _result != null && (_isMale || _isFemale);
    return Scaffold(
      appBar: AppBar(title: const Text('Predecir Genero')),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: _bgColor,
        width: double.infinity,
        child: SingleChildScrollView(
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
                          hintText: 'Ej: irma',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _predict,
                          icon: const Icon(Icons.search),
                          label: const Text('Predecir genero'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_loading) const CircularProgressIndicator(color: Colors.white),
              if (_error != null)
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center),
              if (_result != null && !_loading) _buildResult(onColored),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(bool onColored) {
    if (!_isMale && !_isFemale) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No se pudo determinar el genero para ese nombre.'),
        ),
      );
    }
    final textColor = Colors.white;
    final probability = ((_result!['probability'] ?? 0) * 100).toStringAsFixed(0);
    return Column(
      children: [
        Icon(
          _isMale ? Icons.male : Icons.female,
          size: 120,
          color: textColor,
        ),
        const SizedBox(height: 12),
        Text(
          (_result!['name'] ?? '').toString().toUpperCase(),
          style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _isMale ? 'MASCULINO' : 'FEMENINO',
          style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Probabilidad: $probability%',
          style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 16),
        ),
      ],
    );
  }
}
