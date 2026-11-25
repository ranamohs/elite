import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/databases/cache/cache_helper.dart';
import '../../../core/functions/is_arabic.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/service_locator.dart';
import '../../account/presentation/widgets/account_actions.dart';
import '../../account/presentation/widgets/account_ui.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final cache = getIt<CacheHelper>();
  late final Map<String, bool> preferences;
  final busy = <String>{};
  @override
  void initState() {
    super.initState();
    preferences = {
      for (final key in ['orders', 'offers', 'sms'])
        key:
        cache.getData(key: 'notification_preference.$key') as bool? ??
            key != 'sms',
    };
  }

  Future<void> toggle(String key, bool value) async {
    if (busy.contains(key)) return;
    final old = preferences[key]!;
    setState(() {
      busy.add(key);
      preferences[key] = value;
    });
    try {
      if (!await cache.saveData(
        key: 'notification_preference.$key',
        value: value,
      )) {
        throw StateError('Preference save failed');
      }
    } catch (_) {
      if (mounted) {
        setState(() => preferences[key] = old);
        accountInfo(
          context,
          'تعذر حفظ الاختيار، حاولي مرة أخرى',
          'Could not save your preference. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy.remove(key));
    }
  }

  Widget section(String title) => Padding(
    padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
    child: Text(
      title,
      style: TextStyle(color: AppColors.subtitleGrey, fontSize: 12.sp),
    ),
  );
  Widget notification(String key, String title) => Padding(
    padding: EdgeInsetsDirectional.only(start: 12.w),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: TextStyle(fontSize: 12.sp)),
        ),
        Switch(
          value: preferences[key]!,
          onChanged: busy.contains(key) ? null : (value) => toggle(key, value),
          activeTrackColor: AppColors.primaryColor,
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'الإعدادات', 'Settings'),
    body: ListView(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
      children: [
        section(accountText(context, 'اللغة', 'Language')),
        AccountCard(
          padding: EdgeInsets.zero,
          child: AccountMenuTile(
            icon: Icons.language,
            title: accountText(context, 'لغة التطبيق', 'App language'),
            onTap: () => context.push(AppRouter.changeLanguageView),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic(context) ? 'العربية' : 'English',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.badgeTextGreen,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12.sp),
              ],
            ),
          ),
        ),
        section(accountText(context, 'عام', 'General')),
        AccountCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AccountMenuTile(
                icon: Icons.lock_outline,
                title: accountText(context, 'سياسة الخصوصية', 'Privacy policy'),
                onTap: () => context.push(AppRouter.privacyPolicyView),
              ),
              const Divider(height: 1),
              AccountMenuTile(
                icon: Icons.info_outline,
                title: accountText(context, 'عن التطبيق', 'About the app'),
                onTap: () => context.push(AppRouter.aboutUsView),
              ),
              const Divider(height: 1),
              // AccountMenuTile(
              //   icon: Icons.star_outline,
              //   title: accountText(context, 'قيّم التطبيق', 'Rate the app'),
              //   onTap: () => accountInfo(
              //     context,
              //     'رابط التطبيق على المتجر مش متاح حاليًا',
              //     'The app store link is not available yet',
              //   ),
              // ),
              // const Divider(height: 1),
              AccountMenuTile(
                icon: Icons.delete_outline,
                title: accountText(context, 'حذف الحساب', 'Delete account'),
                destructive: true,
                onTap: () => showAccountDeletion(context),
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
