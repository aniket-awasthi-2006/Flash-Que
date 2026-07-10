import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/status_badge_widget.dart';
import './widgets/add_edit_card_sheet_widget.dart';
import './widgets/flashcard_list_item_widget.dart';
import './widgets/tab_filter_widget.dart';

// TODO: Replace with [Riverpod/Bloc] for production

class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final CardStatus status;
  final List<Color> gradientColors;
  final DateTime createdAt;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.status,
    required this.gradientColors,
    required this.createdAt,
  });

  FlashcardModel copyWith({
    String? question,
    String? answer,
    CardStatus? status,
    List<Color>? gradientColors,
  }) {
    return FlashcardModel(
      id: id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      status: status ?? this.status,
      gradientColors: gradientColors ?? this.gradientColors,
      createdAt: createdAt,
    );
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      status: _statusFromString(map['status'] as String),
      gradientColors: (map['gradientColors'] as List).cast<Color>(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'answer': answer,
    'status': _statusToString(status),
    'gradientColors': gradientColors,
    'createdAt': createdAt.toIso8601String(),
  };

  static CardStatus _statusFromString(String v) {
    switch (v) {
      case 'learning':
        return CardStatus.learning;
      case 'mastered':
        return CardStatus.mastered;
      default:
        return CardStatus.newCard;
    }
  }

  static String _statusToString(CardStatus s) {
    switch (s) {
      case CardStatus.learning:
        return 'learning';
      case CardStatus.mastered:
        return 'mastered';
      case CardStatus.newCard:
        return 'new';
    }
  }
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with [Riverpod/Bloc] for production
  late List<FlashcardModel> _flashcards;
  int _selectedTabIndex = 0;
  late AnimationController _listAnimController;

  final List<Map<String, dynamic>> _flashcardMaps = [
    {
      'id': 'fc_001',
      'question': 'What is the powerhouse of the cell?',
      'answer':
          'The mitochondria — an organelle that generates most of the cell\'s supply of ATP through cellular respiration.',
      'status': 'mastered',
      'gradientColors': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'createdAt': '2026-07-01T09:00:00.000Z',
    },
    {
      'id': 'fc_002',
      'question': 'Define photosynthesis.',
      'answer':
          'The process by which green plants convert sunlight, water, and CO₂ into glucose and oxygen using chlorophyll.',
      'status': 'mastered',
      'gradientColors': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'createdAt': '2026-07-01T09:05:00.000Z',
    },
    {
      'id': 'fc_003',
      'question': 'What is Newton\'s Second Law of Motion?',
      'answer':
          'F = ma — Force equals mass times acceleration. The net force on an object equals its mass multiplied by its acceleration.',
      'status': 'learning',
      'gradientColors': [const Color(0xFF4481EB), const Color(0xFF04BEFE)],
      'createdAt': '2026-07-02T10:00:00.000Z',
    },
    {
      'id': 'fc_004',
      'question': 'Explain the concept of osmosis.',
      'answer':
          'The movement of water molecules through a semi-permeable membrane from an area of low solute concentration to high solute concentration.',
      'status': 'learning',
      'gradientColors': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      'createdAt': '2026-07-03T11:00:00.000Z',
    },
    {
      'id': 'fc_005',
      'question': 'What is the Pythagorean theorem?',
      'answer':
          'a² + b² = c² — In a right triangle, the square of the hypotenuse equals the sum of the squares of the other two sides.',
      'status': 'mastered',
      'gradientColors': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      'createdAt': '2026-07-04T08:00:00.000Z',
    },
    {
      'id': 'fc_006',
      'question': 'What is DNA and what does it stand for?',
      'answer':
          'Deoxyribonucleic Acid — a molecule that carries genetic information and instructions for development and function of all living organisms.',
      'status': 'new',
      'gradientColors': [const Color(0xFF667EEA), const Color(0xFF38F9D7)],
      'createdAt': '2026-07-05T09:30:00.000Z',
    },
    {
      'id': 'fc_007',
      'question': 'Define the law of conservation of energy.',
      'answer':
          'Energy cannot be created or destroyed, only transformed from one form to another. The total energy of an isolated system remains constant.',
      'status': 'new',
      'gradientColors': [const Color(0xFF4FACFE), const Color(0xFFF093FB)],
      'createdAt': '2026-07-06T14:00:00.000Z',
    },
    {
      'id': 'fc_008',
      'question': 'What is the speed of light?',
      'answer':
          'Approximately 299,792,458 metres per second (≈ 3 × 10⁸ m/s) in a vacuum, denoted as \'c\'.',
      'status': 'learning',
      'gradientColors': [const Color(0xFF43E97B), const Color(0xFF4481EB)],
      'createdAt': '2026-07-07T10:00:00.000Z',
    },
    {
      'id': 'fc_009',
      'question': 'What is the difference between weather and climate?',
      'answer':
          'Weather is short-term atmospheric conditions in a specific area. Climate is the long-term average weather patterns of a region over 30+ years.',
      'status': 'new',
      'gradientColors': [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      'createdAt': '2026-07-08T09:00:00.000Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _flashcards = _flashcardMaps.map(FlashcardModel.fromMap).toList();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _listAnimController.dispose();
    super.dispose();
  }

  List<FlashcardModel> get _filteredCards {
    switch (_selectedTabIndex) {
      case 1:
        return _flashcards
            .where((c) => c.status == CardStatus.learning)
            .toList();
      case 2:
        return _flashcards
            .where((c) => c.status == CardStatus.mastered)
            .toList();
      default:
        return _flashcards;
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _listAnimController.forward(from: 0);
    });
  }

  void _showAddEditSheet({FlashcardModel? card}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditCardSheetWidget(
        existingCard: card,
        onSave: (question, answer) {
          setState(() {
            if (card != null) {
              final idx = _flashcards.indexWhere((c) => c.id == card.id);
              if (idx != -1) {
                _flashcards[idx] = card.copyWith(
                  question: question,
                  answer: answer,
                );
              }
            } else {
              final gradients = [
                [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
                [const Color(0xFF4481EB), const Color(0xFF04BEFE)],
                [const Color(0xFFF093FB), const Color(0xFFF5576C)],
                [const Color(0xFFFA709A), const Color(0xFFFEE140)],
                [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
              ];
              final rnd = Random();
              _flashcards.add(
                FlashcardModel(
                  id: 'fc_${DateTime.now().millisecondsSinceEpoch}',
                  question: question,
                  answer: answer,
                  status: CardStatus.newCard,
                  gradientColors: gradients[rnd.nextInt(gradients.length)],
                  createdAt: DateTime.now(),
                ),
              );
            }
            _listAnimController.forward(from: 0);
          });
        },
      ),
    );
  }

  void _deleteCard(String id) {
    setState(() {
      _flashcards.removeWhere((c) => c.id == id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Flashcard deleted')));
  }

  void _cycleStatus(FlashcardModel card) {
    final nextStatus = switch (card.status) {
      CardStatus.newCard => CardStatus.learning,
      CardStatus.learning => CardStatus.mastered,
      CardStatus.mastered => CardStatus.newCard,
    };
    setState(() {
      final idx = _flashcards.indexWhere((c) => c.id == card.id);
      if (idx != -1) {
        _flashcards[idx] = card.copyWith(status: nextStatus);
      }
    });
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredCards;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FlashQue',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          '${_flashcards.length} flashcards in your deck',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Study Now button
                  if (_flashcards.isNotEmpty)
                    GestureDetector(
                      onTap: () => context.go('/study-screen'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Study',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Tab filter
            TabFilterWidget(
              selectedIndex: _selectedTabIndex,
              onTabChanged: _onTabChanged,
              counts: [
                _flashcards.length,
                _flashcards
                    .where((c) => c.status == CardStatus.learning)
                    .length,
                _flashcards
                    .where((c) => c.status == CardStatus.mastered)
                    .length,
              ],
            ),
            const SizedBox(height: 8),
            // List / Grid
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.style_outlined,
                      title: _selectedTabIndex == 0
                          ? 'No flashcards yet'
                          : 'No cards here',
                      description: _selectedTabIndex == 0
                          ? 'Tap the + button to create your first flashcard and start studying.'
                          : 'Cards will appear here as you progress through your studies.',
                      ctaLabel: _selectedTabIndex == 0
                          ? 'Create Flashcard'
                          : null,
                      onCta: _selectedTabIndex == 0
                          ? () => _showAddEditSheet()
                          : null,
                    )
                  : _isTablet
                  ? _buildTabletGrid(filtered)
                  : _buildPhoneList(filtered),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Card',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPhoneList(List<FlashcardModel> cards) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final delay = (index * 60).clamp(0, 400);
        final animation = CurvedAnimation(
          parent: _listAnimController,
          curve: Interval(
            delay / 1000.0,
            (delay + 400) / 1000.0,
            curve: Curves.easeOutCubic,
          ),
        );
        return AnimatedBuilder(
          animation: animation,
          builder: (_, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FlashcardListItemWidget(
              card: card,
              onEdit: () => _showAddEditSheet(card: card),
              onDelete: () => _deleteCard(card.id),
              onStatusTap: () => _cycleStatus(card),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletGrid(List<FlashcardModel> cards) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return FlashcardListItemWidget(
          card: card,
          onEdit: () => _showAddEditSheet(card: card),
          onDelete: () => _deleteCard(card.id),
          onStatusTap: () => _cycleStatus(card),
        );
      },
    );
  }
}
