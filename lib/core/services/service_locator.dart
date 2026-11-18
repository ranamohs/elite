import '../../features/account/data/repos/addresses_repo/account_addresses_repo.dart';
import '../../features/account/data/repos/addresses_repo/local_account_addresses_repo.dart';
import '../../features/account/presentation/manager/addresses_cubit/account_addresses_cubit.dart';
import '../../features/orders/data/repos/order_details_repo.dart';
import '../../features/orders/data/repos/order_details_repo_impl.dart';
import '../../features/orders/presentation/manager/order_details_cubit.dart';
import '../../features/orders/data/repos/orders_history_repo.dart';
import '../../features/orders/data/repos/orders_history_repo_impl.dart';
import '../../features/orders/presentation/manager/orders_history_cubit.dart';
import '../../features/category_catalog/data/repos/cart_repo.dart';
import '../../features/category_catalog/data/repos/cart_repo_impl.dart';
import '../../features/category_catalog/presentation/manager/cart_cubit.dart';
import '../../features/checkout/data/repos/service_request_repo.dart';
import '../../features/checkout/data/repos/service_request_repo_impl.dart';
import '../../features/checkout/presentation/manager/service_request_cubit.dart';
import '../../features/category_catalog/data/repos/catalog_repo.dart';
import '../../features/category_catalog/data/repos/catalog_repo_impl.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/databases/cache/app_data_manager.dart';
import 'package:elite/core/databases/cache/cache_helper.dart';
import 'package:elite/core/databases/cache/secure_storage_helper.dart';
import 'package:elite/core/databases/cache/user_data_manager.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_info.dart';
import 'package:elite/features/home/data/repos/banners_repo/banners_repo.dart';
import 'package:elite/features/home/data/repos/banners_repo/banners_repo_impl.dart';
import 'package:elite/features/home/data/repos/categories_repo/categories_repo.dart';
import 'package:elite/features/home/data/repos/categories_repo/categories_repo_impl.dart';
import 'package:elite/features/home/data/repos/contracts_repo/maintenance_contracts_repo.dart';
import 'package:elite/features/home/data/repos/contracts_repo/maintenance_contracts_repo_impl.dart';
import 'package:elite/features/home/presentation/manager/banners_cubit/banners_cubit.dart';
import 'package:elite/features/home/presentation/manager/categories_cubit/categories_cubit.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contracts_cubit.dart';
import 'package:elite/features/login/data/repos/login_repo_impl.dart';
import 'package:elite/features/login/presentation/manager/login_cubit.dart';
import 'package:elite/features/register/data/repos/register_repo_impl.dart';
import 'package:elite/features/register/presentation/manager/register_cubit.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/account/data/repos/delete_account_repo/delete_account_repo_impl.dart';
import '../../features/account/data/repos/logout_repo/logout_repo_impl.dart';
import '../../features/account/data/repos/update_profile_repo/update_profile_repo_impl.dart';
import '../../features/account/presentation/manager/delete_account_cubit/delete_account_cubit.dart';
import '../../features/account/presentation/manager/logout_cubit/logout_cubit.dart';
import '../../features/account/presentation/manager/update_profile_cubit/update_profile_cubit.dart';
import '../../features/app_info/data/repos/about_us_repo/about_us_repo.dart';
import '../../features/app_info/data/repos/about_us_repo/about_us_repo_impl.dart';
import '../../features/app_info/data/repos/contact_us_repo/contact_us_repo_impl.dart';
import '../../features/app_info/data/repos/default_page_repo/default_page_repo_impl.dart';
import '../../features/app_info/data/repos/privacy_repo/privacy_repo.dart';
import '../../features/app_info/data/repos/privacy_repo/privacy_repo_impl.dart';
import '../../features/app_info/data/repos/terms_repo/terms_repo.dart';
import '../../features/app_info/data/repos/terms_repo/terms_repo_impl.dart';
import '../../features/app_info/presentation/manager/about_us_cubit/about_us_cubit.dart';
import '../../features/app_info/presentation/manager/contact_us_cubit/contact_us_cubit.dart';
import '../../features/app_info/presentation/manager/default_page_cubit/default_page_cubit.dart';
import '../../features/app_info/presentation/manager/privacy_cubit/privacy_cubit.dart';
import '../../features/app_info/presentation/manager/terms_cubit/terms_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core shops
  getIt.registerLazySingleton<CacheHelper>(() => CacheHelper());
  getIt.registerSingleton<AppDataManager>(AppDataManager(getIt<CacheHelper>()));
  getIt.registerSingleton<UserDataManager>(
    UserDataManager(getIt<CacheHelper>()),
  );
  getIt.registerLazySingleton<SecureStorageHelper>(() => SecureStorageHelper());
  getIt.registerLazySingleton<DioConsumer>(() => DioConsumer(dio: Dio()));
  getIt.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(DataConnectionChecker()),
  );
  getIt.registerLazySingleton<NetworkConnectionCubit>(
        () => NetworkConnectionCubit(getIt<NetworkInfo>()),
  );

  getIt.registerLazySingleton<CatalogRepo>(
        () => CatalogRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
    ),
  );

  getIt.registerLazySingleton<CartRepo>(
        () => CartRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<CartCubit>(() => CartCubit(repo: getIt<CartRepo>()));
  getIt.registerLazySingleton<ServiceRequestRepo>(
        () => ServiceRequestRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<ServiceRequestCubit>(
        () => ServiceRequestCubit(repo: getIt<ServiceRequestRepo>()),
  );

  getIt.registerLazySingleton<OrdersHistoryRepo>(
        () => OrdersHistoryRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<OrdersHistoryCubit>(
        () => OrdersHistoryCubit(repo: getIt<OrdersHistoryRepo>()),
  );

  getIt.registerLazySingleton<OrderDetailsRepo>(
        () => OrderDetailsRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<OrderDetailsCubit>(
        () => OrderDetailsCubit(repo: getIt<OrderDetailsRepo>()),
  );

  getIt.registerLazySingleton<AccountAddressesRepo>(
        () => LocalAccountAddressesRepo(
      cache: getIt<CacheHelper>(),
      user: getIt<UserDataManager>(),
    ),
  );
  getIt.registerFactory<AccountAddressesCubit>(
        () => AccountAddressesCubit(repo: getIt<AccountAddressesRepo>()),
  );

  // Banners dependencies
  getIt.registerLazySingleton<BannersRepo>(
        () => BannersRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<BannersCubit>(
        () => BannersCubit(bannersRepo: getIt<BannersRepo>()),
  );

  // Categories dependencies
  getIt.registerLazySingleton<CategoriesRepo>(
        () => CategoriesRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<CategoriesCubit>(
        () => CategoriesCubit(categoriesRepo: getIt<CategoriesRepo>()),
  );

  // Maintenance contracts dependencies
  getIt.registerLazySingleton<MaintenanceContractsRepo>(
        () => MaintenanceContractsRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<MaintenanceContractsCubit>(
        () => MaintenanceContractsCubit(
      maintenanceContractsRepo: getIt<MaintenanceContractsRepo>(),
    ),
  );

  // Register dependencies
  getIt.registerSingleton<RegisterRepoImpl>(
    RegisterRepoImpl(
      dioConsumer: getIt.get<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
      userDataManager: getIt<UserDataManager>(),
    ),
  );
  getIt.registerFactory<RegisterCubit>(
        () => RegisterCubit(registerRepo: getIt<RegisterRepoImpl>()),
  );

  // Login dependencies
  getIt.registerSingleton<LoginRepoImpl>(
    LoginRepoImpl(
      dioConsumer: getIt.get<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
      userDataManager: getIt<UserDataManager>(),
    ),
  );
  getIt.registerFactory<LoginCubit>(
        () => LoginCubit(loginRepo: getIt<LoginRepoImpl>()),
  );

  getIt.registerLazySingleton<AboutUsRepo>(
        () => AboutUsRepoImpl(dioConsumer: getIt<DioConsumer>()),
  );

  getIt.registerFactory<AboutUsCubit>(
        () => AboutUsCubit(repo: getIt<AboutUsRepo>()),
  );
  getIt.registerLazySingleton<TermsRepo>(
        () => TermsRepoImpl(dioConsumer: getIt<DioConsumer>()),
  );

  getIt.registerFactory<TermsCubit>(() => TermsCubit(repo: getIt<TermsRepo>()));

  getIt.registerLazySingleton<PrivacyRepo>(
        () => PrivacyRepoImpl(dioConsumer: getIt<DioConsumer>()),
  );

  getIt.registerFactory<PrivacyCubit>(
        () => PrivacyCubit(repo: getIt<PrivacyRepo>()),
  );

  getIt.registerSingleton<LogoutRepoImpl>(
    LogoutRepoImpl(
      networkCubit: getIt(),
      dioConsumer: getIt<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      userDataManager: getIt<UserDataManager>(),
    ),
  );
  getIt.registerFactory<LogoutCubit>(
        () => LogoutCubit(logoutRepo: getIt<LogoutRepoImpl>()),
  );

  getIt.registerLazySingleton<DeleteAccountRepoImpl>(
        () => DeleteAccountRepoImpl(
      dioConsumer: getIt(),
      secureStorageHelper: getIt(),
      networkCubit: getIt(),
      userDataManager: getIt(),
    ),
  );
  getIt.registerFactory(() => DeleteAccountCubit(deleteAccountRepo: getIt()));

  getIt.registerSingleton<UpdateProfileRepoImpl>(
    UpdateProfileRepoImpl(
      dioConsumer: getIt.get<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      userDataManager: getIt<UserDataManager>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<UpdateProfileCubit>(
        () => UpdateProfileCubit(updateProfileRepo: getIt<UpdateProfileRepoImpl>()),
  );

  getIt.registerLazySingleton<DefaultPageRepoImpl>(
        () => DefaultPageRepoImpl(
      dioConsumer: getIt<DioConsumer>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<DefaultPageCubit>(
        () => DefaultPageCubit(
      repo: getIt<DefaultPageRepoImpl>(),
      cacheHelper: getIt<CacheHelper>(),
    ),
  );

  getIt.registerSingleton<ContactUsRepoImpl>(
    ContactUsRepoImpl(
      dioConsumer: getIt.get<DioConsumer>(),
      secureStorageHelper: getIt<SecureStorageHelper>(),
      networkCubit: getIt<NetworkConnectionCubit>(),
    ),
  );
  getIt.registerFactory<ContactUsCubit>(
        () => ContactUsCubit(contactUsRepo: getIt<ContactUsRepoImpl>()),
  );
}
