import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum CardStatus { newCard, learning, mastered }

class StatusBadgeWidget extends StatelessWidget {
  final CardStatus status;

  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      CardStatus.newCard => (
        'New',
        AppTheme.statusNew.withAlpha(31),
        AppTheme.statusNew,
      ),
      CardStatus.learning => (
        'Learning',
        AppTheme.statusLearning.withAlpha(31),
        AppTheme.statusLearning,
      ),
      CardStatus.mastered => (
        'Mastered',
        AppTheme.statusMastered.withAlpha(31),
        AppTheme.statusMastered,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
