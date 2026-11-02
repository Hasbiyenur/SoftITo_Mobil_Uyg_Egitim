import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../widgets/info_card.dart';

/// Hukuki Destek Ekranı
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  void _showLegalDetail(BuildContext context, LegalTopic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LegalDetailSheet(topic: topic),
    );
  }

  void _showLawyerDetail(BuildContext context, LawyerProfile lawyer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.gavel, color: Colors.blueGrey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lawyer.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lawyer.demoNote,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Uzmanlık: ${lawyer.field}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lawyer.description,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hukuki Destek'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const NoticeBanner(
              message:
                  'ÖNEMLİ YASAL UYARI: Bu bölümdeki bilgiler ve avukat profilleri yalnızca eğitim ve demo amaçlıdır. Hukuki tavsiye veya gerçek avukatlık hizmeti teşkil etmez.',
              icon: Icons.gavel,
              color: Colors.redAccent,
            ),
            Text(
              'Temel Hukuki Bilgiler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...SampleData.legalTopics.map(
              (topic) => InfoCard(
                title: topic.title,
                description: topic.summary,
                icon: topic.icon,
                iconColor: const Color(0xFF5C6BC0),
                badgeText: 'Hukuki Rehber',
                badgeColor: const Color(0xFF3949AB),
                onTap: () => _showLegalDetail(context, topic),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Demo Danışman Profilleri (Kurgusal)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gerçek kişi değillerdir; iletişim veya randevu imkanı bulunmamaktadır.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ...SampleData.lawyers.map(
              (lawyer) => InfoCard(
                title: lawyer.name,
                description: '${lawyer.field} — ${lawyer.description}',
                icon: Icons.balance,
                iconColor: Colors.blueGrey,
                badgeText: 'Kurgusal Profil',
                badgeColor: Colors.blueGrey,
                onTap: () => _showLawyerDetail(context, lawyer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalDetailSheet extends StatelessWidget {
  final LegalTopic topic;

  const _LegalDetailSheet({required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    topic.icon,
                    color: const Color(0xFF512DA8),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              topic.details,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'Hatırlatma ve Tavsiyeler',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...topic.warnings.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• $w',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
