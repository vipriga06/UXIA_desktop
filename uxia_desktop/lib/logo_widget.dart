import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WidgetLogo extends StatelessWidget {
  const WidgetLogo({super.key});

  @override
  Widget build(BuildContext context) {
    bool esMobil = MediaQuery.of(context).size.width < 600;

    return SvgPicture.asset(
      'assets/logos/logo_completo.svg',
      height: esMobil ? 100 : 220,
      fit: BoxFit.contain,
    );
  }
}
