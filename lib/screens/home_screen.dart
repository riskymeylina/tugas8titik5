// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/news_model.dart';
import '../widgets/news_content_sheet.dart';
import '../widgets/berita_card.dart';
import '../app_colors.dart';
import 'add_news_screen.dart';
import 'profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String selectedCategory = 'All';
  String searchQuery = '';
  bool _isGrid = false;

  final List<String> _categories = [
    'All',
    'Lifestyle',
    'Travel',
    'Food',
    'Education',
    'Technology',
    'Health'
  ];

  @override
  void initState() {
    super.initState();
    // Load berita setelah widget selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && auth.token != null) {
        context.read<NewsProvider>().loadNews(auth.token!);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // HAPUS BERITA: Tampilkan dialog pilihan berita milik user
  Future<void> _showDeleteDialog() async {
    final auth = context.read<AuthProvider>();
    final newsProvider = context.read<NewsProvider>();

    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk menghapus berita')),
      );
      return;
    }

    final myNews = newsProvider.news.where((n) => n.userId == auth.user?.id).toList();

    if (myNews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda tidak memiliki berita untuk dihapus')),
      );
      return;
    }

    final Berita? selectedBerita = await showDialog<Berita>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Berita untuk Dihapus'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: myNews.length,
            itemBuilder: (context, i) {
              final berita = myNews[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(berita.gambarUrl, width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(berita.judul, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(berita.kategori),
                onTap: () => Navigator.pop(ctx, berita),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ],
      ),
    );

    if (selectedBerita != null) {
      _confirmDelete(selectedBerita);
    }
  }

  // Konfirmasi akhir sebelum hapus
  Future<void> _confirmDelete(Berita berita) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Berita?'),
        content: Text('Yakin ingin menghapus berita:\n"${berita.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = context.read<AuthProvider>();
      final newsProvider = context.read<NewsProvider>();

      final success = await newsProvider.deleteNewsAndRefresh(
        newsId: berita.id,
        token: auth.token ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Berita berhasil dihapus!' : 'Gagal menghapus berita'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // AppBar Home
  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'News App',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
      ),
      actions: [
        IconButton(
          icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view, color: Colors.black),
          onPressed: () => setState(() => _isGrid = !_isGrid),
        ),
      ],
    );
  }

  // Konten Home
  Widget _buildHomeContent() {
    final newsProvider = context.watch<NewsProvider>();
    final List<Berita> allNews = newsProvider.news;

    final filtered = allNews.where((n) {
      final matchCat = selectedCategory == 'All' || n.kategori == selectedCategory;
      final matchSearch = n.judul.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _searchBar(),
          const SizedBox(height: 12),
          _buildCategoryChips(),
          const SizedBox(height: 12),
          Expanded(
            child: newsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Tidak ada berita ditemukan'))
                    : _buildNewsList(filtered),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari berita...',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) => setState(() => searchQuery = value),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(cat),
              selected: selectedCategory == cat,
              selectedColor: AppColors.primaryRed.withOpacity(0.2),
              onSelected: (_) => setState(() => selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsList(List<Berita> filtered) {
    if (_isGrid) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) => BeritaCard(
          berita: filtered[i],
          onTap: () => _openNewsPreview(filtered[i]),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: BeritaCard(
          berita: filtered[i],
          onTap: () => _openNewsPreview(filtered[i]),
        ),
      ),
    );
  }

  void _openNewsPreview(Berita berita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewsContentSheet(
        berita: berita,
        scrollController: ScrollController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: _selectedIndex == 0 ? _buildHomeAppBar() : null,
      body: _selectedIndex == 0 ? _buildHomeContent() : const ProfileScreen(),

      // FAB: Tambah & Hapus Berita (hanya jika login)
      floatingActionButton: (_selectedIndex == 0 && auth.isAuthenticated)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // TOMBOL HAPUS
                FloatingActionButton.extended(
                  heroTag: 'deleteFab',
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Hapus Berita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _showDeleteDialog,
                ),
                const SizedBox(height: 12),
                // TOMBOL TAMBAH
                FloatingActionButton.extended(
                  heroTag: 'addFab',
                  backgroundColor: AppColors.primaryRed,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Tambah Berita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddNewsScreen()),
                    );
                    if (result == true && mounted) {
                      context.read<NewsProvider>().loadNews(auth.token ?? '');
                    }
                  },
                ),
              ],
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}