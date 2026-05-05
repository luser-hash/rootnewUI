import 'package:flutter/widgets.dart';

import '../../src/features/shared/finance.dart';

class AppState {
  AppState._();

  static final ValueNotifier<List<Submission>> submissions =
      ValueNotifier<List<Submission>>(List<Submission>.from(submissionsSeed));

  static void updateSubmissionStatus(String id, SubmissionStatus status) {
    submissions.value = submissions.value
        .map(
          (Submission submission) => submission.id == id
              ? submission.copyWith(status: status)
              : submission,
        )
        .toList();
  }
}

class SubmissionsBuilder extends StatelessWidget {
  const SubmissionsBuilder({super.key, required this.builder});

  final Widget Function(List<Submission> submissions) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Submission>>(
      valueListenable: AppState.submissions,
      builder: (_, List<Submission> submissions, _) => builder(submissions),
    );
  }
}
