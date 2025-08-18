import 'package:flutter/material.dart';

import '../../../core/presentation/ui_components/ui_components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onProceed});

  final VoidCallback onProceed;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      widget.onProceed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SvgIcon('assets/icons/zamry_logo.svg', width: 68)));
  }
}
