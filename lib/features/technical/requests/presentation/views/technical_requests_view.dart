import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/services/service_locator.dart';
import 'package:elite/features/account/presentation/widgets/account_ui.dart';
import '../../data/models/technical_request_history.dart';
import '../../data/repos/assigned_requests_repo.dart';
import '../manager/assigned_requests/assigned_requests_cubit.dart';
import '../manager/history/technical_request_history_cubit.dart';
import '../widgets/technical_history_card.dart';
import 'assigned_request_details_view.dart';
import 'technical_work_in_progress_view.dart';

class TechnicalRequestsView extends StatefulWidget {
  final AssignedRequestsCubit cubit;
  final bool isActive;
  const TechnicalRequestsView({
    super.key,
    required this.cubit,
    this.isActive = true,
  });
  @override
  State<TechnicalRequestsView> createState() => _TechnicalRequestsViewState();
}

class _TechnicalRequestsViewState extends State<TechnicalRequestsView> {
  late final TechnicalRequestHistoryCubit history;
  TechnicalRequestTab selected = TechnicalRequestTab.upcoming;
  @override
  void initState() {
    super.initState();
    history = TechnicalRequestHistoryCubit(getIt<AssignedRequestsRepo>());
    if (widget.isActive) history.refresh();
  }

  @override
  void didUpdateWidget(covariant TechnicalRequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) history.refresh();
  }

  @override
  void dispose() {
    history.close();
    super.dispose();
  }

  Future<void> open(TechnicalHistoryEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => entry.started || entry.unpaid
            ? TechnicalWorkInProgressView(
          request: entry.request,
          awaitingPayment: entry.unpaid,
        )
            : AssignedRequestDetailsView(request: entry.request),
      ),
    );
    if (mounted) {
      history.refresh();
      widget.cubit.load();
    }
  }

  String group(TechnicalHistoryEntry entry) {
    final date = entry.appointmentDate;
    if (date == null)
      return accountText(context, 'مواعيد أخرى', 'Other appointments');
    final now = DateTime.now(),
        today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
    if (date == today) return accountText(context, 'النهارده', 'Today');
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date == tomorrow) return accountText(context, 'بكرة', 'Tomorrow');
    return '${date.day}/${date.month}/${date.year}';
  }

  String sourceName(TechnicalRequestSource source) => switch (source) {
    TechnicalRequestSource.received => accountText(
      context,
      'الطلبات المستلمة',
      'Received requests',
    ),
    TechnicalRequestSource.started => accountText(
      context,
      'الطلبات الجاري تنفيذها',
      'Started requests',
    ),
    TechnicalRequestSource.unpaid => accountText(
      context,
      'المكتملة غير المدفوعة',
      'Completed unpaid requests',
    ),
    TechnicalRequestSource.all => accountText(
      context,
      'كل الطلبات',
      'All orders',
    ),
  };
  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'طلباتي', 'My requests'),
    embedded: true,
    body: BlocBuilder<TechnicalRequestHistoryCubit, TechnicalRequestHistoryState>(
      bloc: history,
      builder: (context, state) {
        final all = mergeTechnicalHistory(state.pages),
            entries = all.where((e) => e.tab == selected).toList();
        final groups = <String, List<TechnicalHistoryEntry>>{};
        for (final entry in entries) {
          groups.putIfAbsent(group(entry), () => []).add(entry);
        }
        final hasMore = state.pages.values.any((page) => page.hasMore);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 12.h),
              child: Row(
                children: [
                  for (final tab in TechnicalRequestTab.values) ...[
                    if (tab != TechnicalRequestTab.values.first)
                      SizedBox(width: 6.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => selected = tab),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 4.w,
                          ),
                          backgroundColor: selected == tab
                              ? AppColors.primaryColor
                              : Colors.white,
                          foregroundColor: selected == tab
                              ? Colors.white
                              : Colors.black87,
                          side: BorderSide(
                            color: selected == tab
                                ? AppColors.primaryColor
                                : AppColors.unselectedBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          '${switch (tab) {
                            TechnicalRequestTab.upcoming => accountText(context, 'القادمة', 'Upcoming'),
                            TechnicalRequestTab.completed => accountText(context, 'المكتملة', 'Completed'),
                            TechnicalRequestTab.canceled => accountText(context, 'الملغية', 'Canceled'),
                          }}${selected == tab && state.pages.isNotEmpty ? ' (${entries.length}${hasMore ? '+' : ''})' : ''}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: history.refresh,
                color: AppColors.primaryColor,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
                  children: [
                    if (state.pages.isEmpty && state.loading.isNotEmpty)
                      ...List.generate(
                        3,
                            (_) => Container(
                          height: 135.h,
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    if (state.pages.isNotEmpty && state.loading.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(),
                      ),
                    for (final group in groups.entries) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                        child: Text(
                          group.key,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.subtitleGrey,
                          ),
                        ),
                      ),
                      ...group.value.map(
                            (entry) => TechnicalHistoryCard(
                          entry: entry,
                          onDetails: () => open(entry),
                        ),
                      ),
                    ],
                    if (entries.isEmpty &&
                        state.loading.isEmpty &&
                        state.errors.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 65.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 52.sp,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              accountText(
                                context,
                                'مفيش طلبات في القسم ده حاليًا',
                                'No requests in this section yet',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    for (final error in state.errors.entries)
                      AccountCard(
                        child: Column(
                          children: [
                            Text(
                              sourceName(error.key),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(error.value, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: state.loading.contains(error.key)
                                  ? null
                                  : () => history.load(error.key),
                              child: Text(
                                accountText(context, 'إعادة المحاولة', 'Retry'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    for (final page in state.pages.entries)
                      if (page.value.hasMore)
                        TextButton(
                          onPressed: state.loading.contains(page.key)
                              ? null
                              : () => history.load(page.key, more: true),
                          child: Text(
                            '${accountText(context, 'تحميل المزيد', 'Load more')} · ${sourceName(page.key)}',
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
