import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/auth_manager.dart';

class FirstLoginPreferencesScreen extends StatefulWidget {
  const FirstLoginPreferencesScreen({super.key});

  @override
  State<FirstLoginPreferencesScreen> createState() =>
      _FirstLoginPreferencesScreenState();
}

class _FirstLoginPreferencesScreenState
    extends State<FirstLoginPreferencesScreen> {
  bool _saving = false;
  final Set<String> _selectedSkills = <String>{};

  final List<_SkillChoice> _choices = const [
    _SkillChoice(
      id: 'social_health',
      title: 'Mạng xã hội và Sức khỏe',
      icon: Icons.school_outlined,
      colors: [Color(0xFFFFF3C4), Color(0xFFFDE68A)],
      iconColor: Color(0xFFB45309),
    ),
    _SkillChoice(
      id: 'goal_setting',
      title: 'Thiết lập mục tiêu',
      icon: Icons.explore_outlined,
      colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
      iconColor: Color(0xFF4338CA),
    ),
    _SkillChoice(
      id: 'communication',
      title: 'Các kỹ năng giao tiếp',
      icon: Icons.record_voice_over_outlined,
      colors: [Color(0xFFFCE7F3), Color(0xFFF9A8D4)],
      iconColor: Color(0xFFBE185D),
    ),
    _SkillChoice(
      id: 'critical_thinking',
      title: 'Tư duy thực tế',
      icon: Icons.psychology_alt_outlined,
      colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
      iconColor: Color(0xFF374151),
    ),
    _SkillChoice(
      id: 'stress_management',
      title: 'Đối phó với cảm xúc và căng thẳng',
      icon: Icons.spa_outlined,
      colors: [Color(0xFFCFFAFE), Color(0xFFA7F3D0)],
      iconColor: Color(0xFF0F766E),
    ),
    _SkillChoice(
      id: 'problem_solving',
      title: 'Giải quyết vấn đề và quyết định',
      icon: Icons.tips_and_updates_outlined,
      colors: [Color(0xFFFDECC8), Color(0xFFFBBF24)],
      iconColor: Color(0xFFB45309),
    ),
  ];

  void _toggleChoice(String id) {
    setState(() {
      if (_selectedSkills.contains(id)) {
        _selectedSkills.remove(id);
      } else {
        _selectedSkills.add(id);
      }
    });
  }

  Future<void> _finish({required bool saveSelection}) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await AuthManager.completeFirstLoginOnboarding(
        favoriteSkills: saveSelection
            ? _selectedSkills.toList()
            : const <String>[],
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text(
          'Chọn kỹ năng yêu thích',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chọn những kỹ năng bạn thích để dễ tìm hơn',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                itemCount: _choices.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = _choices[index];
                  final selected = _selectedSkills.contains(item.id);
                  return _SkillCard(
                    choice: item,
                    selected: selected,
                    onTap: () => _toggleChoice(item.id),
                  );
                },
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () => _finish(saveSelection: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Bắt đầu ngay',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => _finish(saveSelection: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Bỏ qua',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final _SkillChoice choice;
  final bool selected;
  final VoidCallback onTap;

  const _SkillCard({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.2 : 0.12),
                blurRadius: selected ? 18 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: selected
                          ? const [Color(0xFF4F46E5), Color(0xFF7C3AED)]
                          : choice.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.82),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            choice.icon,
                            size: 30,
                            color: selected ? Colors.white : choice.iconColor,
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F46E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  choice.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillChoice {
  final String id;
  final String title;
  final IconData icon;
  final List<Color> colors;
  final Color iconColor;

  const _SkillChoice({
    required this.id,
    required this.title,
    required this.icon,
    required this.colors,
    required this.iconColor,
  });
}
