import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WidgetLogo extends StatelessWidget {
  const WidgetLogo({super.key});

  @override
  Widget build(BuildContext context) {
    bool esMobil = MediaQuery.of(context).size.width < 600;
    final double size = esMobil ? 140 : 260;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF8bc6cc), // color secundario (igual que primaryColorValue)
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/logos/logo_completo.svg',
        height: esMobil ? 100 : 220,
        fit: BoxFit.contain,
      ),
    );
  }
}
