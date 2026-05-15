part of 'member_detail_screen.dart';

class _MemberLedgerSection extends StatelessWidget {
  const _MemberLedgerSection({required this.controller});

  final MemberDetailLedgerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const AppCardList(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    final String? error = controller.errorMessage;
    if (error != null) {
      return AppCardList(
        children: <Widget>[
          AppMessageCard(
            message: error,
            tone: AppMessageTone.neutral,
            background: Colors.transparent,
            textColor: AppThemeColors.textMuted(context),
            padding: const EdgeInsets.all(20),
            showBorder: false,
            showIcon: false,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final MemberLedgerStatement? statement = controller.statement;
    final List<MemberLedgerEntry> entries =
        statement?.entries ?? <MemberLedgerEntry>[];
    if (entries.isEmpty) {
      return AppCardList(
        children: <Widget>[
          AppMessageCard(
            message: 'No ledger entries yet.',
            tone: AppMessageTone.neutral,
            background: Colors.transparent,
            textColor: AppThemeColors.textMuted(context),
            padding: const EdgeInsets.all(20),
            showBorder: false,
            showIcon: false,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return AppCardList(
      children: entries
          .asMap()
          .entries
          .map(
            (MapEntry<int, MemberLedgerEntry> entry) => _MemberLedgerRow(
              statement: statement,
              entry: entry.value,
              isLast: entry.key == entries.length - 1,
            ),
          )
          .toList(),
    );
  }
}

class _MemberLedgerRow extends StatelessWidget {
  const _MemberLedgerRow({
    required this.statement,
    required this.entry,
    required this.isLast,
  });

  final MemberLedgerStatement? statement;
  final MemberLedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isLedgerInflow(entry.entryType, amount);
    final Color foreground = _ledgerEntryForeground(context, entry.entryType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLedgerDetails(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(color: AppThemeColors.border(context)),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _ledgerEntryBackground(context, entry.entryType),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _ledgerEntryIcon(entry.entryType),
                  size: 18,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.txnDate.isEmpty ? '-' : entry.txnDate,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.entryType.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${positive ? '+' : '-'}${formatMoneyTextUnsigned(entry.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: positive
                      ? AppThemeColors.statusSuccessFg(context)
                      : AppThemeColors.statusErrorFg(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLedgerDetails(BuildContext context) {
    final MemberLedgerUser? user = statement?.user;
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isLedgerInflow(entry.entryType, amount);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _ledgerEntryBackground(context, entry.entryType),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _ledgerEntryIcon(entry.entryType),
                        size: 18,
                        color: _ledgerEntryForeground(context, entry.entryType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            entry.entryType.label,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppThemeColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            valueOrDash(
                              user?.fullName.isNotEmpty == true
                                  ? user?.fullName
                                  : entry.memberName,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${positive ? '+' : '-'}${formatMoneyTextUnsigned(entry.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: positive
                        ? AppThemeColors.statusSuccessFg(context)
                        : AppThemeColors.statusErrorFg(context),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.45,
                  children: <Widget>[
                    AppDetailBlock(
                      label: 'Balance',
                      value: formatMoneyTextUnsigned(statement?.currentBalance),
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Pending',
                      value: formatMoneyTextUnsigned(statement?.pendingTotal),
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Entries',
                      value: '${statement?.entryCount ?? 0}',
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Currency',
                      value: entry.currency,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Txn Date',
                      value: valueOrDash(entry.txnDate),
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Created',
                      value: formatDateTimeShort(entry.createdAt),
                      center: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'User ID',
                  value: valueOrDash(user?.userId ?? entry.userId),
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Full Name',
                  value: valueOrDash(user?.fullName ?? entry.memberName),
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Contact No',
                  value: valueOrDash(user?.contactNo ?? entry.memberContact),
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Ledger ID',
                  value: entry.ledgerId,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Reference Type',
                  value: valueOrDash(entry.referenceType),
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Reference ID',
                  value: valueOrDash(entry.referenceId),
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Comment',
                  value: valueOrDash(entry.comment),
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Created By',
                  value: valueOrDash(entry.createdByName),
                  selectable: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
