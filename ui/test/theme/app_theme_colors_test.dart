import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/core/theme/app_theme.dart';

void main() {
  testWidgets('light theme semantic colors preserve existing app colors', (
    WidgetTester tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(AppThemeColors.background(capturedContext), AppColors.bg);
    expect(AppThemeColors.surface(capturedContext), AppColors.surface);
    expect(AppThemeColors.card(capturedContext), AppColors.card);
    expect(AppThemeColors.text(capturedContext), AppColors.text);
    expect(AppThemeColors.textMid(capturedContext), AppColors.textMid);
    expect(AppThemeColors.textMuted(capturedContext), AppColors.textMute);
    expect(AppThemeColors.border(capturedContext), AppColors.border);
    expect(AppThemeColors.divider(capturedContext), AppColors.border);
    expect(
      AppThemeColors.statusSuccess(capturedContext).background,
      AppColors.greenLt,
    );
    expect(
      AppThemeColors.statusSuccess(capturedContext).foreground,
      AppColors.green,
    );
  });

  testWidgets('dark theme semantic colors use dark-mode token values', (
    WidgetTester tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (BuildContext context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      AppThemeColors.background(capturedContext),
      AppThemeTokens.darkBackground,
    );
    expect(AppThemeColors.surface(capturedContext), AppThemeTokens.darkSurface);
    expect(AppThemeColors.card(capturedContext), AppThemeTokens.darkCard);
    expect(
      AppThemeColors.elevatedSurface(capturedContext),
      AppThemeTokens.darkElevatedSurface,
    );
    expect(AppThemeColors.text(capturedContext), AppThemeTokens.darkText);
    expect(AppThemeColors.textMid(capturedContext), AppThemeTokens.darkTextMid);
    expect(
      AppThemeColors.textMuted(capturedContext),
      AppThemeTokens.darkTextMuted,
    );
    expect(AppThemeColors.border(capturedContext), AppThemeTokens.darkBorder);
    expect(AppThemeColors.divider(capturedContext), AppThemeTokens.darkDivider);
    expect(
      AppThemeColors.statusSuccess(capturedContext).background,
      isNot(AppColors.greenLt),
    );
    expect(
      AppThemeColors.statusError(capturedContext).background,
      isNot(AppColors.redLt),
    );
    expect(
      AppThemeColors.statusWarning(capturedContext).background,
      isNot(AppColors.amberLt),
    );
    expect(
      AppThemeColors.statusInfo(capturedContext).background,
      isNot(AppColors.blueLt),
    );
  });
}
