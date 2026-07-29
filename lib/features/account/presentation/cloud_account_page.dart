import 'package:flutter/material.dart';

import 'cloud_account_controller.dart';

class CloudAccountPage extends StatefulWidget {
  const CloudAccountPage({required this.controller, super.key});

  final CloudAccountController controller;

  @override
  State<CloudAccountPage> createState() => _CloudAccountPageState();
}

class _CloudAccountPageState extends State<CloudAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    await widget.controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (widget.controller.isSignedIn) {
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'حساب و فضای ابری',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'استفاده از برنامه بدون حساب همچنان ممکن است. حساب ابری برای پشتیبان‌گیری و ارتباط مربی و شاگرد اضافه می‌شود.',
            ),
            const SizedBox(height: 20),
            if (!widget.controller.isAvailable)
              _UnavailableCard(error: widget.controller.error)
            else if (widget.controller.isSignedIn)
              _SignedInCard(controller: widget.controller)
            else
              _SignInCard(
                controller: widget.controller,
                emailController: _emailController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onSubmit: _signIn,
              ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'وضعیت همگام‌سازی',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اتصال حساب آماده است. داده‌های فعلی همچنان فقط در SQLite گوشی نگهداری می‌شوند و تا تکمیل موتور Sync چیزی خودکار روی سرور ارسال نمی‌شود.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.controller,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final CloudAccountController controller;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final String? errorMessage = _friendlyError(controller.error);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'ورود مربی',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('با همان ایمیل و رمزی که در Supabase ساخته شده وارد شوید.'),
              const SizedBox(height: 18),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                autofillHints: const <String>[AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'ایمیل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textDirection: TextDirection.ltr,
                autofillHints: const <String>[AutofillHints.password],
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: 'رمز عبور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              if (errorMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.isBusy ? null : onSubmit,
                icon: controller.isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('ورود به حساب ابری'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({required this.controller});

  final CloudAccountController controller;

  @override
  Widget build(BuildContext context) {
    final String title = controller.displayName.isNotEmpty
        ? controller.displayName
        : controller.email;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.cloud_done_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        controller.username.isEmpty
                            ? controller.email
                            : '@${controller.username}',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _AccountRow(label: 'نقش حساب', value: _roleLabel(controller.role)),
            _AccountRow(label: 'ایمیل', value: controller.email, ltr: true),
            _AccountRow(
              label: 'پذیرش شاگرد جدید',
              value: controller.acceptingClients ? 'فعال' : 'غیرفعال',
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: controller.isBusy ? null : controller.refreshProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('به‌روزرسانی پروفایل'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: controller.isBusy ? null : controller.signOut,
              icon: const Icon(Icons.logout),
              label: const Text('خروج از حساب'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'اتصال ابری آماده نشد',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _friendlyError(error) ?? 'برنامه در حالت آفلاین قابل استفاده است.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'coach':
      return 'مربی';
    case 'athlete':
      return 'شاگرد';
    case 'admin':
      return 'مدیر';
    default:
      return role;
  }
}

String? _friendlyError(Object? error) {
  if (error == null) {
    return null;
  }
  final String message = error.toString();
  if (message.contains('Invalid login credentials')) {
    return 'ایمیل یا رمز عبور صحیح نیست.';
  }
  if (message.contains('SocketException') || message.contains('Failed host')) {
    return 'اتصال اینترنت برقرار نیست. اطلاعات محلی برنامه همچنان در دسترس است.';
  }
  if (message.contains('ArgumentError')) {
    return 'ایمیل و رمز عبور را کامل وارد کنید.';
  }
  return message;
}
