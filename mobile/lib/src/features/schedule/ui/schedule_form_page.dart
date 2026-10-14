import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/standalone_page_header.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_user_tree.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_form_controller.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_form_basic.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_form_details.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_form_people.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_form_timing.dart';

class ScheduleFormPage extends ConsumerStatefulWidget {
  const ScheduleFormPage({
    super.key,
    required this.isEditing,
    this.scheduleId,
    this.scheduleEventId,
  });

  static const routePath = '/app/schedule/form';

  static String location({
    String? scheduleId,
    String? scheduleEventId,
    bool isEditing = false,
  }) {
    final uri = Uri(
      path: routePath,
      queryParameters: {
        ...?switch (scheduleId) {
          final value? => {'scheduleId': value},
          null => null,
        },
        ...?switch (scheduleEventId) {
          final value? => {'eventId': value},
          null => null,
        },
        if (isEditing) 'mode': 'edit',
      },
    );

    return uri.toString();
  }

  static ScheduleFormRouteConfig parseRoute(Uri uri) {
    final query = uri.queryParameters;
    final scheduleId = query['scheduleId'];
    final scheduleEventId = query['eventId'];
    final isEditing = uri.queryParameters['mode'] == 'edit';
    final hasScheduleId = query.containsKey('scheduleId');
    final hasScheduleEventId = query.containsKey('eventId');
    final hasScheduleContext = hasScheduleId || hasScheduleEventId || isEditing;

    if (!hasScheduleContext) {
      return const ScheduleFormRouteConfig.create();
    }

    if (scheduleId != null && scheduleId.isEmpty) {
      throw StateError(
        'Schedule form route requires a non-empty scheduleId when provided.',
      );
    }

    if (scheduleEventId != null && scheduleEventId.isEmpty) {
      throw StateError(
        'Schedule form route requires a non-empty eventId when provided.',
      );
    }

    if (scheduleId == null || scheduleEventId == null) {
      throw StateError(
        'Schedule form route requires both scheduleId and eventId for reuse or edit mode.',
      );
    }

    return ScheduleFormRouteConfig(
      scheduleId: scheduleId,
      scheduleEventId: scheduleEventId,
      isEditing: isEditing,
    );
  }

  final bool isEditing;
  final String? scheduleId;
  final String? scheduleEventId;

  @override
  ConsumerState<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

final class ScheduleFormRouteConfig {
  const ScheduleFormRouteConfig({
    this.scheduleId,
    this.scheduleEventId,
    required this.isEditing,
  });

  const ScheduleFormRouteConfig.create()
    : scheduleId = null,
      scheduleEventId = null,
      isEditing = false;

