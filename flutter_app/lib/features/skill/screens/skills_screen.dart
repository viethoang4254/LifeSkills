import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/services/skill_service.dart';
import '../../../utils/user_progress_manager.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/state/state_widgets.dart';
import 'skill_detail_screen.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final SkillService _skillService = SkillService();
  List<dynamic> _allSkills = [];
  List<dynamic> _filtered = [];
  UIState _state = UIState.loading;
  UIError? _error;
  String _selectedCategory = 'Tất cả';
  List<String> _categories = ['Tất cả'];
  Set<String> _completedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSkills();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    final ids = await UserProgressManager.getCompletedSkillIds();
    if (mounted) setState(() => _completedIds = Set.from(ids));
  }

  Future<void> _loadSkills() async {
    setState(() {
      _state = UIState.loading;
      _error = null;
    });
    try {
      final skills = await _skillService.getSkills();
      if (mounted) {
        final cats = <String>{'Tất cả'};
        for (final s in skills) {
          if (s['category'] != null) cats.add(s['category'] as String);
        }
        setState(() {
          _allSkills = skills;
          _categories = cats.toList();
          _state = skills.isEmpty ? UIState.empty : UIState.success;
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = UIState.error;
          _error = UIError.genericError(
            message: e.toString().contains('Connection')
                ? 'Không thể kết nối. Kiểm tra Internet của bạn.'
                : 'Không thể tải danh sách kỹ năng',
          );
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _selectedCategory == 'Tất cả'
          ? List.from(_allSkills)
          : _allSkills
                .where((s) => s['category'] == _selectedCategory)
                .toList();
    });
  }

  double _getCompletion() {
    if (_allSkills.isEmpty) return 0;
    return _completedIds.length / _allSkills.length;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Khoá Học Kỹ Năng',
      currentIndex: 2,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case UIState.loading:
        return SkeletonLoader(itemCount: 4, itemHeight: 220);

      case UIState.error:
        return Stack(
          children: [
            Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  _buildProgressHeader(),
                  _buildCategoryFilter(),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            ErrorOverlay(
              title: _error?.title ?? 'Có lỗi xảy ra',
              message: _error?.message,
              onRetry: _loadSkills,
              onDismiss: () => Navigator.pop(context),
            ),
          ],
        );

      case UIState.empty:
        return Stack(
          children: [
            Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  _buildProgressHeader(),
                  _buildCategoryFilter(),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            EmptyStateOverlay(
              icon: '📚',
              title: 'Chưa có kỹ năng nào',
              description: 'Hãy quay lại sau',
              ctaLabel: 'Tải lại',
              onCTA: _loadSkills,
            ),
          ],
        );

      case UIState.success:
      case UIState.idle:
        return Column(
          children: [
            _buildProgressHeader(),
            _buildCategoryFilter(),
            Expanded(child: _buildList()),
          ],
        );
    }
  }

  Widget _buildProgressHeader() {
    final done = _completedIds.length;
    final total = _allSkills.length;
    final pct = _getCompletion();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ học tập',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done / $total kỹ năng',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}% hoàn thành',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎓', style: TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories
                  .map(
                    (cat) => GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        _applyFilter();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedCategory == cat
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFF0F0FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            color: _selectedCategory == cat
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty && _state == UIState.success) {
      return EmptyStateOverlay(
        icon: '📭',
        title: 'Không tìm thấy kỹ năng',
        description: 'Thử chọn danh mục khác',
        ctaLabel: 'Xem tất cả',
        onCTA: () {
          setState(() => _selectedCategory = 'Tất cả');
          _applyFilter();
        },
      );
    }
    return RefreshIndicator(
      onRefresh: _loadSkills,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _filtered.length,
        itemBuilder: (context, index) => _buildSkillCard(_filtered[index]),
      ),
    );
  }

  Widget _buildSkillCard(dynamic item) {
    final id = item['id'] ?? '';
    final isCompleted = _completedIds.contains(id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SkillDetailScreen(skillItem: item)),
        );
        _loadCompleted();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF059669).withValues(alpha: 0.4)
                : const Color(0xFFEEF2FF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image_url'] != null &&
                (item['image_url'] as String).isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Hero(
                      tag: 'skill_img_${item['id']}',
                      child: Image.network(
                        item['image_url'],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: const Color(0xFFEEF2FF),
                        ),
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hoàn thành',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['category'] ?? 'Khác',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4F46E5),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        const Text('⭐', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title'] ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: Colors.indigo.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cơ bản',
                        style: GoogleFonts.outfit(
                          color: Colors.indigo.shade400,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Colors.indigo.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item['duration_minutes'] ?? 5}p',
                        style: GoogleFonts.outfit(
                          color: Colors.indigo.shade400,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        Text(
                          'Hoàn thành 100%',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF059669),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        )
                      else
                        Text(
                          '0%',
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF059669).withValues(alpha: 0.1)
                              : const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isCompleted ? '✓ Xem lại' : 'Học ngay →',
                          style: GoogleFonts.outfit(
                            color: isCompleted
                                ? const Color(0xFF059669)
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
