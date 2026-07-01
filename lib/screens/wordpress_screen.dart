import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class WordpressScreen extends StatefulWidget {
  const WordpressScreen({super.key});

  @override
  State<WordpressScreen> createState() => _WordpressScreenState();
}

class _WordpressScreenState extends State<WordpressScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic>? _posts;

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
      final data = await ApiService.getWordpressPosts();
      setState(() => _posts = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Entidades HTML mas comunes (acentos en espanol, comillas, etc.).
  static const Map<String, String> _entities = {
    '&#8217;': "'", '&#8216;': "'", '&#8220;': '"', '&#8221;': '"',
    '&#8230;': '...', '&hellip;': '...', '&nbsp;': ' ', '&amp;': '&',
    '&quot;': '"', '&#039;': "'", '&#39;': "'", '&laquo;': '«', '&raquo;': '»',
    '&aacute;': 'á', '&eacute;': 'é', '&iacute;': 'í', '&oacute;': 'ó',
    '&uacute;': 'ú', '&Aacute;': 'Á', '&Eacute;': 'É', '&Iacute;': 'Í',
    '&Oacute;': 'Ó', '&Uacute;': 'Ú', '&ntilde;': 'ñ', '&Ntilde;': 'Ñ',
    '&uuml;': 'ü', '&Uuml;': 'Ü', '&iexcl;': '¡', '&iquest;': '¿',
    '&ordf;': 'ª', '&ordm;': 'º', '&deg;': '°',
  };

  /// Quita etiquetas HTML y decodifica entidades.
  String _clean(String html) {
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    _entities.forEach((k, v) => text = text.replaceAll(k, v));
    // Entidades numericas restantes (&#123;).
    text = text.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });
    return text.trim();
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

  String? _featuredImage(Map<String, dynamic> post) {
    final embedded = post['_embedded'] as Map<String, dynamic>?;
    final media = embedded?['wp:featuredmedia'] as List?;
    if (media != null && media.isNotEmpty) {
      return media.first['source_url'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias WordPress'),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        if (_posts == null || _posts!.isEmpty)
          const Center(child: Text('No hay noticias disponibles.'))
        else
          ..._posts!.map((p) => _buildPost(p as Map<String, dynamic>)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo de la pagina hecha con WordPress.
        Image.network(
          'https://s.w.org/style/images/about/WordPress-logotype-standard.png',
          height: 60,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.wordpress, size: 60, color: Color(0xFF21759B)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Buenalectura',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          'buenalectura.wordpress.com',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ultimas 3 noticias publicadas',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPost(Map<String, dynamic> post) {
    final title = _clean((post['title']?['rendered'] ?? '').toString());
    final excerpt = _clean((post['excerpt']?['rendered'] ?? '').toString());
    final link = (post['link'] ?? '').toString();
    final image = _featuredImage(post);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            Image.network(
              image,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  excerpt,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: link.isEmpty ? null : () => _openUrl(link),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Visitar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
