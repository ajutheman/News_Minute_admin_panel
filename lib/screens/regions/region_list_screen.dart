import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/region_provider.dart';

class RegionListScreen extends StatefulWidget {
  const RegionListScreen({super.key});

  @override
  State<RegionListScreen> createState() => _RegionListScreenState();
}

class _RegionListScreenState extends State<RegionListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<RegionProvider>(context, listen: false).fetchRegions()
    );
  }

  void _showAddEditDialog(BuildContext context, {Map<String, dynamic>? region}) {
    final nameController = TextEditingController(text: region?['name'] ?? '');
    final typeController = TextEditingController(text: region?['type'] ?? 'City');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(region == null ? 'Add Region' : 'Edit Region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
             TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type (e.g., City, State, Country)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final provider = Provider.of<RegionProvider>(context, listen: false);
                final data = {
                  'name': nameController.text,
                  'type': typeController.text,
                };
                
                bool success;
                if (region == null) {
                  success = await provider.addRegion(data);
                } else {
                  success = await provider.updateRegion(region['_id'], data);
                }
                
                if (success && mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved Successfully')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.regions.length,
              itemBuilder: (context, index) {
                final region = provider.regions[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.public)),
                    title: Text(region['name']),
                    subtitle: Text(region['type'] ?? 'Unknown Type'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(context, region: region),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
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
                               await provider.deleteRegion(region['_id']);
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
