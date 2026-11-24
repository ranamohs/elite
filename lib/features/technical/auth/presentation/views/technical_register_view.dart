import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/functions/is_arabic.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/state_management/user_cubit/user_cubit.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../../../home/presentation/manager/categories_cubit/categories_cubit.dart';
import '../../../auth/data/models/technical_registration_request.dart';
import '../manager/technical_registration_cubit.dart';
import '../manager/technical_registration_state.dart';
import '../widgets/technical_documents_step.dart';
import '../widgets/technical_personal_step.dart';
import '../widgets/technical_specialties_step.dart';
import '../widgets/technical_registration_progress.dart';

class TechnicalRegisterView extends StatefulWidget {
  const TechnicalRegisterView({super.key});
  @override
  State<TechnicalRegisterView> createState() => _TechnicalRegisterViewState();
}

class _TechnicalRegisterViewState extends State<TechnicalRegisterView> {
  final form = GlobalKey<FormState>();
  final fields = {
    for (final key in [
      'name',
      'phone',
      'email',
      'password',
      'password_confirmation',
      'national_id',
      'city',
      'experience',
    ])
      key: TextEditingController(),
  };
  final selectedCategories = <int>{};
  final days = <String>{};
  final areas = <String>[];
  final documents = <String, String>{};
  final scroll = ScrollController();
  late final TechnicalRegistrationCubit cubit;
  late final CategoriesCubit categories;
  int step = 0;
  bool accepted = false;
  String? picking;
  @override
  void initState() {
    super.initState();
    cubit = getIt<TechnicalRegistrationCubit>();
    categories = getIt<CategoriesCubit>()..getCategories();
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    scroll.dispose();
    cubit.close();
    categories.close();
    super.dispose();
  }

  void goStep(int value) {
    setState(() => step = value);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Future<void> pick(String key) async {
    if (picking != null) return;
    setState(() => picking = key);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (!mounted || file == null) return;
      if (![
        'jpg',
        'jpeg',
        'png',
      ].contains(file.path.toLowerCase().split('.').last) ||
          await File(file.path).length() > 5 * 1024 * 1024) {
        if (mounted)
          accountInfo(
            context,
            'اختاري JPG أو JPEG أو PNG بحد أقصى 5 ميجابايت',
            'Choose JPG, JPEG or PNG, up to 5 MB',
          );
        return;
      }
      if (mounted) setState(() => documents[key] = file.path);
    } catch (_) {
      if (mounted)
        accountInfo(
          context,
          'تعذر اختيار الصورة',
          'Could not select the photo',
        );
    } finally {
      if (mounted) setState(() => picking = null);
    }
  }

  void next() {
    if (cubit.state is TechnicalRegistrationLoading || picking != null) return;
    FocusScope.of(context).unfocus();
    if (step == 0) {
      if (form.currentState!.validate()) goStep(1);
      return;
    }
    if (step == 1) {
      if (selectedCategories.isEmpty || areas.isEmpty || days.isEmpty) {
        accountInfo(
          context,
          'اختاري تخصص واحد على الأقل ومنطقة شغل وأيام الشغل',
          'Select at least one specialty, work area and work day',
        );
        return;
      }
      goStep(2);
      return;
    }
    if (!accepted ||
        !TechnicalRegistrationRequest.documentKeys.every(
          documents.containsKey,
        )) {
      accountInfo(
        context,
        'اختاري كل المستندات المطلوبة ووافقي على الشروط',
        'Select all required documents and accept the terms',
      );
      return;
    }
    cubit.register(
      TechnicalRegistrationRequest(
        name: fields['name']!.text,
        email: fields['email']!.text,
        phone: fields['phone']!.text,
        password: fields['password']!.text,
        passwordConfirmation: fields['password_confirmation']!.text,
        nationalId: fields['national_id']!.text,
        experience: fields['experience']!.text,
        city: fields['city']!.text,
        categoryIds: selectedCategories.toList(),
        workDays: days.toList(),
        workAreas: areas,
        documents: documents,
        acceptTerms: accepted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TechnicalRegistrationCubit, TechnicalRegistrationState>(
        bloc: cubit,
        listener: (context, state) {
          if (state is TechnicalRegistrationSuccess) {
            context.read<UserCubit>().setGuestStatus(false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.result.localizedMessage(isArabic(context))),
              ),
            );
            context.go(
              state.result.access.canUseTechnicalPages
                  ? AppRouter.technicalHome
                  : AppRouter.technicalPending,
            );
          } else if (state is TechnicalRegistrationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failure.localizedMessage(isArabic(context)),
                ),
              ),
            );
            if (state.failure.fieldErrors.isNotEmpty) {
              final key = state.failure.fieldErrors.keys.first.split('.').first;
              if (fields.containsKey(key))
                goStep(0);
              else if ([
                'main_category_ids',
                'work_areas',
                'work_days',
              ].any(key.startsWith))
                goStep(1);
            }
          }
        },
        builder: (context, state) => PopScope(
          canPop: state is! TechnicalRegistrationLoading && step == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && state is! TechnicalRegistrationLoading && step > 0)
              goStep(step - 1);
          },
          child: AccountScaffold(
            title: accountText(context, 'انضم كفني', 'Join as a technician'),
            bottomBar: AccountSaveBar(
              label: step == 2
                  ? accountText(
                context,
                'إرسال الطلب للمراجعة',
                'Submit for review',
              )
                  : accountText(context, 'التالي', 'Next'),
              loading: state is TechnicalRegistrationLoading,
              onPressed: picking == null ? next : null,
            ),
            body: AbsorbPointer(
              absorbing: state is TechnicalRegistrationLoading,
              child: ListView(
                controller: scroll,
                padding: EdgeInsets.all(18.w),
                children: [
                  TechnicalRegistrationProgress(step: step),
                  SizedBox(height: 22.h),
                  if (step == 0) ...[
                    Form(
                      key: form,
                      child: TechnicalPersonalStep(fields: fields),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRouter.technicalLogin),
                      child: Text(
                        accountText(
                          context,
                          'عندك حساب فني؟ سجّل دخولك',
                          'Already a technician? Sign in',
                        ),
                      ),
                    ),
                  ],
                  if (step == 1)
                    TechnicalSpecialtiesStep(
                      categories: categories,
                      selectedCategories: selectedCategories,
                      days: days,
                      areas: areas,
                      onCategory: (id) {
                        if (!selectedCategories.contains(id) &&
                            selectedCategories.length >= 20) {
                          accountInfo(
                            context,
                            'بحد أقصى 20 تخصص',
                            'Select up to 20 specialties',
                          );
                          return;
                        }
                        setState(() {
                          if (!selectedCategories.remove(id))
                            selectedCategories.add(id);
                        });
                      },
                      onDay: (day) => setState(() {
                        if (!days.remove(day)) days.add(day);
                      }),
                      onAddArea: (area) => setState(() {
                        if (!areas.contains(area)) areas.add(area);
                      }),
                      onRemoveArea: (area) =>
                          setState(() => areas.remove(area)),
                    ),
                  if (step == 2)
                    TechnicalDocumentsStep(
                      documents: documents,
                      picking: picking,
                      accepted: accepted,
                      onPick: pick,
                      onAccept: (value) => setState(() => accepted = value),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
