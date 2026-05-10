import '../../../../core/network/api_client.dart';
import '../../shared/finance.dart';
import '../domain/investment_close_request.dart';
import '../domain/investment_create_request.dart';
import '../domain/investment_detail.dart';

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
      fundReleasedBy: _optionalText(json['fund_released_by']),
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
}
