import 'package:cached_network_image/cached_network_image.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/features/home/data/models/banners_models/banners_model.dart';
import 'package:elite/features/home/presentation/manager/banners_cubit/banners_cubit.dart';
import 'package:elite/features/home/presentation/manager/banners_cubit/banners_state.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_router.dart';

class HomeBannersSection extends StatefulWidget {
  final List<Data>? banners;
  final void Function(int index)? onBannerTap;

  const HomeBannersSection({
    super.key,
    this.banners,
    this.onBannerTap,
  });

  @override
  State<HomeBannersSection> createState() => _HomeBannersSectionState();
}

class _HomeBannersSectionState extends State<HomeBannersSection> {
  int _bannerIndex = 0;
  final PageController _bannerController = PageController(viewportFraction: 0.9);
  Timer? _autoPlayTimer;
  int _currentBannersCount = 0;

  @override
  void dispose() {
    _stopAutoPlay();
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoPlay(int count) {
    _stopAutoPlay();
    if (count <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final nextIndex = (_bannerIndex + 1) % count;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _handleBannerTap(Data? banner, int index) async {
    if (widget.onBannerTap != null) {
      widget.onBannerTap!(index);
      return;
    }

    final url = banner?.url;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (mounted) {
      GoRouter.of(context).push(AppRouter.allCategoriesView);
    }
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        SizedBox(
          height: 145.h,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: 1,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Shimmer.fromColors(
                  baseColor: AppColors.loadingEffectColor,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 6.h,
              width: 18.w,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners != null) {
      return _buildBannersList(widget.banners!);
    }

    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        if (state is BannersLoading) {
          return _buildShimmerLoading();
        }

        if (state is BannersSuccess) {
          final bannersList = state.bannersModel.data ?? [];
          if (bannersList.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildBannersList(bannersList);
        }

        if (state is BannersFailure) {
          return const SizedBox.shrink();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBannersList(List<Data> bannersList) {
    if (bannersList.isEmpty) {
      _stopAutoPlay();
      return const SizedBox.shrink();
    }

    final count = bannersList.length;
    if (_currentBannersCount != count) {
      _currentBannersCount = count;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startAutoPlay(count);
        }
      });
    }

    return Column(
      children: [
        SizedBox(
          height: 145.h,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _bannerIndex = index;
              });
            },
            itemCount: count,
            itemBuilder: (context, index) {
              final banner = bannersList[index];
              final imageUrl = banner.image;
              final isAr = isArabic(context);
              final bannerName = (isAr
                  ? banner.name?.ar
                  : banner.name?.en) ??
                  banner.name?.ar ??
                  banner.name?.en ??
                  '';

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: GestureDetector(
                  onTap: () => _handleBannerTap(banner, index),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      color: Colors.grey.shade200,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppColors.loadingEffectColor,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildFallbackBannerContent(bannerName, banner, index),
                          )
                        else
                          _buildFallbackBannerContent(bannerName, banner, index),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 10.h),
        if (count > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final isActive = _bannerIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                height: 6.h,
                width: isActive ? 18.w : 6.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.homeHeaderGreen
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildFallbackBannerContent(String bannerName, Data? banner, int index) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE0EDF3),
            Color(0xFF8AA38B),
            Color(0xFF384A33),
          ],
          stops: [0.0, 0.45, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10.w,
            top: 10.h,
            bottom: 10.h,
            width: 80.w,
            child: Image.asset(
              AppAssets.appLogo,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(85.w, 4.h, 14.w, 4.h),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bannerName.isNotEmpty
                          ? bannerName
                          : 'صيانة التكييف قبل الصيف',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'خصم 20% بكود SUMMER20',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    GestureDetector(
                      onTap: () => _handleBannerTap(banner, index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.homeHeaderGreen,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          'احجز دلوقتي',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
