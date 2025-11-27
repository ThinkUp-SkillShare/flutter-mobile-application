import 'package:flutter/material.dart';
import '../../../auth/application/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/group_management_service.dart';

class ManageMembersScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final Map<String, dynamic> permissions;

  const ManageMembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.permissions,
  });

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  Set<int> selectedMembers = {};
  bool isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => isLoading = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      members = await GroupService.getGroupMembers(widget.groupId, token);
    } catch (e) {
      print('Error loading members: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF0F9D58),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _promoteToAdmin(int userId, String userEmail) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Admin'),
        content: Text('Promote $userEmail to admin? They will have management permissions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F9D58)),
            child: const Text('Promote'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final success = await GroupManagementService.promoteToAdmin(widget.groupId, userId, token);

      if (success) {
        _showSnackBar('Member promoted to admin');
        _loadMembers();
      } else {
        _showSnackBar('Failed to promote member', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _demoteToMember(int userId, String userEmail) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demote to Member'),
        content: Text('Demote $userEmail to regular member? They will lose admin permissions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF6B35)),
            child: const Text('Demote'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final success = await GroupManagementService.demoteToMember(widget.groupId, userId, token);

      if (success) {
        _showSnackBar('Admin demoted to member');
        _loadMembers();
      } else {
        _showSnackBar('Failed to demote admin', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _removeMember(int userId, String userEmail) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove $userEmail from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final success = await GroupManagementService.removeMember(widget.groupId, userId, token);

      if (success) {
        _showSnackBar('Member removed from group');
        _loadMembers();
      } else {
        _showSnackBar('Failed to remove member', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _bulkRemoveMembers() async {
    if (selectedMembers.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Multiple Members'),
        content: Text('Remove ${selectedMembers.length} selected members from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
            child: const Text('Remove All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final removedIds = await GroupManagementService.bulkRemoveMembers(
        widget.groupId,
        selectedMembers.toList(),
        token,
      );

      _showSnackBar('Removed ${removedIds.length} of ${selectedMembers.length} members');
      setState(() {
        selectedMembers.clear();
        isMultiSelectMode = false;
      });
      _loadMembers();
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _transferOwnership(int userId, String userEmail) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Ownership'),
        content: Text(
          'Transfer group ownership to $userEmail? You will lose owner privileges but remain as admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF6B35)),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final success = await GroupManagementService.transferOwnership(widget.groupId, userId, token);

      if (success) {
        _showSnackBar('Ownership transferred successfully');
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Failed to transfer ownership', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showMemberActions(Map<String, dynamic> member) {
    final userId = member['userId'] as int;
    final userEmail = member['userEmail'] as String;
    final role = member['role'] as String;
    final isAdmin = role == 'admin';

    final canPromote = widget.permissions['canPromoteMembers'] == true;
    final canRemove = widget.permissions['canRemoveMembers'] == true;
    final canTransfer = widget.permissions['canTransferOwnership'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (canPromote && !isAdmin)
              ListTile(
                leading: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF0F9D58)),
                title: const Text('Promote to Admin'),
                onTap: () {
                  Navigator.pop(context);
                  _promoteToAdmin(userId, userEmail);
                },
              ),
            if (canPromote && isAdmin)
              ListTile(
                leading: const Icon(Icons.arrow_downward_rounded, color: Color(0xFFFF6B35)),
                title: const Text('Demote to Member'),
                onTap: () {
                  Navigator.pop(context);
                  _demoteToMember(userId, userEmail);
                },
              ),
            if (canTransfer)
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF9B59B6)),
                title: const Text('Transfer Ownership'),
                onTap: () {
                  Navigator.pop(context);
                  _transferOwnership(userId, userEmail);
                },
              ),
            if (canRemove)
              ListTile(
                leading: const Icon(Icons.person_remove_rounded, color: Color(0xFFD32F2F)),
                title: const Text('Remove from Group'),
                onTap: () {
                  Navigator.pop(context);
                  _removeMember(userId, userEmail);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canRemove = widget.permissions['canRemoveMembers'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2C3E50)),
        ),
        title: Text(
          isMultiSelectMode ? '${selectedMembers.length} selected' : 'Manage Members',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (canRemove && !isMultiSelectMode)
            IconButton(
              icon: const Icon(Icons.checklist_rounded, color: Color(0xFF324779)),
              onPressed: () {
                setState(() => isMultiSelectMode = true);
              },
            ),
          if (isMultiSelectMode)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFD32F2F)),
              onPressed: () {
                setState(() {
                  isMultiSelectMode = false;
                  selectedMembers.clear();
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF324779).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF324779).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded, color: Color(0xFF324779)),
                  const SizedBox(width: 12),
                  Text(
                    '${members.length} members in ${widget.groupName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF324779),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final userId = member['userId'] as int;
                final isAdmin = member['role'] == 'admin';
                final isSelected = selectedMembers.contains(userId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF324779)
                          : (isAdmin ? const Color(0xFF324779).withOpacity(0.3) : Colors.transparent),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () {
                      if (isMultiSelectMode) {
                        setState(() {
                          if (isSelected) {
                            selectedMembers.remove(userId);
                          } else {
                            selectedMembers.add(userId);
                          }
                        });
                      } else {
                        _showMemberActions(member);
                      }
                    },
                    leading: isMultiSelectMode
                        ? Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedMembers.add(userId);
                          } else {
                            selectedMembers.remove(userId);
                          }
                        });
                      },
                      activeColor: const Color(0xFF324779),
                    )
                        : CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF324779),
                      child: Text(
                        member['userEmail'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      member['userEmail'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    subtitle: isAdmin
                        ? const Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF324779),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        : null,
                    trailing: !isMultiSelectMode && isAdmin
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF324779),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isMultiSelectMode && selectedMembers.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _bulkRemoveMembers,
        backgroundColor: const Color(0xFFD32F2F),
        icon: const Icon(Icons.delete_rounded),
        label: Text('Remove ${selectedMembers.length}'),
      )
          : null,
    );
  }
}