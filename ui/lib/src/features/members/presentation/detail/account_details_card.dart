part of 'member_detail_screen.dart';

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({
    required this.isLoading,
    required this.errorMessage,
    required this.user,
  });

  final bool isLoading;
  final String? errorMessage;
  final ManagedUser? user;

  @override
  Widget build(BuildContext context) {
    final String? error = errorMessage;
    final ManagedUser? profile = user;

    return AppSection(
      title: 'Account Details',
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: AppCardList(
        children: <Widget>[
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (error != null)
            AppMessageCard(
              message: error,
              tone: AppMessageTone.neutral,
              background: Colors.transparent,
              textColor: AppThemeColors.textMuted(context),
              padding: const EdgeInsets.all(20),
              showBorder: false,
              showIcon: false,
              textAlign: TextAlign.center,
            )
          else if (profile == null)
            AppMessageCard(
              message: 'No account details found.',
              tone: AppMessageTone.neutral,
              background: Colors.transparent,
              textColor: AppThemeColors.textMuted(context),
              padding: const EdgeInsets.all(20),
              showBorder: false,
              showIcon: false,
              textAlign: TextAlign.center,
            )
          else ...<Widget>[
            AppDetailRow(
              icon: Icons.phone_outlined,
              label: 'Contact No',
              value: valueOrDash(profile.contactNo),
            ),
            AppDetailRow(
              icon: Icons.mail_outline,
              label: 'Email',
              value: valueOrDash(profile.email),
            ),
            AppDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Join Date',
              value: valueOrDash(profile.joinDate),
            ),
            AppDetailRow(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Role',
              value: profile.role.label,
            ),
            AppDetailRow(
              icon: Icons.verified_user_outlined,
              label: 'Status',
              value: profile.status.label,
            ),
            AppDetailRow(
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: valueOrDash(profile.notes),
            ),
            AppDetailRow(
              icon: Icons.history_outlined,
              label: 'Created At',
              value: formatDateTimeShort(profile.createdAt),
            ),
            AppDetailRow(
              icon: Icons.update_outlined,
              label: 'Updated At',
              value: formatDateTimeShort(profile.updatedAt),
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}
