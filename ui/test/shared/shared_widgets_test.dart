import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/src/features/shared/widgets/app_data_table.dart';
import 'package:ui/src/features/shared/widgets/app_detail_row.dart';
import 'package:ui/src/features/shared/widgets/app_form_fields.dart';
import 'package:ui/src/features/shared/widgets/app_message_card.dart';
import 'package:ui/src/features/shared/widgets/status_pills.dart';

void main() {
  testWidgets('AppMessageCard renders title and message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppMessageCard(
            title: 'Saved',
            message: 'The request was saved.',
            tone: AppMessageTone.success,
          ),
        ),
      ),
    );

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('The request was saved.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('AppDetailRow renders label and value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppDetailRow(
            label: 'Account',
            value: 'Primary Capital',
            icon: Icons.account_balance_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Primary Capital'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
  });

  testWidgets('AppStatusPill renders label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppStatusPill(label: 'APPROVED')),
      ),
    );

    expect(find.text('APPROVED'), findsOneWidget);
  });

  testWidgets('shared form fields render and accept input', (
    WidgetTester tester,
  ) async {
    final TextEditingController textController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    addTearDown(textController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              AppTextFormField(
                controller: textController,
                label: 'Name',
                icon: Icons.person_outline,
              ),
              AppPasswordField(
                controller: passwordController,
                label: 'Password',
                obscureText: true,
                onToggleVisibility: () {},
              ),
              AppDropdownField<String>(
                label: 'Role',
                value: 'member',
                values: const <String>['member', 'staff'],
                labelBuilder: (String value) => value,
                onChanged: (_) {},
              ),
              AppDateField(
                value: DateTime(2026, 5, 15),
                onTap: () {},
                label: 'Join Date',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Amina');
    expect(textController.text, 'Amina');
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('member'), findsOneWidget);
    expect(find.text('Join Date: 2026-05-15'), findsOneWidget);
  });

  testWidgets('shared table widgets render cells and sortable header', (
    WidgetTester tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              AppTableHeader(
                cells: <Widget>[
                  const AppHeaderCell('Name'),
                  AppSortableHeaderCell<String>(
                    text: 'Amount',
                    field: 'amount',
                    active: 'name',
                    ascending: true,
                    onTap: (String value) => selected = value,
                  ),
                ],
              ),
              const AppTableRow(
                cells: <Widget>[AppTextCell('Capital'), AppMoneyCell('-1250')],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Capital'), findsOneWidget);
    expect(find.text('-৳1,250.00'), findsOneWidget);

    await tester.tap(find.text('Amount'));
    expect(selected, 'amount');
  });
}
