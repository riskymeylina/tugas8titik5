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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadNews(context);
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // ---------------- APP BAR HOME ----------------
  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'News App',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isGrid ? Icons.view_list : Icons.grid_view,
            color: Colors.black,
          ),
          onPressed: () => setState(() => _isGrid = !_isGrid),
        ),
      ],
    );
  }

  // ---------------- HOME CONTENT ----------------
  Widget _buildHomeContent() {
    final newsProvider = context.watch<NewsProvider>();
    List<Berita> allNews = newsProvider.news;
    bool isLoading = newsProvider.isLoading;

    List<Berita> filtered = allNews.where((n) {
      final matchCat =
          selectedCategory == 'All' || n.kategori == selectedCategory;
      final matchSearch =
          n.judul.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _searchBar(),
          const SizedBox(height: 12),

          // Category Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 6),
                ..._categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: selectedCategory == c,
                      selectedColor: AppColors.primaryRed.withOpacity(0.12),
                      onSelected: (_) =>
                          setState(() => selectedCategory = c),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(allNews.isEmpty
                            ? 'Belum ada berita. Tambahkan berita baru!'
                            : 'Berita tidak ditemukan.'),
                      )
                    : _isGrid
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final item = filtered[i];
                              return BeritaCard(
                                berita: item,
                                onTap: () => _openNewsDetail(item),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final item = filtered[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: BeritaCard(
                                  berita: item,
                                  onTap: () => _openNewsDetail(item),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // ---------------- MAIN BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,

      appBar: _selectedIndex == 0
          ? _buildHomeAppBar()
          : null, // FIX: Tidak ada lagi _buildProfileAppBar

      body: _selectedIndex == 0
          ? _buildHomeContent()
          : const ProfileScreen(),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNewsScreen()),
                );

                if (mounted) {
                  context.read<NewsProvider>().loadNews(context);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Berita'),
              backgroundColor: AppColors.primaryRed,
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _searchBar() => TextField(
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
        onChanged: (v) => setState(() => searchQuery = v),
      );

  void _openNewsDetail(Berita berita) {
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
}
