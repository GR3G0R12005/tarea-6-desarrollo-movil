import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 76,
                      backgroundImage: const AssetImage('assets/images/gregory.png'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gregory Martinez',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Desarrollador Movil',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Datos de contacto para posibles trabajos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _contactCard(
                    context,
                    icon: Icons.email,
                    color: const Color(0xFFD32F2F),
                    title: 'Correo electronico',
                    value: 'gregorymartinez0212@gmail.com',
                    onTap: () => _launch(
                        context, 'mailto:gregorymartinez0212@gmail.com'),
                  ),
                  _contactCard(
                    context,
                    icon: Icons.phone,
                    color: const Color(0xFF388E3C),
                    title: 'Telefono',
                    value: '829-634-2005',
                    onTap: () => _launch(context, 'tel:+18296342005'),
                  ),
                  _contactCard(
                    context,
                    icon: Icons.chat,
                    color: const Color(0xFF25D366),
                    title: 'WhatsApp',
                    value: '+1 829-634-2005',
                    onTap: () => _launch(context, 'https://wa.me/18296342005'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Caja de Herramientas v1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    'Tarea 6 - Desarrollo Movil',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
