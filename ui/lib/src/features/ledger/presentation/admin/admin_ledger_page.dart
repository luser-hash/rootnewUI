import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../shared/finance.dart';
import '../../../shared/widgets/app_card_list.dart';
import '../../../shared/widgets/app_data_table.dart';
import '../../../shared/widgets/app_detail_block.dart';
import '../../../shared/widgets/app_message_card.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../data/member_ledger_repository.dart';
import '../../domain/member_ledger_statement.dart';
import '../admin_ledger_controller.dart';

part 'admin_ledger_header.dart';
part 'admin_ledger_post_sheet.dart';
part 'admin_ledger_filters.dart';
part 'admin_ledger_row.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key, required this.repository});

  final MemberLedgerRepository repository;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late final AdminLedgerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminLedgerController(repository: widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final AdminLedgerStatement? statement = _controller.statement;
        return Column(
          children: <Widget>[
            _LedgerHeaderContent(
              statement: statement,
              isPosting: _controller.isPosting,
              onAdd: _showAdminPostSheet,
            ),
            _LedgerFilters(
              filter: _controller.filter,
              onChanged: (MemberLedgerFilter filter) {
                _controller.load(filter: filter);
              },
              onClear: _controller.filter.hasFilters
                  ? _controller.clearFilters
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
              child: _buildBody(statement),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(AdminLedgerStatement? statement) {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return AppMessageCard(
        icon: Icons.error_outline,
        message: error,
        tone: AppMessageTone.error,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        borderRadius: 18,
      );
    }

    final List<MemberLedgerEntry> entries =
        statement?.entries ?? <MemberLedgerEntry>[];
    if (entries.isEmpty) {
      return const AppMessageCard(
        icon: Icons.menu_book_outlined,
        message: 'No ledger entries found.',
        tone: AppMessageTone.neutral,
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(18),
        borderRadius: 18,
      );
    }

    return AppCardList(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      children: entries
          .asMap()
          .entries
          .map(
            (MapEntry<int, MemberLedgerEntry> entry) => _LedgerRow(
              entry: entry.value,
              isLast: entry.key == entries.length - 1,
            ),
          )
          .toList(),
    );
  }

  Future<void> _showAdminPostSheet() async {
    final AdminLedgerPostResult? result =
        await showModalBottomSheet<AdminLedgerPostResult>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppThemeColors.card(context),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (BuildContext context) {
            return _AdminLedgerPostSheet(
              onSubmit: _controller.adminPost,
              errorMessage: () => _controller.postErrorMessage,
            );
          },
        );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ledger entry posted. New balance ${result.newBalance}.'),
      ),
    );
  }
}
