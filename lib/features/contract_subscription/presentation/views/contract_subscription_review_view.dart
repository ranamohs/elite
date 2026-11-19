import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/services/service_locator.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../../home/data/models/contracts_models/maintenance_contracts_model.dart';
import '../../../home/presentation/widgets/contract_formatters.dart';
import '../../data/models/contract_subscription_request.dart';
import '../manager/contract_subscription_cubit.dart';
import '../manager/contract_subscription_state.dart';
import '../widgets/subscription_contract_card.dart';
import '../widgets/subscription_step_indicator.dart';

class ContractSubscriptionReviewView extends StatefulWidget {
  final MaintenanceContract contract;
  final ContractSubscriptionRequest request;
  const ContractSubscriptionReviewView({
    super.key,
    required this.contract,
    required this.request,
  });
  @override
  State<ContractSubscriptionReviewView> createState() =>
      _ContractSubscriptionReviewViewState();
}

class _ContractSubscriptionReviewViewState
    extends State<ContractSubscriptionReviewView> {
  late final ContractSubscriptionCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = getIt<ContractSubscriptionCubit>();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) => BlocConsumer<ContractSubscriptionCubit, ContractSubscriptionState>(
    bloc: cubit,
    listener: (context, state) {
      if (state is ContractSubscriptionSuccess)
        Navigator.of(context).pop(state.model);
      if (state is ContractSubscriptionNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.result.localizedMessage(isArabic(context))),
          ),
        );
      }
      if (state is ContractSubscriptionFailure)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure.errMessage)));
    },
    builder: (context, state) => PopScope(
      canPop: state is! ContractSubscriptionLoading,
      child: AccountScaffold(
        title: accountText(
          context,
          'المراجعة وتأكيد الاشتراك',
          'Review and confirm subscription',
        ),
        bottomBar: AccountSaveBar(
          loading: state is ContractSubscriptionLoading,
          label: state is ContractSubscriptionNotice
              ? accountText(context, 'الرجوع للرئيسية', 'Back to home')
              : accountText(
            context,
            'تأكيد الاشتراك · ${contractPriceText(widget.contract)}',
            'Confirm subscription · ${contractPriceText(widget.contract)}',
          ),
          onPressed: state is ContractSubscriptionNotice
              ? () => context.go(AppRouter.homePage)
              : () => cubit.subscribe(widget.request),
        ),
        body: ListView(
          padding: EdgeInsets.all(18.w),
          children: [
            if (state is ContractSubscriptionNotice) ...[
              AccountCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        state.result.localizedMessage(isArabic(context)),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            const SubscriptionStepIndicator(step: 2),
            SizedBox(height: 18.h),
            SubscriptionContractCard(contract: widget.contract),
            SizedBox(height: 16.h),
            AccountCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    accountText(
                      context,
                      'عنوان الاشتراك',
                      'Subscription address',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    widget.request.address,
                    style: TextStyle(fontSize: 12.sp, height: 1.7),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            AccountCard(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  File(widget.request.imagePath),
                  height: 145.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              accountText(
                context,
                'التأكيد بيرسل طلب الاشتراك. مفيش خصم مبلغ من خلال الخطوة دي.',
                'Confirmation submits your subscription. No payment is collected in this step.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}
