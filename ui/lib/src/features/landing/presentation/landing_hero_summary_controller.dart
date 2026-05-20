import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../ledger/domain/member_ledger_statement.dart';
import '../../members/data/member_management_repository.dart';
import '../../members/domain/member_management_models.dart';
import '../../reports/data/staff_report_repository.dart';
import '../../reports/domain/staff_report_models.dart';

class LandingHeroSummaryController extends ChangeNotifier {
  LandingHeroSummaryController({
    required MemberLedgerRepository ledgerRepository,
    required MemberManagementRepository memberRepository,
    required StaffReportRepository staffReportRepository,
  }) : _ledgerRepository = ledgerRepository,
       _memberRepository = memberRepository,
       _staffReportRepository = staffReportRepository;

  final MemberLedgerRepository _ledgerRepository;
  final MemberManagementRepository _memberRepository;
  final StaffReportRepository _staffReportRepository;

  bool _isLoading = false;
  String? _errorMessage;
  num _totalCapital = 0;
  num _weeklyAdded = 0;
  int _activeMemberCount = 0;
  MemberLedgerStatement? _memberStatement;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  num get totalCapital => _totalCapital;
  num get weeklyAdded => _weeklyAdded;
  int get activeMemberCount => _activeMemberCount;
  MemberLedgerStatement? get memberStatement => _memberStatement;
  num get memberCapital => _amount(_memberStatement?.capitalBalance);
  num get memberProfitWallet => _amount(_memberStatement?.profitWalletBalance);
  num get memberTotalAmount => _amount(_memberStatement?.totalAmount);

  Future<void> load({
    required bool canViewCapitalSummary,
    required bool canViewMembers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (canViewCapitalSummary) {
        final AssociationSummaryReport summary = await _staffReportRepository
            .associationSummary();
        _totalCapital = _amount(summary.capital.totalAuthorized);
        try {
          final AdminLedgerStatement statement = await _ledgerRepository
              .adminLedger(const MemberLedgerFilter());
          _weeklyAdded = _weeklyAddedFromLedger(statement.entries);
        } catch (_) {
          _weeklyAdded = 0;
        }
      } else {
        _memberStatement = await _ledgerRepository.statement(
          const MemberLedgerFilter(),
        );
      }

      if (canViewMembers) {
        final List<ManagedUser> activeMembers = await _memberRepository.list(
          filter: const ManagedUserFilter(status: ManagedUserStatus.active),
        );
        _activeMemberCount = activeMembers.length;
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load dashboard summary.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  num _weeklyAddedFromLedger(List<MemberLedgerEntry> entries) {
    final DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
    return entries.fold<num>(0, (num sum, MemberLedgerEntry entry) {
      final DateTime? entryDate =
          entry.createdAt ?? _parseTxnDate(entry.txnDate);
      final num amount = num.tryParse(entry.amount) ?? 0;
      if (entryDate == null || entryDate.isBefore(cutoff) || amount <= 0) {
        return sum;
      }
      if (entry.entryType != MemberLedgerEntryType.submission) {
        return sum;
      }
      return sum + amount;
    });
  }

  DateTime? _parseTxnDate(String value) {
    return DateTime.tryParse(value.trim());
  }

  num _amount(String? value) {
    return num.tryParse(value ?? '') ?? 0;
  }
}
