import 'package:flutter/material.dart';
import '../../../login/presentation/views/login_view.dart';

class TechnicalLoginView extends StatelessWidget {
  const TechnicalLoginView({super.key});
  @override
  Widget build(BuildContext context) => const LoginView(technical: true);
}
