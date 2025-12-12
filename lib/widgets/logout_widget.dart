// lib/widgets/logout_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LogoutWidget {
  static Future<void> confirmAndLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }
}

class LogoutIconButton extends StatelessWidget {
  final Color? color;
  const LogoutIconButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout, color: color ?? Colors.red),
      onPressed: () => LogoutWidget.confirmAndLogout(context),
    );
  }
}

// TAMBAHKAN INI!
class LogoutListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;

  const LogoutListTile({super.key, this.leading, this.title = 'Logout', this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ?? const Icon(Icons.logout),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: () => LogoutWidget.confirmAndLogout(context),
    );
  }
}