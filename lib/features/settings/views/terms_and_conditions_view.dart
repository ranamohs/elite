import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/functions/is_arabic.dart';
import '../../../core/services/service_locator.dart';
import '../../account/presentation/widgets/account_ui.dart';
import '../../app_info/presentation/manager/terms_cubit/terms_cubit.dart';
import '../../app_info/presentation/manager/terms_cubit/terms_state.dart';
import '../widgets/settings_content_page.dart';

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<TermsCubit>()..fetchTerms(),
    child: BlocBuilder<TermsCubit, TermsState>(
      builder: (context, state) {
        final info = switch (state) {
          TermsSuccessState() => state.info,
          TermsCachedLoadingState() => state.cachedData,
          _ => null,
        };
        final ar = isArabic(context);
        final localizedName = ar ? info?.data?.name?.ar : info?.data?.name?.en;
        final fallbackName = ar ? info?.data?.name?.en : info?.data?.name?.ar;
        final title = localizedName?.trim().isNotEmpty == true
            ? localizedName!.trim()
            : fallbackName?.trim().isNotEmpty == true
            ? fallbackName!.trim()
            : accountText(context, 'الشروط والأحكام', 'Terms and conditions');
        final body = ar ? info?.data?.body?.ar : info?.data?.body?.en;
        final fallbackBody = ar ? info?.data?.body?.en : info?.data?.body?.ar;
        return SettingsContentPage(
          title: title,
          icon: Icons.description_outlined,
          content: body?.trim().isNotEmpty == true ? body : fallbackBody,
          loading: state is TermsLoadingState,
          refreshing: state is TermsCachedLoadingState,
          error: state is TermsFailureState
              ? (state.message.isNotEmpty
              ? state.message
              : accountText(
            context,
            'تعذر تحميل المحتوى',
            'Could not load content',
          ))
              : null,
          onRefresh: () => context.read<TermsCubit>().fetchTerms(),
        );
      },
    ),
  );
}
