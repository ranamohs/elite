import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/retry_widget.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../manager/assigned_requests_cubit.dart';
import '../manager/assigned_requests_state.dart';
import '../views/assigned_request_details_view.dart';
import 'assigned_request_card.dart';

class AssignedRequestsContent extends StatelessWidget {
  final AssignedRequestsCubit cubit;
  final bool home;
  const AssignedRequestsContent({
    super.key,
    required this.cubit,
    this.home = false,
  });
  Future<void> respond(BuildContext context, int id, bool accept) async {
    final error = await cubit.respond(id: id, accept: accept);
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ??
                accountText(
                  context,
                  accept ? 'تم قبول الطلب' : 'تم رفض الطلب',
                  accept ? 'Request accepted' : 'Request declined',
                ),
          ),
        ),
      );
  }

  @override
  Widget build(
      BuildContext context,
      ) => BlocBuilder<AssignedRequestsCubit, AssignedRequestsState>(
    bloc: cubit,
    builder: (context, state) {
      if (state is AssignedRequestsLoading || state is AssignedRequestsInitial)
        return Shimmer.fromColors(
          baseColor: AppColors.loadingEffectColor,
          highlightColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.all(18.w),
            children: List.generate(
              3,
                  (_) => Container(
                height: 145.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        );
      final model = assignedRequestsData(state);
      if (model == null)
        return Center(
          child: RetryWidget(
            message: state is AssignedRequestsFailure
                ? state.failure.errMessage
                : accountText(
              context,
              'تعذر تحميل الطلبات',
              'Could not load requests',
            ),
            onPressed: () => cubit.load(),
          ),
        );
      final current = model.requests.where((e) => !e.isClosed).toList();
      final closed = model.requests.where((e) => e.isClosed).toList();
      final items = home ? [...current, ...closed] : model.requests;
      return RefreshIndicator(
        onRefresh: () => cubit.load(),
        color: AppColors.primaryColor,
        child: ListView(
          padding: EdgeInsets.all(18.w),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              accountText(
                context,
                home ? 'الطلبات المسندة إليك' : 'كل الطلبات المسندة',
                home ? 'Assigned to you' : 'All assigned requests',
              ),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14.h),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 52.sp,
                      color: AppColors.badgeTextGreen,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      accountText(
                        context,
                        'مفيش طلبات مسندة ليك حاليًا',
                        'No requests assigned to you yet',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ...items.map(
                  (request) => AssignedRequestCard(
                request: request,
                prominent: !request.isClosed,
                busy:
                state is AssignedRequestsResponding &&
                    state.id == request.id,
                onAccept: state is AssignedRequestsResponding
                    ? null
                    : () => respond(context, request.id, true),
                onReject: state is AssignedRequestsResponding
                    ? null
                    : () => respond(context, request.id, false),
                onDetails: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AssignedRequestDetailsView(request: request),
                  ),
                ),
              ),
            ),
            if (state is AssignedRequestsFailure)
              RetryWidget(
                message: state.failure.errMessage,
                onPressed: () => cubit.load(more: state.more),
              ),
            if (model.hasMore && state is! AssignedRequestsFailure)
              Center(
                child: state is AssignedRequestsLoadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                  onPressed: () => cubit.load(more: true),
                  child: Text(
                    accountText(context, 'تحميل المزيد', 'Load more'),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
