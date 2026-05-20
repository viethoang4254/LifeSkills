import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/services/admin_service.dart';
import '../../../utils/auth_manager.dart';
import '../../../widgets/state/success_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final user = await AuthManager.getUser();
    _adminId = user['id']!;

    try {
      final users = await _adminService.getAllUsers(_adminId);
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        await showFeedbackDialog<void>(
          context,
          title: 'Không thể tải người dùng',
          message: e.toString(),
          icon: Icons.error_outline_rounded,
          accentColor: Colors.red.shade600,
          actionLabel: 'OK',
        );
      }
    }
  }

  Future<void> _toggleRole(String targetEmail, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    try {
      await _adminService.setRole(
        adminId: _adminId,
        targetEmail: targetEmail,
        newRole: newRole,
      );
      if (mounted) {
        await showFeedbackDialog<void>(
          context,
          title: 'Đã cập nhật quyền',
          message: 'Quyền tài khoản đã được chuyển thành $newRole.',
          icon: Icons.admin_panel_settings_rounded,
          accentColor: const Color(0xFF4F46E5),
          actionLabel: 'OK',
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        await showFeedbackDialog<void>(
          context,
          title: 'Không thể cập nhật quyền',
          message: e.toString(),
          icon: Icons.error_outline_rounded,
          accentColor: Colors.red.shade600,
          actionLabel: 'OK',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý hệ thống', style: GoogleFonts.outfit()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final u = _users[index];
                final isAdmin = u['role'] == 'admin';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdmin
                          ? Colors.orange.shade100
                          : const Color(0xFFEEF2FF),
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: isAdmin
                            ? Colors.orange
                            : const Color(0xFF4F46E5),
                      ),
                    ),
                    title: Text(
                      u['name'] ?? '',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      u['email'] ?? '',
                      style: GoogleFonts.outfit(),
                    ),
                    trailing: u['id'] == _adminId
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Bạn',
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          )
                        : TextButton(
                            onPressed: () => _toggleRole(u['email'], u['role']),
                            child: Text(
                              isAdmin ? 'Gỡ Admin' : 'Thành Admin',
                              style: TextStyle(
                                color: isAdmin
                                    ? Colors.red
                                    : Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
