part of 'admin_ledger_page.dart';

class _LedgerFilters extends StatefulWidget {
  const _LedgerFilters({
    required this.filter,
    required this.onChanged,
    required this.onClear,
  });

  final MemberLedgerFilter filter;
  final ValueChanged<MemberLedgerFilter> onChanged;
  final VoidCallback? onClear;

  @override
  State<_LedgerFilters> createState() => _LedgerFiltersState();
}

class _LedgerFiltersState extends State<_LedgerFilters> {
  late final TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(text: widget.filter.userId ?? '');
  }

  @override
  void didUpdateWidget(covariant _LedgerFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String nextUserId = widget.filter.userId ?? '';
    if (nextUserId != _userIdController.text) {
      _userIdController.text = nextUserId;
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MemberLedgerFilter filter = widget.filter;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<MemberLedgerEntryType?>(
            initialValue: filter.entryType,
            decoration: _fieldDecoration(
              context: context,
              label: 'Entry Type',
              icon: Icons.tune_rounded,
            ),
            items: <DropdownMenuItem<MemberLedgerEntryType?>>[
              const DropdownMenuItem<MemberLedgerEntryType?>(
                value: null,
                child: Text('All Types'),
              ),
              ...MemberLedgerEntryType.values.map(
                (MemberLedgerEntryType value) =>
                    DropdownMenuItem<MemberLedgerEntryType?>(
                      value: value,
                      child: Text(value.label),
                    ),
              ),
            ],
            onChanged: (MemberLedgerEntryType? entryType) {
              widget.onChanged(
                MemberLedgerFilter(
                  entryType: entryType,
                  walletType: filter.walletType,
                  fromDate: filter.fromDate,
                  toDate: filter.toDate,
                  userId: filter.userId,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<LedgerWalletType?>(
            initialValue: filter.walletType,
            decoration: _fieldDecoration(
              context: context,
              label: 'Wallet',
              icon: Icons.account_balance_wallet_outlined,
            ),
            items: <DropdownMenuItem<LedgerWalletType?>>[
              const DropdownMenuItem<LedgerWalletType?>(
                value: null,
                child: Text('All Wallets'),
              ),
              ...LedgerWalletType.values.map(
                (LedgerWalletType value) => DropdownMenuItem<LedgerWalletType?>(
                  value: value,
                  child: Text(value.label),
                ),
              ),
            ],
            onChanged: (LedgerWalletType? walletType) {
              widget.onChanged(
                MemberLedgerFilter(
                  entryType: filter.entryType,
                  walletType: walletType,
                  fromDate: filter.fromDate,
                  toDate: filter.toDate,
                  userId: filter.userId,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _DateFilterButton(
                  label: 'From',
                  value: filter.fromDate,
                  onTap: () => _pickDate(
                    context: context,
                    initialDate: filter.fromDate,
                    onPicked: (DateTime date) {
                      widget.onChanged(
                        MemberLedgerFilter(
                          entryType: filter.entryType,
                          walletType: filter.walletType,
                          fromDate: date,
                          toDate: filter.toDate,
                          userId: filter.userId,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateFilterButton(
                  label: 'To',
                  value: filter.toDate,
                  onTap: () => _pickDate(
                    context: context,
                    initialDate: filter.toDate,
                    onPicked: (DateTime date) {
                      widget.onChanged(
                        MemberLedgerFilter(
                          entryType: filter.entryType,
                          walletType: filter.walletType,
                          fromDate: filter.fromDate,
                          toDate: date,
                          userId: filter.userId,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (widget.onClear != null) ...<Widget>[
                const SizedBox(width: 8),
                Material(
                  color: AppThemeColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: widget.onClear,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 46,
                      height: 54,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _userIdController,
            decoration: _fieldDecoration(
              context: context,
              label: 'Member User ID',
              icon: Icons.person_search_rounded,
            ).copyWith(suffixIcon: _UserIdApplyButton(onTap: _applyUserId)),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _applyUserId(),
          ),
        ],
      ),
    );
  }

  void _applyUserId() {
    widget.onChanged(
      MemberLedgerFilter(
        entryType: widget.filter.entryType,
        walletType: widget.filter.walletType,
        fromDate: widget.filter.fromDate,
        toDate: widget.filter.toDate,
        userId: _userIdController.text.trim(),
      ),
    );
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      onPicked(picked);
    }
  }
}

class _UserIdApplyButton extends StatelessWidget {
  const _UserIdApplyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Apply member filter',
      icon: Icon(
        Icons.search_rounded,
        color: AppThemeColors.textMuted(context),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppThemeColors.textMuted(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                    Text(
                      value == null ? 'Any date' : _formatDate(value!),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.text(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
