// lib/screens/news_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/news_model.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class NewsDetailScreen extends StatefulWidget {
  final Berita berita;
  const NewsDetailScreen({super.key, required this.berita});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  List<Comment> comments = [];
  bool loadingComments = true;
  final commentController = TextEditingController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => loadingComments = true);
    final auth = context.read<AuthProvider>();
    try {
      comments = await ApiService.getComments(widget.berita.id, auth.token ?? '');
    } catch (e) {
      comments = [];
    }
    setState(() => loadingComments = false);
  }

  Future<void> _postComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await ApiService.addComment(
      newsId: widget.berita.id,
      content: text,
      token: auth.token ?? '',
    );

    if (success) {
      commentController.clear();
      _loadComments();
    }
  }

  String _formatTimeAgo() {
    // Karena belum ada createdAt, kita pakai "baru saja"
    return "baru saja";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    String quote = widget.berita.deskripsiLengkap.split('.').first.trim();
    if (quote.isEmpty || quote.length < 10) {
      quote = "Berita terkini seputar olahraga dan dunia";
    };
    // print('Quote extracted: $widget.berita');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER ATAS (CNN Style)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red,
                        child: Text(
                          "C",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("posted by CNN Indonesia", style: TextStyle(fontSize: 15)),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Follow"),
                        style: OutlinedButton.styleFrom(
                          shape: StadiumBorder(),
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.berita.judul,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.2),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(widget.berita.waktu, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.berita.kategori ?? "Sports",
                          style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quote besar dengan garis merah
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(left: BorderSide(color: Colors.red, width: 6)),
                    ),
                    child: Text(
                      "“$quote”",
                      style: const TextStyle(fontSize: 21, fontStyle: FontStyle.italic, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // ISI BERITA + GAMBAR + KOMENTAR
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.berita.gambarUrl,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 240,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      widget.berita.deskripsiLengkap,
                      style: const TextStyle(fontSize: 17, height: 1.7),
                      maxLines: isExpanded ? null : 5,
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() => isExpanded = !isExpanded),
                        icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right),
                        label: Text(isExpanded ? "Show less" : "Read More"),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // TOMBOL KOMENTAR BESAR
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.comment_outlined),
                        label: Text("Komentar (${comments.length})", style: const TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text("Komentar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    if (loadingComments)
                      const Center(child: CircularProgressIndicator())
                    else if (comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.comment_outlined, size: 70, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Belum ada komentar", style: TextStyle(color: Colors.grey, fontSize: 16)),
                            Text("Jadilah yang pertama!", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      ...comments.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.red[100],
                                child: Text(
                                  c.username[0].toUpperCase(),
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(c.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(_formatTimeAgo(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(c.content),
                                  ],
                                ),
                              ),
                              // Tombol edit/hapus sementara dinonaktifkan karena belum tahu user
                              // Nanti kalau sudah ada auth.user, aktifkan lagi
                              // PopupMenuButton(
                              //   onSelected: (v) { ... },
                              //   itemBuilder: (_) => [ ... ],
                              // ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // INPUT KOMENTAR DI BAWAH (STICKY)
      bottomSheet: auth.isAuthenticated
          ? Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Tulis komentar...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.red,
                    onPressed: _postComment,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}