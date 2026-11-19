import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/routes/app_router.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../data/models/contract_subscription_model.dart';
import '../widgets/subscription_dates_card.dart';
import 'subscription_details_view.dart';

class ContractSubscriptionSuccessView extends StatelessWidget {
  final ContractSubscriptionModel subscription;
  const ContractSubscriptionSuccessView({
    super.key,
    required this.subscription,
  });
  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    final message = ar ? subscription.message.ar : subscription.message.en;
    return AccountScaffold(
      title: accountText(context, 'الاشتراك', 'Subscription'),
      bottomBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SubscriptionDetailsView(subscription: subscription),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text(
                    accountText(
                      context,
                      'تفاصيل عقدي',
                      'My subscription details',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRouter.homePage),
                  child: Text(
                    accountText(context, 'الرجوع للرئيسية', 'Back to home'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(18.w),
        children: [
          SizedBox(height: 30.h),
          CircleAvatar(
            radius: 34.r,
            backgroundColor: AppColors.badgeBg,
            child: Icon(
              Icons.check_rounded,
              color: AppColors.primaryColor,
              size: 42.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            message.isEmpty
                ? accountText(
              context,
              'تم الاشتراك بنجاح',
              'Subscribed successfully',
            )
                : message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24.h),
          SubscriptionDatesCard(subscription: subscription),
        ],
      ),
    );
  }
}
