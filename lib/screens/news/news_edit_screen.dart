import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/news_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/region_provider.dart';
import '../../services/file_upload_service.dart';

class NewsEditScreen extends StatefulWidget {
  final Map<String, dynamic>? news;
  const NewsEditScreen({super.key, this.news});

  @override
  State<NewsEditScreen> createState() => _NewsEditScreenState();
}

class _NewsEditScreenState extends State<NewsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _slugController = TextEditingController();
  final _imageUrlController = TextEditingController(); // For manual URL
  
  String? _selectedMainCategoryId;
  String? _selectedRegionType = 'National';
  String? _selectedTargetRegionId;
  String? _selectedNewsType = 'Standard';
  
  // Image Upload State
  bool _isUploading = false;
  File? _pickedFile;
  String? _uploadedImageUrl; // Final URL to save
  bool _useFileUpload = true; // Toggle state

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<RegionProvider>(context, listen: false).fetchRegions();
    });

    if (widget.news != null) {
      _titleController.text = widget.news!['title'];
      _contentController.text = widget.news!['content'];
      _slugController.text = widget.news!['slug'];
      _selectedMainCategoryId = widget.news!['mainCategory']['_id'];
      _selectedRegionType = widget.news!['regionType'];
      _selectedNewsType = widget.news!['newsType'];
      _selectedTargetRegionId = widget.news!['targetRegion']?['_id'];
      
      _uploadedImageUrl = widget.news!['coverImage'];
      if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
        _imageUrlController.text = _uploadedImageUrl!;
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedFile = File(image.path);
        _isUploading = true;
      });

      // Upload immediately (or could wait for save)
      final url = await FileUploadService.uploadImage(_pickedFile!);
      setState(() {
        _isUploading = false;
        if (url != null) {
          _uploadedImageUrl = url;
          _imageUrlController.text = url; // Sync
        } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload Failed')));
             _pickedFile = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.news == null ? 'Create News' : 'Edit News')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // --- IMAGE SECTION ---
              Text('Cover Image', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(label: const Text('Upload File'), selected: _useFileUpload, onSelected: (v) => setState(() => _useFileUpload = true)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Enter URL'), selected: !_useFileUpload, onSelected: (v) => setState(() => _useFileUpload = false)),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_useFileUpload) 
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: const Icon(Icons.upload),
                      label: Text(_isUploading ? 'Uploading...' : 'Pick Image'),
                    ),
                    const SizedBox(width: 16),
                    if (_pickedFile != null) 
                       const Text('Image Selected', style: TextStyle(color: Colors.green))
                    else if (_uploadedImageUrl != null)
                       const Text('Current Image Set', style: TextStyle(color: Colors.blue)),
                  ],
                )
              else 
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder(), hintText: 'https://...'),
                  onChanged: (v) => _uploadedImageUrl = v,
                ),
              
              if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: Image.network(
                      _uploadedImageUrl!, 
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // --- END IMAGE SECTION ---

              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(labelText: 'Slug', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Consumer<CategoryProvider>(
                builder: (ctx, catProvider, _) {
                  return DropdownButtonFormField<String>(
                    value: _selectedMainCategoryId,
                    decoration: const InputDecoration(labelText: 'Main Category', border: OutlineInputBorder()),
                    items: catProvider.categories.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem(value: cat['_id'], child: Text(cat['name']));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMainCategoryId = val),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRegionType,
                decoration: const InputDecoration(labelText: 'Region Type', border: OutlineInputBorder()),
                items: ['International', 'National', 'Local'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedRegionType = val),
              ),
              const SizedBox(height: 16),
              if (_selectedRegionType != 'International')
                Consumer<RegionProvider>(
                  builder: (ctx, regionProvider, _) {
                    return DropdownButtonFormField<String>(
                      value: _selectedTargetRegionId,
                      decoration: const InputDecoration(labelText: 'Target Region', border: OutlineInputBorder()),
                      items: regionProvider.regions.map<DropdownMenuItem<String>>((r) {
                        return DropdownMenuItem(value: r['_id'], child: Text(r['name']));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTargetRegionId = val),
                    );
                  },
                ),
              if (_selectedRegionType != 'International') const SizedBox(height: 16),
               DropdownButtonFormField<String>(
                value: _selectedNewsType,
                decoration: const InputDecoration(labelText: 'News Type', border: OutlineInputBorder()),
                items: ['Standard', 'Breaking', 'Editorial', 'Opinion'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedNewsType = val),
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder(), alignLabelWithHint: true),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final newsData = {
                        'title': _titleController.text,
                        'slug': _slugController.text,
                        'content': _contentController.text,
                        'mainCategory': _selectedMainCategoryId,
                        'regionType': _selectedRegionType,
                        'newsType': _selectedNewsType,
                         if (_selectedTargetRegionId != null) 'targetRegion': _selectedTargetRegionId,
                        'status': 'Published',
                        'coverImage': _uploadedImageUrl // Save the image URL
                      };

                      final provider = Provider.of<NewsProvider>(context, listen: false);
                      bool success = await provider.createNews(newsData);
                      
                      if (success && mounted) {
                        Navigator.pop(context);
                         Provider.of<NewsProvider>(context, listen: false).fetchNews();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('News Saved')));
                      }
                    }
                  },
                  child: const Text('SAVE NEWS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
