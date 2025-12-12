import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../app_colors.dart';
import 'dart:typed_data'; // ← WAJIB untuk web (bytes)

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({super.key});

  @override
  State<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _contentC = TextEditingController();

  XFile? _imageFile;
  Uint8List? _imageBytes; // ← untuk WEB agar tidak error blob
  String? _selectedCategory;

  final List<String> _categories = [
    'All', 'Lifestyle', 'Travel', 'Food', 'Education', 'Technology', 'Health'
  ];

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes(); // ← FIX WEB

      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memilih gambar: $e")),
      );
    }
  }

  Future<void> _saveNews() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar wajib diisi!')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori')),
      );
      return;
    }

    setState(() => _isLoading = true);
final success = await context.read<NewsProvider>().addNewsAndRefresh(
      title: _titleC.text.trim(),
      content: _contentC.text.trim(),
      category: _selectedCategory!,
      imageBytes: _imageBytes!,      // ← kirim bytes saja
      imageFilename: _imageFile!.name,
      token: context.read<AuthProvider>().token!,
      // FIX 2: Pass the required context parameter
      context: context,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berita berhasil dipublikasikan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain ?? Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Berita",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: AppColors.primaryRed.withOpacity(0.15), width: 1.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Judul Berita", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _titleC,
                    decoration: InputDecoration(
                      hintText: "Masukkan judul menarik...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.title, color: AppColors.primaryRed),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v!.trim().isEmpty ? "Judul wajib diisi" : null,
                  ),
                  const SizedBox(height: 24),

                  const Text("Isi Berita", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _contentC,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Tuliskan berita secara lengkap...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => v!.trim().isEmpty ? "Isi berita wajib diisi" : null,
                  ),
                  const SizedBox(height: 24),

                  const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text("Pilih kategori"),
                    items: _categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                  const SizedBox(height: 28),

                  // GAMBAR — FIX
                  const Text("Gambar Utama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showImageSheet,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: _imageBytes == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey[600]),
                                  const SizedBox(height: 12),
                                  Text("Ketuk untuk pilih gambar",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 18,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                                        onPressed: _showImageSheet,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveNews,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.publish),
                          label: Text(_isLoading ? "Menyimpan..." : "Publikasikan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
