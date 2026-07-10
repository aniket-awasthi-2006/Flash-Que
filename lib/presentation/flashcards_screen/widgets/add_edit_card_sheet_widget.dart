import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../flashcards_screen.dart';

class AddEditCardSheetWidget extends StatefulWidget {
  final FlashcardModel? existingCard;
  final void Function(String question, String answer) onSave;

  const AddEditCardSheetWidget({
    super.key,
    this.existingCard,
    required this.onSave,
  });

  @override
  State<AddEditCardSheetWidget> createState() => _AddEditCardSheetWidgetState();
}

class _AddEditCardSheetWidgetState extends State<AddEditCardSheetWidget> {
  // TODO: Replace with [Riverpod/Bloc] for production
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.existingCard?.question ?? '',
    );
    _answerController = TextEditingController(
      text: widget.existingCard?.answer ?? '',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Simulate brief processing
    Future.microtask(() {
      widget.onSave(
        _questionController.text.trim(),
        _answerController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingCard != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Flashcard' : 'New Flashcard',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEditing
                  ? 'Update the question and answer for this card.'
                  : 'Add a question and answer to create your flashcard.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            // Question field — Underline Minimal (V4)
            TextFormField(
              controller: _questionController,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                hintText: 'e.g. What is the speed of light?',
                hintStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                ),
              ),
              maxLines: 2,
              minLines: 1,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Question cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Answer field — Underline Minimal (V4)
            TextFormField(
              controller: _answerController,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'Answer',
                labelStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                hintText: 'e.g. Approximately 299,792,458 m/s',
                hintStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                ),
              ),
              maxLines: 4,
              minLines: 2,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Answer cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Save Changes' : 'Add Card',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