  final String? scheduleId;
  final String? scheduleEventId;
  final bool isEditing;
}

class _ScheduleFormPageState extends ConsumerState<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final ScheduleFormArgs _formArgs;
  _ScheduleFormSnapshot? _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _formArgs = ScheduleFormArgs(
      isEditing: widget.isEditing,
      scheduleId: widget.scheduleId,
      scheduleEventId: widget.scheduleEventId,
    );
    Future<void>(
      () => ref
          .read(scheduleFormControllerProvider(_formArgs).notifier)
          .bootstrap(),
    );
  }

  bool _hasEdits(ScheduleFormState formState) {
    return _initialSnapshot?.hasChanges(formState) ?? false;
  }

  Future<bool?> _showDiscardConfirmationDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bỏ thay đổi?'),
          content: const Text(
            'Bạn có thay đổi chưa lưu. Bạn có chắc muốn thoát mà không lưu không?',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Ở lại'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Bỏ thay đổi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    final shouldLeave = await _showDiscardConfirmationDialog();
    if (shouldLeave == true && mounted) {
      context.pop();
    }
  }

  Future<void> _handleBack(ScheduleFormState formState) async {
    if (_hasEdits(formState)) {
      final shouldLeave = await _showDiscardConfirmationDialog();
      if (shouldLeave == true && mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    final formState = ref.watch(scheduleFormControllerProvider(_formArgs));
    final formController = ref.read(
      scheduleFormControllerProvider(_formArgs).notifier,
    );
    final currentUser = ref.watch(authControllerProvider).user;
    final scheduleUserGroups = currentUser == null
        ? const <TreeSelectGroup>[]
        : buildScheduleUserTree(
            users: scheduleState.users,
            currentUser: currentUser,
          );
    final colorScheme = Theme.of(context).colorScheme;
    final pageTitle = widget.isEditing
        ? 'Chỉnh sửa lịch trình'
        : 'Tạo lịch trình';

    if (!formState.isBootstrapping &&
        formState.loadError == null &&
        _initialSnapshot == null) {
      _initialSnapshot = _ScheduleFormSnapshot.fromState(formState);
    }

    if (formState.isBootstrapping) {
      return Scaffold(
        appBar: StandalonePageHeader(title: pageTitle),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (formState.loadError != null) {
      return Scaffold(
        appBar: StandalonePageHeader(title: pageTitle),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Text(
                  formState.loadError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Quay lại'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final hasChanges = _hasEdits(formState);

    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        appBar: StandalonePageHeader(
          title: pageTitle,
          onBackPressed: () => _handleBack(formState),
          actions: [
            if (formState.isSubmitting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              HeaderActionButton(
                key: const ValueKey('schedule_form_header_save'),
                tooltip: widget.isEditing ? 'Lưu' : 'Tạo',
                icon: Icons.check,
                color: colorScheme.primary,
                onPressed: _submit,
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScheduleFormBasicSection(
                      formState: formState,
                      onTypeChanged: formState.isSubmitting
                          ? null
                          : formController.updateType,
                      onTitleChanged: formController.updateTitle,
                      onScheduleTypeChanged: formState.isSubmitting
                          ? null
                          : formController.updateScheduleType,
                    ),
                    const SizedBox(height: 16),
                    ScheduleFormTimingSection(
                      formState: formState,
                      onStartDateChanged: formController.updateStartDate,
                      onEndDateChanged: formController.updateEndDate,
                      onStartTimeChanged: formController.updateStartTime,
                      onEndTimeChanged: formController.updateEndTime,
                      onRepeatTypeChanged: formState.isSubmitting
                          ? null
                          : formController.updateRepeatType,
                      onRepeatPatternChanged:
                          formController.updateRepeatPattern,
                    ),
                    const SizedBox(height: 16),
                    ScheduleFormPeopleSection(
                      formState: formState,
                      isUsersLoading: scheduleState.isUsersLoading,
                      scheduleUserGroups: scheduleUserGroups,
                      onParticipantsChanged: formController.updateParticipants,
                      onObserversChanged: formController.updateObservers,
                    ),
                    const SizedBox(height: 16),
                    ScheduleFormDetailsSection(
                      formState: formState,
                      onAddressChanged: formController.updateAddress,
                      onNoteChanged: formController.updateNote,
                      onPrivacyChanged: formState.isSubmitting
                          ? null
                          : formController.updatePrivacy,
                      onIsGeneralChanged: formState.isSubmitting
                          ? null
                          : formController.updateIsGeneral,
                      onHasReminderChanged: formState.isSubmitting
                          ? null
                          : formController.updateHasReminder,
                      onRemindValueChanged: formController.updateRemindValue,
                      onRemindRangeChanged: formState.isSubmitting
                          ? null
                          : formController.updateRemindRange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await ref
        .read(scheduleFormControllerProvider(_formArgs).notifier)
        .submit();
    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      context.pop(true);
      return;
    }

    _showSnackBar(result.message!);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ScheduleFormSnapshot {
  const _ScheduleFormSnapshot({
    required this.title,
    required this.note,
    required this.physicalAddress,
    required this.remindValue,
    required this.type,
    required this.scheduleType,
    required this.privacy,
    required this.repeatType,
    required this.repeatPattern,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.isGeneral,
    required this.hasReminder,
    required this.remindRange,
    required this.participants,
    required this.observers,
  });

  factory _ScheduleFormSnapshot.fromState(ScheduleFormState state) {
    return _ScheduleFormSnapshot(
      title: state.title.trim(),
      note: state.note.trim(),
      physicalAddress: state.physicalAddress.trim(),
      remindValue: state.remindValue.trim(),
      type: state.type,
      scheduleType: state.scheduleType,
      privacy: state.privacy,
      repeatType: state.repeatType,
      repeatPattern: Set.of(state.repeatPattern),
      startDate: state.startDate,
      endDate: state.endDate,
      startTime: state.startTime,
      endTime: state.endTime,
      isGeneral: state.isGeneral,
      hasReminder: state.hasReminder,
      remindRange: state.remindRange,
      participants: Set.of(state.participants),
      observers: Set.of(state.observers),
    );
  }

  final String title;
  final String note;
  final String physicalAddress;
  final String remindValue;
  final ScheduleEventType? type;
  final ScheduleEventScheduleType? scheduleType;
  final ScheduleEventPrivacy? privacy;
  final ScheduleEventRepeatType? repeatType;
  final Set<String> repeatPattern;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isGeneral;
  final bool hasReminder;
  final ScheduleEventRemindRange? remindRange;
  final Set<String> participants;
  final Set<String> observers;

  bool hasChanges(ScheduleFormState current) {
    return title != current.title.trim() ||
        note != current.note.trim() ||
        physicalAddress != current.physicalAddress.trim() ||
        remindValue != current.remindValue.trim() ||
        type != current.type ||
        scheduleType != current.scheduleType ||
        privacy != current.privacy ||
        repeatType != current.repeatType ||
        !setEquals(repeatPattern, current.repeatPattern) ||
        startDate != current.startDate ||
        endDate != current.endDate ||
        startTime != current.startTime ||
        endTime != current.endTime ||
        isGeneral != current.isGeneral ||
        hasReminder != current.hasReminder ||
        remindRange != current.remindRange ||
        !setEquals(participants, current.participants) ||
        !setEquals(observers, current.observers);
  }
}
