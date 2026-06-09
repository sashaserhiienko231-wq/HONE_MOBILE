import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/app/providers/locale_provider.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/l10n/app_localizations.dart';

class LanguageSettingsSection extends ConsumerWidget {
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.languageSystem, style: const TextStyle(color: Colors.white)),
                trailing: current == null
                    ? const Icon(Icons.check, color: AppTheme.neonGreen)
                    : null,
                onTap: () => ref.read(localeProvider.notifier).setLocale(null),
              ),
              ...LocaleNotifier.supported.map(
                (locale) => ListTile(
                  title: Text(
                    locale.languageCode.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: current?.languageCode == locale.languageCode
                      ? const Icon(Icons.check, color: AppTheme.neonGreen)
                      : null,
                  onTap: () => ref.read(localeProvider.notifier).setLocale(locale),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
