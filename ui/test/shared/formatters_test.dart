import 'package:flutter_test/flutter_test.dart';
import 'package:root_finance_ui/src/features/shared/finance.dart';

void main() {
  group('money formatters', () {
    test('formatMoneySigned preserves negative signs', () {
      expect(formatMoneySigned(-1234.5), '-৳1,234.50');
      expect(formatMoneySigned(1234.5), '৳1,234.50');
      expect(formatMoneySigned(0), '৳0.00');
    });

    test('formatMoneyUnsigned always formats absolute values', () {
      expect(formatMoneyUnsigned(-1234567.8), '৳12,34,567.80');
      expect(formatMoneyUnsigned(1234567.8), '৳12,34,567.80');
      expect(formatMoneyTextUnsigned('-2500'), '৳2,500.00');
    });

    test('formatMoneyCompactSigned preserves signs for compact values', () {
      expect(formatMoneyCompactSigned(-1250), '-৳1.3K');
      expect(formatMoneyCompactSigned(1250), '৳1.3K');
      expect(formatMoneyCompactSigned(999), '৳999');
    });
  });

  group('text formatters', () {
    test('valueOrDash returns dash for blank values', () {
      expect(valueOrDash(null), '-');
      expect(valueOrDash(''), '-');
      expect(valueOrDash('   '), '-');
      expect(valueOrDash('Capital'), 'Capital');
    });

    test('prettyEnumLabel converts enum-like values to labels', () {
      expect(prettyEnumLabel('BANK_TRANSFER'), 'Bank Transfer');
      expect(prettyEnumLabel(' pending_review '), 'Pending Review');
      expect(prettyEnumLabel(''), '-');
    });
  });

  group('date formatters', () {
    test('formatDateTimeShort returns dash for null values', () {
      expect(formatDateTimeShort(null), '-');
    });
  });
}
