import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cloud_account_service.dart';
import 'cloud_account_controller.dart';

class CloudAccountPage extends StatefulWidget {
  const CloudAccountPage({required this.controller, super.key});

  final CloudAccountController controller;

  @override
  State<CloudAccountPage> createState() => _CloudAccountPageState();
}

class _CloudAccountPageState extends State<CloudAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    await widget.controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    if (widget.controller.isSignedIn) {
      TextInput.finishAutofillContext();
      _passwordController.clear();
    }
  }

  Future<void> _confirmSignOut() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('خروج از حساب ابری'),
            content: const Text(
              'اطلاعات محلی و شاگردهای ذخیره‌شده روی گوشی حذف نمی‌شوند.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('خروج'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await widget.controller.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final CloudAccountController controller = widget.controller;
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
              'حساب ابری اختیاری است. برنامه، شاگردها و کتابخانه آفلاین بدون ورود هم کار می‌کنند.',
            ),
            const SizedBox(height: 20),
            if (!controller.isAvailable)
              _UnavailableCard(error: controller.error)
            else if (controller.phase == CloudAccountPhase.restoring)
              const _AccountProgressCard(
                title: 'در حال بررسی حساب',
                description: 'جلسه ذخیره‌شده و مجوز مربی در حال بررسی است.',
              )
            else if (controller.phase == CloudAccountPhase.signingOut)
              const _AccountProgressCard(
                title: 'در حال خروج',
                description: 'جلسه محلی حساب در حال بسته‌شدن است.',
              )
            else if (controller.isSignedIn)
              _SignedInCard(controller: controller, onSignOut: _confirmSignOut)
            else if (controller.hasSession)
              _SessionRecoveryCard(
                controller: controller,
                onSignOut: _confirmSignOut,
              )
            else
              _SignInCard(
                formKey: _formKey,
                controller: controller,
                emailController: _emailController,
                passwordController: _passwordController,
                passwordFocus: _passwordFocus,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onSubmit: _signIn,
              ),
            const SizedBox(height: 16),
            const _OfflineSafetyCard(),
          ],
        );
      },
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.formKey,
    required this.controller,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final CloudAccountController controller;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
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
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'ورود مربی',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'فقط حساب دارای نقش مربی یا مدیر اجازه اتصال به این اپ را دارد.',
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const <String>[AutofillHints.email],
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: (String? value) {
                    final String email = value?.trim() ?? '';
                    final int at = email.indexOf('@');
                    final int dot = email.lastIndexOf('.');
                    if (at <= 0 || dot <= at + 1 || dot >= email.length - 1) {
                      return 'ایمیل معتبر وارد کنید.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'ایمیل',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const <String>[AutofillHints.password],
                  validator: (String? value) => value == null || value.isEmpty
                      ? 'رمز عبور را وارد کنید.'
                      : null,
                  onFieldSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? 'نمایش رمز عبور'
                          : 'پنهان‌کردن رمز عبور',
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                if (errorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _InlineError(message: errorMessage),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: controller.isBusy ? null : onSubmit,
                  icon: controller.phase == CloudAccountPhase.signingIn
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
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({required this.controller, required this.onSignOut});

  final CloudAccountController controller;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final String title = controller.displayName.isNotEmpty
        ? controller.displayName
        : controller.email;
    final String? errorMessage = _friendlyError(controller.error);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.cloud_done_outlined),
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
                const Icon(Icons.verified_user_outlined),
              ],
            ),
            const SizedBox(height: 18),
            _AccountRow(label: 'نقش حساب', value: _roleLabel(controller.role)),
            _AccountRow(label: 'ایمیل', value: controller.email, ltr: true),
            _AccountRow(
              label: 'پذیرش شاگرد جدید',
              value: controller.acceptingClients ? 'فعال' : 'غیرفعال',
            ),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              _InlineError(message: errorMessage),
            ],
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: controller.isBusy ? null : controller.refreshProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('به‌روزرسانی پروفایل'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: controller.isBusy ? null : onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('خروج امن از حساب'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRecoveryCard extends StatelessWidget {
  const _SessionRecoveryCard({
    required this.controller,
    required this.onSignOut,
  });

  final CloudAccountController controller;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.cloud_sync_outlined, size: 52),
            const SizedBox(height: 12),
            Text(
              'جلسه حساب روی دستگاه موجود است',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _friendlyError(controller.error) ??
                  'برای تأیید نقش مربی دوباره تلاش کنید.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.isBusy ? null : controller.refreshProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('بررسی دوباره حساب'),
            ),
            TextButton(
              onPressed: controller.isBusy ? null : onSignOut,
              child: const Text('خروج از این جلسه'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountProgressCard extends StatelessWidget {
  const _AccountProgressCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _OfflineSafetyCard extends StatelessWidget {
  const _OfflineSafetyCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
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
              'ورود به حساب داده‌های محلی را خودکار آپلود نمی‌کند. تا تکمیل موتور Sync، اطلاعات فعلی فقط در SQLite گوشی باقی می‌مانند.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.value,
    this.ltr = false,
  });

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
              _friendlyError(error) ??
                  'برنامه در حالت آفلاین قابل استفاده است.',
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
  if (error is CloudAccountException) {
    return error.message;
  }

  final String message = error.toString().toLowerCase();
  if (message.contains('invalid login credentials')) {
    return 'ایمیل یا رمز عبور صحیح نیست.';
  }
  if (message.contains('email not confirmed')) {
    return 'ایمیل این حساب هنوز تأیید نشده است.';
  }
  if (message.contains('socketexception') ||
      message.contains('failed host') ||
      message.contains('network')) {
    return 'اتصال اینترنت برقرار نیست. اطلاعات محلی برنامه همچنان در دسترس است.';
  }
  if (message.contains('too many requests') || message.contains('rate limit')) {
    return 'تعداد تلاش‌ها بیش از حد مجاز است. چند دقیقه بعد دوباره امتحان کنید.';
  }
  return 'عملیات حساب کامل نشد. اتصال اینترنت و اطلاعات ورود را بررسی کنید.';
}
