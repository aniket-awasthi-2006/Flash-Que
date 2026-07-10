import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/status_badge_widget.dart';
import '../flashcards_screen/flashcards_screen.dart';
import './widgets/activity_chart_widget.dart';
import './widgets/flip_card_widget.dart';
import './widgets/kpi_card_row_widget.dart';
import './widgets/session_progress_widget.dart';

// TODO: Replace with [Riverpod/Bloc] for production

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production — inject real deck data
  late List<FlashcardModel> _studyCards;
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _masteredCount = 0;
  int _totalAnswered = 0;
  int _correctCount = 0;

  final List<Map<String, dynamic>> _studyCardMaps = [
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
    _studyCards = _studyCardMaps.map(FlashcardModel.fromMap).toList();
    _masteredCount = _studyCards
        .where((c) => c.status == CardStatus.mastered)
        .length;
  }

  FlashcardModel get _currentCard => _studyCards[_currentIndex];

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
  }

  void _goNext() {
    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _markKnown() {
    setState(() {
      _correctCount++;
      _totalAnswered++;
      if (_studyCards[_currentIndex].status != CardStatus.mastered) {
        _masteredCount++;
        _studyCards[_currentIndex] = _studyCards[_currentIndex].copyWith(
          status: CardStatus.mastered,
        );
      }
      _isFlipped = false;
      if (_currentIndex < _studyCards.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _markStillLearning() {
    setState(() {
      _totalAnswered++;
      if (_studyCards[_currentIndex].status == CardStatus.mastered) {
        _masteredCount--;
        _studyCards[_currentIndex] = _studyCards[_currentIndex].copyWith(
          status: CardStatus.learning,
        );
      }
      _isFlipped = false;
      if (_currentIndex < _studyCards.length - 1) {
        _currentIndex++;
      }
    });
  }

  int get _accuracyPercent {
    if (_totalAnswered == 0) return 0;
    return ((_correctCount / _totalAnswered) * 100).round();
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeader(),
              SessionProgressWidget(
                current: _currentIndex + 1,
                total: _studyCards.length,
              ),
              const SizedBox(height: 20),
              // Flip card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FlipCardWidget(
                  card: _currentCard,
                  isFlipped: _isFlipped,
                  onFlip: _flipCard,
                ),
              ),
              const SizedBox(height: 20),
              // Show answer / mark buttons
              _buildCardActions(),
              const SizedBox(height: 16),
              // Prev / Next navigation
              _buildNavButtons(),
              const SizedBox(height: 28),
              // KPI cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: KpiCardRowWidget(
                  masteredCount: _masteredCount,
                  totalCards: _studyCards.length,
                  accuracyPercent: _accuracyPercent,
                  totalAnswered: _totalAnswered,
                ),
              ),
              const SizedBox(height: 24),
              // Activity chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActivityChartWidget(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left: card + nav
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _buildHeader(),
                SessionProgressWidget(
                  current: _currentIndex + 1,
                  total: _studyCards.length,
                ),
                const SizedBox(height: 24),
                FlipCardWidget(
                  card: _currentCard,
                  isFlipped: _isFlipped,
                  onFlip: _flipCard,
                ),
                const SizedBox(height: 20),
                _buildCardActions(),
                const SizedBox(height: 16),
                _buildNavButtons(),
              ],
            ),
          ),
        ),
        // Right: stats sidebar
        Container(width: 1, color: Theme.of(context).colorScheme.outline),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                KpiCardRowWidget(
                  masteredCount: _masteredCount,
                  totalCards: _studyCards.length,
                  accuracyPercent: _accuracyPercent,
                  totalAnswered: _totalAnswered,
                ),
                const SizedBox(height: 24),
                ActivityChartWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/flashcards-screen'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Session',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Card ${_currentIndex + 1} of ${_studyCards.length}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          StatusBadgeWidget(status: _currentCard.status),
        ],
      ),
    );
  }

  Widget _buildCardActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isFlipped
            ? Row(
                key: const ValueKey('known-buttons'),
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _markStillLearning,
                      icon: const Icon(Icons.replay_rounded, size: 16),
                      label: Text(
                        'Still Learning',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.warning,
                        side: const BorderSide(color: AppTheme.warning),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markKnown,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(
                        'Got It!',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                key: const ValueKey('show-answer'),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _flipCard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Show Answer',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNavButtons() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Previous
          Expanded(
            child: GestureDetector(
              onTap: _currentIndex > 0 ? _goPrev : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _currentIndex > 0
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _currentIndex > 0
                        ? theme.colorScheme.outline
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16,
                      color: _currentIndex > 0
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Previous',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _currentIndex > 0
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next
          Expanded(
            child: GestureDetector(
              onTap: _currentIndex < _studyCards.length - 1 ? _goNext : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _currentIndex < _studyCards.length - 1
                      ? AppTheme.primary
                      : theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _currentIndex < _studyCards.length - 1
                            ? Colors.white
                            : theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: _currentIndex < _studyCards.length - 1
                          ? Colors.white
                          : theme.colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
