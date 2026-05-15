import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../ledger/domain/member_ledger_statement.dart';
import '../../members/data/member_management_repository.dart';
import '../../members/domain/member_management_models.dart';

class LandingHeroSummaryController extends ChangeNotifier {
  LandingHeroSummaryController({
    required MemberLedgerRepository ledgerRepository,
    required MemberManagementRepository memberRepository,
  }) : _ledgerRepository = ledgerRepository,
       _memberRepository = memberRepository;

  final MemberLedgerRepository _ledgerRepository;
  final MemberManagementRepository _memberRepository;

  bool _isLoading = false;
  String? _errorMessage;
  num _totalCapital = 0;
  num _weeklyAdded = 0;
  int _activeMemberCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  num get totalCapital => _totalCapital;
  num get weeklyAdded => _weeklyAdded;
  int get activeMemberCount => _activeMemberCount;

  Future<void> load({
    required bool canViewCapitalSummary,
    required bool canViewMembers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (canViewCapitalSummary) {
        final AdminLedgerStatement statement = await _ledgerRepository
            .adminLedger(const MemberLedgerFilter());
        _totalCapital = _capitalFromLedger(statement);
        _weeklyAdded = _weeklyAddedFromLedger(statement.entries);
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

  num _capitalFromLedger(AdminLedgerStatement statement) {
    final num totalIn = num.tryParse(statement.totalIn) ?? 0;
    final num totalOut = num.tryParse(statement.totalOut) ?? 0;
    return totalOut < 0 ? totalIn + totalOut : totalIn - totalOut.abs();
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
}
