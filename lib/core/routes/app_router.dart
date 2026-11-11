import 'package:elite/features/home/presentation/views/all_categories_view.dart';
import 'package:elite/features/register/presentation/views/register_view.dart';
import 'package:elite/features/splash/presentation/views/welcome_view.dart';
import 'package:elite/features/splash/presentation/views/splash_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/views/home_page.dart';
import '../../features/login/presentation/views/login_view.dart';
import '../../features/services/presentation/views/category_services_view.dart';
import '../../features/settings/views/change_language_view.dart';
import '../../features/account/presentation/views/update_profile_view.dart';
import '../../features/settings/views/about_us_view.dart';
import '../../features/app_info/presentation/views/contact_us_view.dart';
import '../../features/settings/views/privacy_policy_view.dart';
import '../../features/register/presentation/manager/register_cubit.dart';
import '../../features/settings/views/terms_and_conditions_view.dart';

import '../../features/app_info/presentation/views/help_and_support_view.dart';
import '../../features/sub_category/presentation/views/sub_category_services_view.dart';
import '../services/service_locator.dart';

abstract class AppRouter {
  static const welcomeView = '/welcomeView';
  static const loginView = '/loginView';
  static const registerView = '/registerView';
  static const introViewWithButton = '/introViewWithButton';
  static const homePage = '/homePage';
  static const categoryDetailsView = '/categoryDetailsView';
  static const subCategoryServicesView = '/subCategoryServicesView';
  static const serviceDetailsView = '/serviceDetailsView';
  static const updateProfileView = '/updateProfileView';
  static const helpAndSupportView = '/helpAndSupportView';
  static const contactUsView = '/contactUsView';
  static const aboutUsView = '/aboutUsView';
  static const termsAndConditionsView = '/termsAndConditionsView';
  static const privacyPolicyView = '/privacyPolicyView';
  static const changeLanguageView = '/changeLanguageView';
  static const allCategoriesView = '/allCategoriesView';
  static const allRecentShopsView = '/allRecentShopsView';
  static const rating = '/rating';
  static const wishlistView = '/wishlistView';
  static const searchView = '/searchView';

  //////////////////

  //FiXIT

  static const introView = '/introView';


  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: welcomeView,builder: (context, state) => const WelcomeView()),
      GoRoute(path: loginView, builder: (context, state) => LoginView()),
      GoRoute(path: allCategoriesView, builder: (context, state) => AllCategoriesView()),

      GoRoute(path: registerView, builder: (context, state) => BlocProvider(
        create: (context) => getIt<RegisterCubit>(),
        child:  RegisterView(),
      )),
      GoRoute(path: homePage, builder: (context, state) =>  AppLayout()),
      GoRoute(
          path: categoryDetailsView,
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            final int categoryId = extras['categoryId'] as int;
            final String arName = extras['arName'] as String;
            final String enName = extras['enName'] as String;
            return CategoryServicesView(
              categoryId: categoryId,
              categoryArName: arName,
              categoryEnName: enName,
            );
          }),
      GoRoute(
          path: subCategoryServicesView,
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            final int subCategoryId = extras['subCategoryId'] as int;
            final String subCategoryArName = extras['subCategoryArName'] as String;
            final String subCategoryEnName = extras['subCategoryEnName'] as String;
            final String? mainCategoryArName = extras['mainCategoryArName'] as String?;
            final String? mainCategoryEnName = extras['mainCategoryEnName'] as String?;
            return SubCategoryServicesView(
              subCategoryId: subCategoryId,
              subCategoryArName: subCategoryArName,
              subCategoryEnName: subCategoryEnName,
              mainCategoryArName: mainCategoryArName,
              mainCategoryEnName: mainCategoryEnName,
            );
          }),

      GoRoute(path: contactUsView, builder: (context, state) => const ContactUsView()),
      GoRoute(path: helpAndSupportView, builder: (context, state) => const HelpAndSupportView()),
      GoRoute(path: aboutUsView, builder: (context, state) => const AboutUsView()),
      GoRoute(path: termsAndConditionsView, builder: (context, state) => const TermsAndConditionsView()),
      GoRoute(path: privacyPolicyView, builder: (context, state) => const PrivacyPolicyView()),
      GoRoute(path: changeLanguageView, builder: (context, state) => const ChangeLanguageView()),
      GoRoute(path: updateProfileView, builder: (context, state) => const UpdateProfileView()),

    ],
  );
}
