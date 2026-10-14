import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/state/new_direct_chat_provider.dart';

final groupCreationPreviewProvider =
    NotifierProvider<GroupCreationPreviewController, GroupCreationPreviewState>(
      GroupCreationPreviewController.new,
    );

final filteredGroupCreationPreviewCoworkersProvider =
    Provider<List<ChatCoworker>>((ref) {
      final state = ref.watch(groupCreationPreviewProvider);
      final coworkers = ref
          .watch(coworkerPickerProvider)
          .maybeWhen(
            data: (coworkers) => coworkers,
            orElse: () => const <ChatCoworker>[],
          );

      if (state.searchQuery.isEmpty) {
        return coworkers;
      }

      return coworkers
          .where((coworker) => coworker.matchesSearchQuery(state.searchQuery))
          .toList(growable: false);
    });

class GroupCreationPreviewController
    extends Notifier<GroupCreationPreviewState> {
  @override
  GroupCreationPreviewState build() {
    return const GroupCreationPreviewState();
  }

  void updateGroupName(String groupName) {
    if (state.groupName == groupName) {
      return;
    }

    state = state.copyWith(groupName: groupName);
  }

  void updateSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    if (state.searchQuery.isEmpty) {
      return;
    }

    state = state.copyWith(searchQuery: '');
  }

  void toggleCoworker(String coworkerId) {
    final nextSelectedCoworkerIds = Set<String>.from(state.selectedCoworkerIds);
    if (nextSelectedCoworkerIds.contains(coworkerId)) {
      nextSelectedCoworkerIds.remove(coworkerId);
    } else {
      nextSelectedCoworkerIds.add(coworkerId);
    }

    state = state.copyWith(selectedCoworkerIds: nextSelectedCoworkerIds);
  }
}

class GroupCreationPreviewState {
  const GroupCreationPreviewState({
    this.groupName = '',
    this.searchQuery = '',
    this.selectedCoworkerIds = const <String>{},
  });

  final String groupName;
  final String searchQuery;
  final Set<String> selectedCoworkerIds;

  GroupCreationPreviewState copyWith({
    String? groupName,
    String? searchQuery,
    Set<String>? selectedCoworkerIds,
  }) {
    return GroupCreationPreviewState(
      groupName: groupName ?? this.groupName,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCoworkerIds: selectedCoworkerIds ?? this.selectedCoworkerIds,
    );
  }
}
