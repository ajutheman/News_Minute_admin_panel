import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<UserProvider>(context, listen: false).fetchUsers()
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
    String role = user['role'] ?? 'PublicUser';
    bool isActive = user['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit User: ${user['username']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: role,
                  items: ['Admin', 'Moderator', 'PublicUser'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setDialogState(() => role = v!),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Active'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                   final provider = Provider.of<UserProvider>(context, listen: false);
                   final success = await provider.updateUser(user['_id'], {
                     'role': role,
                     'isActive': isActive,
                   });
                   if (success && mounted) {
                     Navigator.pop(ctx);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated')));
                   }
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                final isMe = false; // Add logic if needed to check against current user ID
                
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(user['username'][0].toUpperCase())),
                    title: Text(user['username']),
                    subtitle: Text('${user['email']} • ${user['role']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                           icon: const Icon(Icons.edit, color: Colors.blue),
                           onPressed: () => _showEditDialog(context, user),
                         ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                              if (user['role'] == 'Admin') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete Admin')));
                                return;
                              }
                              final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                               await provider.deleteUser(user['_id']);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
