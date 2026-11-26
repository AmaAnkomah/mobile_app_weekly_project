import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../utils/app_theme.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../services/storage_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final MenuItemModel? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String _category = 'Lunch';
  
  XFile? _imageFile;
  String? _currentImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController  = TextEditingController(text: widget.item?.name);
    _descController  = TextEditingController(text: widget.item?.description);
    _priceController = TextEditingController(text: widget.item?.price.toString());
    _stockController = TextEditingController(text: widget.item?.stock.toString());
    _category        = widget.item?.category ?? 'Lunch';
    _currentImageUrl = widget.item?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && _currentImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image.')));
      return;
    }

    setState(() => _isSaving = true);
    final adminVM = context.read<AdminViewModel>();
    final storage = context.read<StorageService>();

    try {
      String imageUrl = _currentImageUrl ?? '';
      
      if (_imageFile != null) {
        imageUrl = await storage.uploadMenuImage(
          file: _imageFile!,
          fileName: StorageService.generateFileName('item'),
        );
      }

      final data = {
        'name':        _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price':       double.parse(_priceController.text),
        'stock':       int.parse(_stockController.text),
        'category':    _category,
        'imageUrl':    imageUrl,
        if (widget.item == null) 'createdAt': DateTime.now(),
      };

      if (widget.item == null) {
        await adminVM.addItem(MenuItemModel.fromMap(data, ''));
      } else {
        await adminVM.updateItem(widget.item!.id!, data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Item' : 'Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              
              _buildLabel('Basic Info'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Item Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(hintText: 'Description'),
                maxLines: 3,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(hintText: 'Price (GHS)', prefixText: 'GHS '),
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(hintText: 'Stock Qty'),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('Category'),
              _buildCategorySelector(),
              
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Update Menu Item' : 'Create Menu Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceDim)),
  );

  Widget _buildImagePicker() => Center(
    child: GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildImagePreview(),
      ),
    ),
  );

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.network(_imageFile!.path, fit: BoxFit.cover); // XFile.path works as URL on Web
    }
    if (_currentImageUrl != null) {
      return Image.network(_currentImageUrl!, fit: BoxFit.cover);
    }
    return const Icon(Icons.add_a_photo_outlined, color: AppTheme.primary, size: 40);
  }

  Widget _buildCategorySelector() => Row(
    children: ['Breakfast', 'Lunch', 'Snacks'].map((cat) {
      final isSelected = _category == cat;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (v) => setState(() => _category = cat),
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.onSurfaceDim),
          ),
        ),
      );
    }).toList(),
  );
}
