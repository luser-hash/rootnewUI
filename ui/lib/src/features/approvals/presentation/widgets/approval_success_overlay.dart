part of '../approval_page.dart';

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.primary.withValues(alpha: .95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .15),
              ),
              child: const Text(
                '✓',
                style: TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Approved!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Capital ledger has been updated',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: .75),
              ),
            ),
            const SizedBox(height: 28),
            Material(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
