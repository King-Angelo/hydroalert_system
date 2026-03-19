import 'package:flutter/material.dart';

import '../../../app_routes.dart';
import '../data/auth_service.dart';

class AdminAuthGatePage extends StatefulWidget {
  const AdminAuthGatePage({
    super.key,
    required this.authService,
    required this.builder,
  });

  final AuthService authService;
  final Widget Function(BuildContext context, String adminUserId) builder;

  @override
  State<AdminAuthGatePage> createState() => _AdminAuthGatePageState();
}

class _AdminAuthGatePageState extends State<AdminAuthGatePage> {
  bool _loading = true;
  String? _adminUserId;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final adminUserId = await widget.authService.getCurrentAdminUserId();
    if (!mounted) return;

    if (adminUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      setState(() {
        _loading = false;
        _adminUserId = null;
      });
      return;
    }

    setState(() {
      _adminUserId = adminUserId;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final adminUserId = _adminUserId;
    if (adminUserId == null) {
      return const Scaffold(
        body: SizedBox.expand(),
      );
    }

    return widget.builder(context, adminUserId);
  }
}
