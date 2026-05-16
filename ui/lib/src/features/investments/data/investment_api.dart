import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../shared/finance.dart';
import '../domain/investment_close_request.dart';
import '../domain/investment_capital_summary.dart';
import '../domain/investment_create_request.dart';
import '../domain/investment_detail.dart';
import '../domain/investment_distribution_record.dart';

class InvestmentApi {
  const InvestmentApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Investment>> list({
    InvestmentStatus? status,
    String? investmentType,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      if (status != null) 'status': status.label,
      if (investmentType?.trim().isNotEmpty ?? false)
        'investment_type': investmentType!.trim(),
    };
    final Uri uri = Uri(
      path: '/investments/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    final Object? data = response['data'];
    final Object? payload = data ?? response['results'] ?? response['items'];
    final List<dynamic> items = payload is List<dynamic>
        ? payload
        : <dynamic>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(_investmentFromJson)
        .toList();
  }

  Future<InvestmentCapitalSummary> capitalSummary() async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/investments/capital-summary/',
    );
    final Object? data = response['data'];
    final Map<String, dynamic> payload = data is Map<String, dynamic>
        ? data
        : response;
    final Object? summary = payload['summary'];
    return InvestmentCapitalSummary.fromJson(
      summary is Map<String, dynamic> ? summary : payload,
    );
  }

  Future<InvestmentDetail> detail(String investmentId) async {
    final String encodedId = Uri.encodeComponent(investmentId.trim());
    final Map<String, dynamic> response = await _apiClient.get(
      '/investments/$encodedId/',
    );
    final Object? data = response['data'];
    return _detailFromJson(data is Map<String, dynamic> ? data : response);
  }

  Future<Investment> create(InvestmentCreateRequest request) async {
    final Map<String, dynamic> response = await _apiClient.post(
      '/investments/',
      body: request.toJson(),
    );
    final Object? data = response['data'];
    return _investmentFromJson(data is Map<String, dynamic> ? data : response);
  }

  Future<InvestmentDetail> releaseFunds(String investmentId) async {
    final String encodedId = Uri.encodeComponent(investmentId.trim());
    final Map<String, dynamic> response = await _apiClient.post(
      '/investments/$encodedId/release-funds/',
      body: <String, dynamic>{},
    );
    final Object? data = response['data'];
    return _detailFromJson(data is Map<String, dynamic> ? data : response);
  }

  Future<InvestmentDetail> closeInvestment(
    String investmentId,
    InvestmentCloseRequest request,
  ) async {
    final String encodedId = Uri.encodeComponent(investmentId.trim());
    final Map<String, dynamic> response = await _apiClient.post(
      '/investments/$encodedId/close/',
      body: request.toJson(),
    );
    final Object? data = response['data'];
    return _detailFromJson(data is Map<String, dynamic> ? data : response);
  }

  Future<InvestmentDetail> distribute(String investmentId) async {
    final String encodedId = Uri.encodeComponent(investmentId.trim());
    final Map<String, dynamic> response = await _apiClient.post(
      '/investments/$encodedId/distribute/',
      body: <String, dynamic>{},
    );
    final Object? data = response['data'];
    return _detailFromJson(data is Map<String, dynamic> ? data : response);
  }

  Future<void> delete(String investmentId) async {
    final String encodedId = Uri.encodeComponent(investmentId.trim());
    await _apiClient.delete('/investments/$encodedId/');
  }

  Future<List<InvestmentDistributionRecord>> distributionRecords(
    String investmentId, {
    InvestmentDistributionStatus? status,
  }) async {
    final String encodedId = Uri.encodeComponent(investmentId.trim());
    final Uri uri = Uri(
      path: '/investments/$encodedId/distribution/',
      queryParameters: status == null
          ? null
          : <String, String>{'status': status.label},
    );

    try {
      final Map<String, dynamic> response = await _apiClient.get(
        uri.toString(),
      );
      final Object? data = response['data'];
      final Object? payload = data ?? response['results'] ?? response['items'];
      final List<dynamic> items = payload is List<dynamic>
          ? payload
          : <dynamic>[];

      return items
          .whereType<Map<String, dynamic>>()
          .map(_distributionRecordFromJson)
          .toList();
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return <InvestmentDistributionRecord>[];
      }
      rethrow;
    }
  }

  Investment _investmentFromJson(Map<String, dynamic> json) {
    return Investment(
      id: '${json['investment_id'] ?? json['id'] ?? ''}',
      title: '${json['title'] ?? 'Untitled investment'}',
      to: '${json['invested_to'] ?? ''}',
      amount: num.tryParse('${json['invested_amount'] ?? 0}') ?? 0,
      pnl: _optionalNumber(json['pnl_amount']),
      status: _statusFromApi(json['status']),
      date: '${json['created_date'] ?? ''}',
    );
  }

  InvestmentDetail _detailFromJson(Map<String, dynamic> json) {
    final Object? createdBy = json['created_by'];
    final Object? fundReleasedBy = json['fund_released_by'];
    return InvestmentDetail(
      id: '${json['investment_id'] ?? json['id'] ?? ''}',
      title: '${json['title'] ?? 'Untitled investment'}',
      investmentType: '${json['investment_type'] ?? ''}',
      investedTo: '${json['invested_to'] ?? ''}',
      investedAmount: '${json['invested_amount'] ?? '0.00'}',
      createdDate: '${json['created_date'] ?? ''}',
      comment: '${json['comment'] ?? ''}',
      status: _statusFromApi(json['status']),
      fundReleasedAt: DateTime.tryParse('${json['fund_released_at'] ?? ''}'),
      fundReleasedBy: fundReleasedBy is Map<String, dynamic>
          ? InvestmentCreatedBy(
              userId: '${fundReleasedBy['user_id'] ?? ''}',
              fullName: '${fundReleasedBy['full_name'] ?? ''}',
            )
          : null,
      closeDate: _optionalText(json['close_date']),
      returnAmount: _optionalText(json['return_amount']),
      pnlAmount: _optionalText(json['pnl_amount']),
      closureComment: '${json['closure_comment'] ?? ''}',
      hasSnapshot: json['has_snapshot'] == true,
      createdBy: createdBy is Map<String, dynamic>
          ? InvestmentCreatedBy(
              userId: '${createdBy['user_id'] ?? ''}',
              fullName: '${createdBy['full_name'] ?? ''}',
            )
          : null,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  InvestmentDistributionRecord _distributionRecordFromJson(
    Map<String, dynamic> json,
  ) {
    final Object? postedBy = json['posted_by'];
    final Object? reversedBy = json['reversed_by'];
    final Object? rawLines = json['lines'];
    final List<dynamic> lines = rawLines is List<dynamic>
        ? rawLines
        : <dynamic>[];

    return InvestmentDistributionRecord(
      distributionId: '${json['distribution_id'] ?? ''}',
      investmentId: '${json['investment_id'] ?? ''}',
      snapshotId: '${json['snapshot_id'] ?? ''}',
      pnlAmount: '${json['pnl_amount'] ?? '0.00'}',
      roundedTotal: '${json['rounded_total'] ?? '0.00'}',
      remainderApplied: '${json['remainder_applied'] ?? '0.00'}',
      status: _distributionStatusFromApi(json['status']),
      postedBy: postedBy is Map<String, dynamic>
          ? _distributionUserFromJson(postedBy)
          : null,
      postedAt: DateTime.tryParse('${json['posted_at'] ?? ''}'),
      reversedBy: reversedBy is Map<String, dynamic>
          ? _distributionUserFromJson(reversedBy)
          : null,
      reversedAt: DateTime.tryParse('${json['reversed_at'] ?? ''}'),
      lines: lines
          .whereType<Map<String, dynamic>>()
          .map(_distributionLineFromJson)
          .toList(),
    );
  }

  InvestmentDistributionUser _distributionUserFromJson(
    Map<String, dynamic> json,
  ) {
    return InvestmentDistributionUser(
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
    );
  }

  InvestmentDistributionLine _distributionLineFromJson(
    Map<String, dynamic> json,
  ) {
    return InvestmentDistributionLine(
      distributionLineId: '${json['distribution_line_id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      ratioUsed: '${json['ratio_used'] ?? ''}',
      shareAmount: '${json['share_amount'] ?? '0.00'}',
      ledgerEntryId: '${json['ledger_entry_id'] ?? ''}',
    );
  }

  num? _optionalNumber(Object? value) {
    if (value == null) {
      return null;
    }
    return num.tryParse('$value');
  }

  String? _optionalText(Object? value) {
    if (value == null) {
      return null;
    }
    final String text = '$value'.trim();
    return text.isEmpty ? null : text;
  }

  InvestmentStatus _statusFromApi(Object? value) {
    return switch ('$value'.trim().toUpperCase()) {
      'OPEN' => InvestmentStatus.open,
      'CLOSED' => InvestmentStatus.closed,
      'DISTRIBUTED' => InvestmentStatus.distributed,
      'REVERSED' => InvestmentStatus.reversed,
      _ => InvestmentStatus.draft,
    };
  }

  InvestmentDistributionStatus _distributionStatusFromApi(Object? value) {
    return switch ('$value'.trim().toUpperCase()) {
      'REVERSED' => InvestmentDistributionStatus.reversed,
      _ => InvestmentDistributionStatus.posted,
    };
  }
}
