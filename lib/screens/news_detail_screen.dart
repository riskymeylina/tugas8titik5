import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/news_model.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'edit_news_screen.dart';

class NewsDetailScreen extends StatefulWidget {
  final Berita berita;
  const NewsDetailScreen({super.key, required this.berita});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  List<Comment> comments = [];
  bool loadingComments = true;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadComments());
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // --- LOGIKA CRUD KOMENTAR ---

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() => loadingComments = true);
    final auth = context.read<AuthProvider>();
    try {
      final fetchedComments = await ApiService.getComments(widget.berita.id, auth.token ?? '');
      if (mounted) setState(() => comments = fetchedComments);
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      if (mounted) setState(() => loadingComments = false);
    }
  }

  Future<void> _postComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      _showSnackBar("Silakan login terlebih dahulu");
      return;
    }

    final success = await ApiService.addComment(
      newsId: widget.berita.id,
      content: text,
      token: auth.token!,
    );

    if (success) {
      commentController.clear();
      FocusScope.of(context).unfocus();
      _loadComments();
    }
  }

  void _showEditCommentDialog(Comment comment) {
    final editController = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Komentar"),
        content: TextField(controller: editController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final success = await ApiService.updateComment(
                commentId: comment.id,
                content: editController.text,
                token: auth.token!,
              );
              if (success && mounted) {
                Navigator.pop(ctx);
                _loadComments();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Komentar"),
        content: const Text("Yakin ingin menghapus komentar ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = context.read<AuthProvider>();
      final success = await ApiService.deleteComment(commentId, auth.token!);
      if (success) _loadComments();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isLoggedIn = auth.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isLoggedIn && auth.userId == widget.berita.userId)
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue, size: 32),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditNewsScreen(berita: widget.berita)),
                );
                if (result == true) _loadComments();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.berita.judul, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildMetaInfo(),
                  const SizedBox(height: 20),
                  _buildMainImage(),
                  const SizedBox(height: 20),
                  Text(widget.berita.deskripsiLengkap, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const Divider(height: 40),
                  _buildCommentSection(auth),
                ],
              ),
            ),
          ),
          if (isLoggedIn) _buildBottomInput(),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 5),
        Text(widget.berita.waktu, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMainImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(widget.berita.gambarUrl, fit: BoxFit.cover, width: double.infinity, height: 200),
    );
  }

  Widget _buildCommentSection(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Komentar (${comments.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        if (loadingComments)
          const Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          const Text("Belum ada komentar.")
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) => _buildCommentItem(comments[index], auth),
          ),
      ],
    );
  }

  Widget _buildCommentItem(Comment c, AuthProvider auth) {
    final bool isOwner = auth.isAuthenticated && auth.userId == c.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // MEMPERBAIKI ERROR 'between'
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(c.username, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'e' ? _showEditCommentDialog(c) : _confirmDeleteComment(c.id),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'e', child: Text("Edit")),
                    const PopupMenuItem(value: 'd', child: Text("Hapus", style: TextStyle(color: Colors.red))),
                  ],
                  child: const Icon(Icons.more_vert, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(c.content),
        ],
      ),
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: const InputDecoration(hintText: "Tulis komentar...", border: InputBorder.none),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _postComment),
        ],
      ),
    );
  }
}