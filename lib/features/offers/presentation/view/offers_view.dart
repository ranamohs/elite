import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/retry_widget.dart';
import '../manager/offers_cubit.dart';
import '../manager/offers_state.dart';
import '../widgets/offer_product_card.dart';
import '../widgets/offers_empty_widget.dart';
import '../widgets/offers_loading_widget.dart';
import '../widgets/offers_tabs.dart';


class OffersView extends StatefulWidget {
  final bool isActive;

  const OffersView({super.key, this.isActive = true});

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView>
    with AutomaticKeepAliveClientMixin {
  late final OffersCubit cubit;
  bool showServices = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    cubit = getIt<OffersCubit>();
    if (widget.isActive) cubit.getOffers();
  }

  @override
  void didUpdateWidget(covariant OffersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) cubit.getOffers();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isAr = isArabic(context);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: AppStyles.styleMedium16(context).fontFamily,
          ),
        ),
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.h, bottom: 16.h),
                    child: Text(
                      AppStrings.offers.tr(),
                      style: AppStyles.styleMedium16(
                        context,
                      ).copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  BlocBuilder<OffersCubit, OffersState>(
                    bloc: cubit,
                    builder: (context, state) {
                      if (state is OffersLoading || state is OffersInitial) {
                        return const Expanded(child: OffersLoadingWidget());
                      }

                      if (state is OffersFailure) {
                        return Expanded(
                          child: Center(
                            child: RetryWidget(
                              message: state.failure.errMessage,
                              onPressed: () => cubit.getOffers(),
                            ),
                          ),
                        );
                      }

                      final model = state is OffersSuccess
                          ? state.offersModel
                          : null;
                      final products = model?.data.products.data ?? const [];
                      final services = model?.data.services.data ?? const [];
                      final current = showServices ? services : products;

                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OffersTabs(
                              showServices: showServices,
                              productsCount: products.length,
                              servicesCount: services.length,
                              onChanged: (value) =>
                                  setState(() => showServices = value),
                            ),
                            SizedBox(height: 14.h),
                            Expanded(
                              child: RefreshIndicator(
                                color: AppColors.homeHeaderGreen,
                                onRefresh: () async => cubit.getOffers(),
                                child: current.isEmpty
                                    ? ListView(
                                  physics:
                                  const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.only(top: 40.h),
                                  children: [
                                    OffersEmptyWidget(
                                      onRefresh: () => cubit.getOffers(),
                                    ),
                                  ],
                                )
                                    : ListView.builder(
                                  physics:
                                  const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: EdgeInsets.only(bottom: 24.h),
                                  itemCount: current.length,
                                  itemBuilder: (context, index) {
                                    return OfferProductCard(
                                      item: current[index],
                                      isArabic: isAr,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
