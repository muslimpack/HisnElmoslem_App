import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/home/presentation/screens/home_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// One-page summary of what is new since the last release.
///
/// TODO: update the items in [build] every release.
class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  Future<void> _done(BuildContext context) async {
    await sl<AppSettingsRepo>().changCurrentVersion(value: sl<PackageInfo>().version);
    if (context.mounted) context.push(const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = <_Item>[
      _Item(Icons.library_add_rounded, s.whatsNewCustomTitle, s.whatsNewCustomDesc),
      _Item(Icons.cloud_download_rounded, s.whatsNewDownloadsTitle, s.whatsNewDownloadsDesc),
      _Item(Icons.touch_app_rounded, s.whatsNewTallyTitle, s.whatsNewTallyDesc),
      _Item(Icons.view_agenda_rounded, s.whatsNewViewerTitle, s.whatsNewViewerDesc),
      _Item(Icons.image_rounded, s.whatsNewShareTitle, s.whatsNewShareDesc),
      _Item(Icons.dashboard_customize_rounded, s.whatsNewHomeTitle, s.whatsNewHomeDesc),
      _Item(Icons.spellcheck_rounded, s.whatsNewContentTitle, s.whatsNewContentDesc),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  Text(
                    s.whatsNewTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appVersion(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _HeroCard(item: items.first, badge: s.whatsNewHeroBadge),
                  for (final item in items.skip(1)) _FeatureTile(item: item),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _done(context),
                  child: Text(s.start),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String title;
  final String description;
  const _Item(this.icon, this.title, this.description);
}

class _HeroCard extends StatelessWidget {
  final _Item item;
  final String badge;
  const _HeroCard({required this.item, required this.badge});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 36, color: scheme.onPrimaryContainer),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: textTheme.labelMedium?.copyWith(color: scheme.onPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final _Item item;
  const _FeatureTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: scheme.secondaryContainer,
              child: Icon(item.icon, color: scheme.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(item.description, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
