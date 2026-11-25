import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/databases/cache/cache_helper.dart';
import '../../../core/services/service_locator.dart';
import '../../account/presentation/widgets/account_ui.dart';
import '../widgets/settings_language_tile.dart';

class ChangeLanguageView extends StatefulWidget {
  const ChangeLanguageView({super.key});
  @override
  State<ChangeLanguageView> createState() => _ChangeLanguageViewState();
}

class _ChangeLanguageViewState extends State<ChangeLanguageView> {
  final cache = getIt<CacheHelper>();
  String? pending;
  Future<void> changeLanguage(String code) async {
    if (pending != null || context.locale.languageCode == code) return;
    final previous = context.locale;
    setState(() => pending = code);
    try {
      final saved = await cache.saveData(key: 'language', value: code);
      if (!saved) throw StateError('Language preference was not saved');
      if (!mounted) return;
      await context.setLocale(Locale(code));
    } catch (_) {
      try {
        await cache.saveData(key: 'language', value: previous.languageCode);
      } catch (_) {}
      if (mounted) {
        if (context.locale != previous) await context.setLocale(previous);
        if (mounted) {
          accountInfo(
            context,
            'تعذر تغيير اللغة، حاولي مرة أخرى',
            'Could not change language. Please try again.',
          );
        }
      }
    } finally {
      if (mounted) setState(() => pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = pending ?? context.locale.languageCode;
    return PopScope(
      canPop: pending == null,
      child: AccountScaffold(
        title: accountText(context, 'لغة التطبيق', 'App language'),
        body: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.badgeBg,
                ),
                child: Icon(
                  Icons.translate_rounded,
                  size: 40.sp,
                  color: AppColors.badgeTextGreen,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              accountText(
                context,
                'اختاري اللغة المناسبة ليكي',
                'Choose your preferred language',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              accountText(
                context,
                'التغيير بيتطبق على التطبيق وبيتحفظ تلقائيًا',
                'Your choice applies to the app and is saved automatically',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.subtitleGrey,
                height: 1.7,
              ),
            ),
            SizedBox(height: 26.h),
            SettingsLanguageTile(
              title: 'العربية',
              subtitle: 'Arabic',
              symbol: 'ع',
              selected: selected == 'ar',
              loading: pending == 'ar',
              onTap: pending == null ? () => changeLanguage('ar') : null,
            ),
            SizedBox(height: 12.h),
            SettingsLanguageTile(
              title: 'English',
              subtitle: 'الإنجليزية',
              symbol: 'EN',
              selected: selected == 'en',
              loading: pending == 'en',
              onTap: pending == null ? () => changeLanguage('en') : null,
            ),
          ],
        ),
      ),
    );
  }
}
