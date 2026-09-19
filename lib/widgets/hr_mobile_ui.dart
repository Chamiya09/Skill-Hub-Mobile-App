import 'package:flutter/material.dart';

const hrEmerald = Color(0xFF10B981);

/// HR-only polish: the login flow and the rest of the app retain their theme.
class HrMobileTheme extends StatelessWidget {
  const HrMobileTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: hrEmerald,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFD1FAE5),
          onPrimaryContainer: const Color(0xFF065F46),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: const Color(0x140F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFD1FAE5),
          checkmarkColor: const Color(0xFF047857),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: hrEmerald, width: 1.6),
          ),
          errorBorder: border.copyWith(
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
          errorMaxLines: 3,
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: hrEmerald,
          textColor: Color(0xFF0F172A),
          shape: Border(),
          collapsedShape: Border(),
        ),
      ),
      child: child,
    );
  }
}

/// One route contract for HR forms and details. The keyboard reduces the sheet's
/// available height so its footer stays visible while the body can scroll.
Future<T?> showHrSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 720),
    builder: (context) => AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(heightFactor: .88, child: builder(context)),
    ),
  );
}

class HrSheet extends StatelessWidget {
  const HrSheet({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.subtitle,
    this.busy = false,
  });
  final String title;
  final String? subtitle;
  final Widget body, footer;
  final bool busy;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: busy ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AbsorbPointer(absorbing: busy, child: body),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x080F172A),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: footer,
            ),
          ],
        ),
      ),
    ),
  );
}

class HrSaveButton extends StatelessWidget {
  const HrSaveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon = Icons.check_rounded,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: busy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: hrEmerald,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon),
      label: Text(busy ? 'Saving...' : label, textAlign: TextAlign.center),
    ),
  );
}

class HrCard extends StatelessWidget {
  const HrCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    shadowColor: const Color(0x180F172A),
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

/// Natural heights keep every value readable at narrow widths and large fonts.
class HrResponsiveTiles extends StatelessWidget {
  const HrResponsiveTiles({
    super.key,
    required this.children,
    this.minWidth = 165,
  });
  final List<Widget> children;
  final double minWidth;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns = constraints.maxWidth >= minWidth * 2 * scale + 12 ? 2 : 1;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(),
      );
    },
  );
}

class HrDetail extends StatelessWidget {
  const HrDetail(this.label, this.value, {super.key});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value.isEmpty ? 'Not provided' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    ),
  );
}
