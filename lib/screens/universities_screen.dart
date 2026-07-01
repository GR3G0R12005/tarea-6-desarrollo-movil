import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final _controller = TextEditingController(text: 'Dominican Republic');
  bool _loading = false;
  String? _error;
  List<dynamic>? _universities;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final country = _controller.text.trim();
    if (country.isEmpty) {
      setState(() => _error = 'Escribe un pais en ingles.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _universities = null;
    });
    try {
      final data = await ApiService.getUniversities(country);
      setState(() => _universities = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades por Pais')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: 'Pais (en ingles)',
                    hintText: 'Ej: Dominican Republic',
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar universidades'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center),
        ),
      );
    }
    if (_universities == null) {
      return const Center(child: Text('Busca un pais para ver sus universidades.'));
    }
    if (_universities!.isEmpty) {
      return const Center(child: Text('No se encontraron universidades para ese pais.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _universities!.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final uni = _universities![index] as Map<String, dynamic>;
        final name = uni['name'] ?? 'Sin nombre';
        final domains = (uni['domains'] as List?) ?? const [];
        final webPages = (uni['web_pages'] as List?) ?? const [];
        final domain = domains.isNotEmpty ? domains.first.toString() : 'N/D';
        final web = webPages.isNotEmpty ? webPages.first.toString() : '';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF8D6E63),
                      child: Icon(Icons.school, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.language, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Dominio: $domain')),
                  ],
                ),
                if (web.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _openUrl(web),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 18, color: Color(0xFF1565C0)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            web,
                            style: const TextStyle(
                              color: Color(0xFF1565C0),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
