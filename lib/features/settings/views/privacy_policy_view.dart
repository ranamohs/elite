import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/functions/is_arabic.dart';
import '../../../core/services/service_locator.dart';
import '../../account/presentation/widgets/account_ui.dart';
import '../../app_info/presentation/manager/privacy_cubit/privacy_cubit.dart';
import '../../app_info/presentation/manager/privacy_cubit/privacy_state.dart';
import '../widgets/settings_content_page.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PrivacyCubit>()..fetchPrivacy(),
    child: BlocBuilder<PrivacyCubit, PrivacyState>(
      builder: (context, state) {
        final info = switch (state) {
          PrivacySuccessState() => state.info,
          PrivacyCachedLoadingState() => state.cachedData,
          _ => null,
        };
        final ar = isArabic(context);
        final localizedName = ar ? info?.data?.name?.ar : info?.data?.name?.en;
        final fallbackName = ar ? info?.data?.name?.en : info?.data?.name?.ar;
        final title = localizedName?.trim().isNotEmpty == true
            ? localizedName!.trim()
            : fallbackName?.trim().isNotEmpty == true
            ? fallbackName!.trim()
            : accountText(context, 'سياسة الخصوصية', 'Privacy policy');
        final body = ar ? info?.data?.body?.ar : info?.data?.body?.en;
        final fallbackBody = ar ? info?.data?.body?.en : info?.data?.body?.ar;
        return SettingsContentPage(
          title: title,
          icon: Icons.lock_outline,
          content: body?.trim().isNotEmpty == true ? body : fallbackBody,
          loading: state is PrivacyLoadingState,
          refreshing: state is PrivacyCachedLoadingState,
          error: state is PrivacyFailureState
              ? (state.message.isNotEmpty
              ? state.message
              : accountText(
            context,
            'تعذر تحميل المحتوى',
            'Could not load content',
          ))
              : null,
          onRefresh: () => context.read<PrivacyCubit>().fetchPrivacy(),
        );
      },
    ),
  );
}
