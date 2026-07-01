import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getWeatherRD();
      setState(() => _data = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Traduce el codigo WMO de Open-Meteo a texto + icono.
  (String, IconData) _describe(int code) {
    if (code == 0) return ('Despejado', Icons.wb_sunny);
    if (code <= 2) return ('Parcialmente nublado', Icons.wb_cloudy);
    if (code == 3) return ('Nublado', Icons.cloud);
    if (code <= 48) return ('Neblina', Icons.foggy);
    if (code <= 57) return ('Llovizna', Icons.grain);
    if (code <= 67) return ('Lluvia', Icons.umbrella);
    if (code <= 77) return ('Nieve', Icons.ac_unit);
    if (code <= 82) return ('Chubascos', Icons.beach_access);
    if (code <= 99) return ('Tormenta', Icons.thunderstorm);
    return ('Desconocido', Icons.help_outline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima en RD'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final current = _data!['current'] as Map<String, dynamic>;
    final daily = _data!['daily'] as Map<String, dynamic>;
    final code = (current['weather_code'] ?? 0) as int;
    final desc = _describe(code);
    final temp = current['temperature_2m'];
    final feels = current['apparent_temperature'];
    final humidity = current['relative_humidity_2m'];
    final wind = current['wind_speed_10m'];
    final maxT = (daily['temperature_2m_max'] as List).first;
    final minT = (daily['temperature_2m_min'] as List).first;
    final today = DateFormat("EEEE d 'de' MMMM 'de' y", 'es').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
              ),
            ),
            child: Column(
              children: [
                const Text('Santo Domingo, Republica Dominicana',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text(today,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Icon(desc.$2, size: 90, color: Colors.white),
                const SizedBox(height: 8),
                Text('$temp°C',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold)),
                Text(desc.$1,
                    style: const TextStyle(color: Colors.white, fontSize: 22)),
                const SizedBox(height: 6),
                Text('Sensacion: $feels°C',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _infoCard(Icons.arrow_upward, 'Maxima', '$maxT°C', Colors.red),
              const SizedBox(width: 12),
              _infoCard(Icons.arrow_downward, 'Minima', '$minT°C', Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoCard(Icons.water_drop, 'Humedad', '$humidity%', Colors.teal),
              const SizedBox(width: 12),
              _infoCard(Icons.air, 'Viento', '$wind km/h', Colors.blueGrey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
