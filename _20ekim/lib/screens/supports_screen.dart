import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../widgets/info_card.dart';

/// Destek, Teşvik ve Yatırımcılar Ekranı
class SupportsScreen extends StatelessWidget {
  const SupportsScreen({super.key});

  void _showInstitutionDetail(
      BuildContext context, SupportInstitution institution) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SupportDetailSheet(institution: institution),
    );
  }

  void _showInvestorTopicDetail(
      BuildContext context, InvestorTopic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvestorTopicDetailSheet(topic: topic),
    );
  }

  void _showInvestorDetail(
      BuildContext context, InvestorProfile investor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvestorDetailSheet(investor: investor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Destek, Teşvik ve Yatırımcılar'),
          bottom: TabBar(
            indicatorColor: const Color(0xFF00897B),
            labelColor: const Color(0xFF00897B),
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(
                icon: Icon(Icons.account_balance_outlined),
                text: 'Devlet Destekleri',
              ),
              Tab(
                icon: Icon(Icons.trending_up_outlined),
                text: 'Yatırımcılar',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // 1. Sekme: Devlet Destekleri
              _buildGovernmentSupportsTab(context),

              // 2. Sekme: Yatırımcılar
              _buildInvestorsTab(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Sekme: Devlet Destekleri
  Widget _buildGovernmentSupportsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const NoticeBanner(
          message:
              'Hibe tutarları, başvuru şartları ve takvimler dönemsel olarak değişebilir. Başvurular doğrudan kurumların resmi sitelerinden yapılır; uygulama içinden başvuru alınmamaktadır.',
          icon: Icons.info_outline,
          color: Color(0xFF00796B),
        ),
        ...SampleData.supports.map(
          (inst) => InfoCard(
            title: '${inst.shortName} Destekleri',
            description: inst.description,
            icon: inst.icon,
            iconColor: const Color(0xFF00897B),
            badgeText: 'Resmi Kurum',
            badgeColor: const Color(0xFF00796B),
            onTap: () => _showInstitutionDetail(context, inst),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .secondaryContainer
              .withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF00796B).withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined,
                        color: Color(0xFF00796B)),
                    const SizedBox(width: 8),
                    Text(
                      'Hibe Başvuru İpucu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu desteklerine başvururken iş fikrinizin yenilikçi yönünü, pazar potansiyelini ve ekibinizin yetkinliklerini net ve sayısallaştırılmış verilerle açıklamanız değerlendirme puanınızı artırır.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Sekme: Yatırımcılar
  Widget _buildInvestorsTab(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const Key('investors_tab_list'),
      padding: const EdgeInsets.all(16.0),
      children: [
        const NoticeBanner(
          message:
              'ÖNEMLİ DEMO UYARISI: Bu sekmedeki yatırımcı profilleri ve içerikler tamamen kurgusal eğitim örnekleridir. Gerçek kişi değillerdir; gerçek yatırım talebi, eşleştirme veya para transferi sunulmaz.',
          icon: Icons.shield_outlined,
          color: Color(0xFFE65100),
        ),
        Text(
          'Yatırım Dünyası & Temel Kavramlar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Melek yatırım, risk sermayesi ve sunum hazırlığı hakkında temel bilgiler.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ...SampleData.investorTopics.map(
          (topic) => InfoCard(
            title: topic.title,
            description: topic.summary,
            icon: topic.icon,
            iconColor: const Color(0xFF0288D1),
            badgeText: 'Yatırım Rehberi',
            badgeColor: const Color(0xFF0277BD),
            onTap: () => _showInvestorTopicDetail(context, topic),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Kurgusal Demo Yatırımcı Profilleri',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Farklı aşamalara ve ilgi alanlarına odaklanan 3 örnek demo yatırımcı.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ...SampleData.investors.map(
          (investor) => InfoCard(
            title: investor.name,
            description:
                '${investor.investmentStage} • ${investor.interestField}',
            icon: Icons.person_pin_outlined,
            iconColor: investor.badgeColor,
            badgeText: 'Kurgusal Demo',
            badgeColor: investor.badgeColor,
            onTap: () => _showInvestorDetail(context, investor),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 22,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Yatırımcı sermayesi şirketinizi hızlandırabilir; ancak devlet hibeleri ilk aşamada hisse kaybetmeden ilerlemenizi sağlar. İkisini stratejik sırayla değerlendirin.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kurum Detay Alt Açılır Paneli
class _SupportDetailSheet extends StatelessWidget {
  final SupportInstitution institution;

  const _SupportDetailSheet({required this.institution});

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
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    institution.icon,
                    color: const Color(0xFF00796B),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        institution.shortName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        institution.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Hedef Kitle:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00796B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              institution.targetAudience,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Örnek Destek Programları:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00796B),
              ),
            ),
            const SizedBox(height: 6),
            ...institution.samplePrograms.map(
              (prog) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF00796B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prog,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.language, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resmi Web Adresi:',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          institution.officialWebsite,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ ${institution.disclaimer}',
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
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

/// Yatırımcılık Konusu Detay Alt Paneli
class _InvestorTopicDetailSheet extends StatelessWidget {
  final InvestorTopic topic;

  const _InvestorTopicDetailSheet({required this.topic});

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
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    topic.icon,
                    color: const Color(0xFF0288D1),
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
            Text(
              'Önemli Noktalar:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0288D1),
              ),
            ),
            const SizedBox(height: 8),
            ...topic.keyPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Color(0xFF0288D1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Anladım'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo Yatırımcı Profili Detay Alt Paneli
class _InvestorDetailSheet extends StatelessWidget {
  final InvestorProfile investor;

  const _InvestorDetailSheet({required this.investor});

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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: investor.badgeColor.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.trending_up,
                    size: 30,
                    color: investor.badgeColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          investor.demoTag,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC77800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        investor.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        investor.investmentStage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Text(
              'İlgi ve Odak Alanları',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: investor.badgeColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              investor.interestField,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Yatırımcı Yaklaşımı & Açıklama',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: investor.badgeColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              investor.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: investor.badgeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: investor.badgeColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        size: 20,
                        color: investor.badgeColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Yatırımcı Tavsiyesi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: investor.badgeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    investor.advice,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface,
                      height: 1.35,
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
