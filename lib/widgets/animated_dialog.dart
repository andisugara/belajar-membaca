import 'package:flutter/material.dart';

class AnimatedDialog {
  /// Menampilkan dialog kustom dengan animasi masuk (Bouncy Scale-in) dan keluar (Scale-out) yang sangat halus
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'AnimatedDialog',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 500),
      // Di Flutter, transitionDuration juga mengatur durasi tutup
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
      transitionBuilder: (context, animation, secondaryAnimation, childWidget) {
        // Kurva memantul saat masuk, dan mengecil halus saat keluar
        final scaleCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeInBack,
        );

        final fadeCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: fadeCurve,
          child: ScaleTransition(
            scale: scaleCurve,
            child: childWidget,
          ),
        );
      },
    );
  }
}
