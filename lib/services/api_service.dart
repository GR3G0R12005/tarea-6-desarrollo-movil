import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centraliza todas las llamadas a las APIs usadas por la app.
class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  /// Genero a partir de un nombre -> https://api.genderize.io/?name=irma
  static Future<Map<String, dynamic>> getGender(String name) async {
    final url = Uri.parse('https://api.genderize.io/?name=${Uri.encodeComponent(name)}');
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar el genero');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Edad a partir de un nombre -> https://api.agify.io/?name=meelad
  static Future<Map<String, dynamic>> getAge(String name) async {
    final url = Uri.parse('https://api.agify.io/?name=${Uri.encodeComponent(name)}');
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar la edad');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Universidades de un pais -> https://adamix.net/proxy.php?country=Dominican+Republic
  static Future<List<dynamic>> getUniversities(String country) async {
    final url = Uri.parse('https://adamix.net/proxy.php?country=${Uri.encodeComponent(country)}');
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar universidades');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded;
    return const [];
  }

  /// Clima actual en Santo Domingo, RD (Open-Meteo, sin API key).
  static Future<Map<String, dynamic>> getWeatherRD() async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=18.4861&longitude=-69.9312'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'weather_code,wind_speed_10m'
      '&daily=temperature_2m_max,temperature_2m_min,weather_code'
      '&timezone=America%2FSanto_Domingo&forecast_days=1',
    );
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar el clima');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Datos de un Pokemon -> https://pokeapi.co/api/v2/pokemon/pikachu
  static Future<Map<String, dynamic>> getPokemon(String name) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${Uri.encodeComponent(name.toLowerCase().trim())}');
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode == 404) {
      throw Exception('No se encontro el Pokemon "$name"');
    }
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar el Pokemon');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Ultimas noticias del sitio WordPress "Buenalectura".
  static Future<List<dynamic>> getWordpressPosts() async {
    final url = Uri.parse(
      'https://public-api.wordpress.com/wp/v2/sites/buenalectura.wordpress.com/posts'
      '?per_page=3&_embed',
    );
    final res = await http.get(url).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar las noticias');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded;
    return const [];
  }
}
