import 'package:flutter/material.dart';

import '../screens/candidate/company_details_screen.dart';

class CompanyLogoButton extends StatelessWidget {
  const CompanyLogoButton({
    super.key,
    required this.companyIdentifier,
    required this.initials,
    this.logoUrl,
    this.size = 46,
    this.backgroundColor = const Color(0xFFECFDF5),
  });

  final String companyIdentifier;
  final String initials;
  final String? logoUrl;
  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final identifier = companyIdentifier.trim();
    return Semantics(
      button: true,
      label: 'View company details',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size * .25),
        child: InkWell(
          onTap: identifier.isEmpty
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CompanyDetailsScreen(identifier: identifier),
                  ),
                ),
          borderRadius: BorderRadius.circular(size * .25),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(size * .25),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: logoUrl?.trim().isNotEmpty == true
                ? Image.network(
                    logoUrl!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    errorBuilder: (_, _, _) => _Initials(value: initials),
                  )
                : _Initials(value: initials),
          ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value.isEmpty ? 'CO' : value,
    style: const TextStyle(
      color: Color(0xFF047857),
      fontSize: 18,
      fontWeight: FontWeight.w900,
    ),
  );
}
