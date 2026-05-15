part of '../approval_page.dart';

class _RejectionReasonDialog extends StatefulWidget {
  const _RejectionReasonDialog();

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final FocusNode _reasonFocusNode = FocusNode();

  @override
  void dispose() {
    _reasonFocusNode.unfocus();
    _reasonFocusNode.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _close([String? reason]) {
    _reasonFocusNode.unfocus();
    Navigator.of(context).pop(reason);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _close(_reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Submission'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _reasonController,
          focusNode: _reasonFocusNode,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Rejection reason',
            hintText: 'Payment reference could not be verified.',
          ),
          validator: (String? value) {
            final String raw = value?.trim() ?? '';
            return raw.isEmpty ? 'Rejection reason is required' : null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => _close(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Reject')),
      ],
    );
  }
}
