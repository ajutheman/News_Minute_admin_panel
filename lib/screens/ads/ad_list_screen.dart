import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/ad_provider.dart';
import '../../services/file_upload_service.dart';

class AdListScreen extends StatefulWidget {
  const AdListScreen({super.key});

  @override
  State<AdListScreen> createState() => _AdListScreenState();
}

class _AdListScreenState extends State<AdListScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<AdProvider>(context, listen: false).fetchAds()
    );
  }

  void _showAddEditDialog(BuildContext context, {Map<String, dynamic>? ad}) {
    final titleController = TextEditingController(text: ad?['title'] ?? '');
    final contentController = TextEditingController(text: ad?['content'] ?? ''); // This holds the image URL
    final List<String> positions = ['HeaderTop', 'HomeMiddle', 'SidebarTop', 'ArticleSidebar', 'ArticleBottom', 'TopBanner', 'BottomBanner', 'InsideNews', 'Sidebar', 'Floating'];
    final positionController = TextEditingController(text: ad?['position'] ?? positions.first);
    String type = ad?['type'] ?? 'Image';
    String status = ad?['status'] ?? 'Active';
    
    // Upload state (local to dialog)
    bool isUploading = false;
    bool useFileUpload = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          Future<void> pickImage() async {
            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setDialogState(() => isUploading = true);
              final url = await FileUploadService.uploadImage(File(image.path));
              setDialogState(() {
                 isUploading = false;
                 if (url != null) {
                   contentController.text = url;
                 }
              });
            }
          }

          return AlertDialog(
            title: Text(ad == null ? 'Add Ad' : 'Edit Ad'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ['Image', 'Text', 'Video'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setDialogState(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Content / Image Section
                  if (type == 'Image') ...[
                     Row(
                        children: [
                          ChoiceChip(label: const Text('File'), selected: useFileUpload, onSelected: (v) => setDialogState(() => useFileUpload = true)),
                          const SizedBox(width: 8),
                          ChoiceChip(label: const Text('URL'), selected: !useFileUpload, onSelected: (v) => setDialogState(() => useFileUpload = false)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (useFileUpload)
                        FilledButton.icon(
                          onPressed: isUploading ? null : pickImage,
                          icon: const Icon(Icons.upload),
                          label: Text(isUploading ? 'Uploading...' : 'Pick Ad Image'),
                        )
                      else 
                        TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Image URL')),
                  ] else 
                     TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content / URL / Text')),
                     
                  if (contentController.text.isNotEmpty && type == 'Image')
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: SizedBox(height: 100, child: Image.network(contentController.text, errorBuilder: (c,e,s) => const Icon(Icons.error))),
                     ),

                  const SizedBox(height: 16),
                  TextField(controller: positionController, decoration: const InputDecoration(labelText: 'Position (e.g., Homepage_Top)')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: ['Active', 'Inactive', 'Scheduled'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setDialogState(() => status = v!),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: isUploading ? null : () async {
                   final provider = Provider.of<AdProvider>(context, listen: false);
                   final data = {
                     'title': titleController.text,
                     'type': type,
                     'content': contentController.text,
                     'position': positionController.text,
                     'status': status,
                   };
                   bool success;
                   if (ad == null) {
                     success = await provider.addAd(data);
                   } else {
                     success = await provider.updateAd(ad['_id'], data);
                   }
                   if (success && mounted) {
                     Navigator.pop(ctx);
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
    final provider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Management'),
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
              itemCount: provider.ads.length,
              itemBuilder: (context, index) {
                final ad = provider.ads[index];
                return Card(
                  child: ListTile(
                    leading: ad['type'] == 'Image' 
                      ? SizedBox(width: 50, child: Image.network(ad['content'], errorBuilder: (c,e,s) => const Icon(Icons.ad_units)))
                      : const Icon(Icons.ad_units),
                    title: Text(ad['title']),
                    subtitle: Text('${ad['position']} - ${ad['status']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                           icon: const Icon(Icons.edit, color: Colors.blue),
                           onPressed: () => _showAddEditDialog(context, ad: ad),
                         ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                              await provider.deleteAd(ad['_id']);
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
