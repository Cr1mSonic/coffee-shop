import 'package:flutter/material.dart';

class ResponsiveFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.padding,
  });

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 40;
    if (isTablet(context)) return 28;
    return 16;
  }

  static double titleSize(BuildContext context) {
    if (isDesktop(context)) return 34;
    if (isTablet(context)) return 30;
    return 24;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: horizontalPadding(context),
                vertical: 20,
              ),
          child: child,
        ),
      ),
    );
  }
}
