import 'package:flutter/material.dart';

import '../domain/athlete.dart';
import 'athlete_form_page.dart';
import 'athletes_controller.dart';

class AthletesPage extends StatefulWidget {
  const AthletesPage({
    required this.controller,
    super.key,
  });

  final AthletesController controller;

  @override
  State<AthletesPage> createState() => _AthletesPageState();
}

class _AthletesPageState extends State<AthletesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final List<Athlete> visible = widget.controller.athletes.where((Athlete item) {
          final String query = _query.trim().toLowerCase();
          return query.isEmpty ||
              item.fullName.toLowerCase().contains(query) ||
              item.phone.contains(query) ||
              item.goal.toLowerCase().contains(query);
        }).toList(growable: false);

        return Scaffold(
          appBar: AppBar(
            title: const Text('شاگردان'),
            actions: <Widget>[
              IconButton(
                tooltip: 'تازه‌سازی',
                onPressed: widget.controller.isLoading ? null : widget.controller.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('شاگرد جدید'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  onChanged: (String value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'جست‌وجوی نام، شماره یا هدف',
                  ),
                ),
              ),
              Expanded(child: _buildBody(context, visible)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, List<Athlete> athletes) {
    if (widget.controller.isLoading && athletes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.controller.error != null && athletes.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline,
        title: 'خواندن اطلاعات انجام نشد',
        actionLabel: 'تلاش دوباره',
        onAction: widget.controller.load,
      );
    }

    if (athletes.isEmpty) {
      return _EmptyState(
        icon: Icons.group_add_outlined,
        title: _query.isEmpty ? 'هنوز شاگردی ثبت نشده' : 'نتیجه‌ای پیدا نشد',
        actionLabel: _query.isEmpty ? 'ثبت اولین شاگرد' : null,
        onAction: _query.isEmpty ? () => _openForm(context) : null,
      );
    }

    return RefreshIndicator(
      onRefresh: widget.controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: athletes.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (BuildContext context, int index) {
          final Athlete athlete = athletes[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                child: Text(athlete.fullName.trim().isEmpty ? '؟' : athlete.fullName.trim()[0]),
              ),
              title: Text(
                athlete.fullName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                <String>[
                  athlete.trainingLevel.label,
                  if (athlete.goal.isNotEmpty) athlete.goal,
                ].join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _openForm(context, athlete: athlete),
              onLongPress: () => _confirmArchive(context, athlete),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Athlete? athlete}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AthleteFormPage(
          controller: widget.controller,
          athlete: athlete,
        ),
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context, Athlete athlete) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('بایگانی شاگرد'),
        content: Text('«${athlete.fullName}» از فهرست فعال خارج شود؟ اطلاعات حذف نمی‌شود.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('بایگانی'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.controller.archive(athlete);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
