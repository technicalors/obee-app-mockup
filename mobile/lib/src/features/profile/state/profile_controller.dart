import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/profile/data/profile_api.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileController extends Notifier<ProfileState> {
  late ProfileApi _profileApi;

  @override
  ProfileState build() {
    _profileApi = ref.watch(profileApiProvider);

    return const ProfileState();
  }

  Future<bool> updateProfile(UpdateUserInput input) async {
    if (state.isLoading) return false;
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser == null) {
      throw StateError('Profile update requires an authenticated user.');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedUser = await _profileApi.updateProfile(input: input);

      if (!ref.mounted) {
        return false;
      }

      ref
          .read(authControllerProvider.notifier)
          .replaceAuthenticatedUser(updatedUser);

      state = const ProfileState();
      return true;
    } catch (error) {
      if (!ref.mounted) {
        return false;
      }

      final problem = error is DioException ? error.error : null;
      state = ProfileState(
        errorMessage: error is DioException
            ? _messageForError(error)
            : 'profileUpdateError',
        fieldErrors: problem is ApiProblemException
            ? problem.problem.errors ?? const {}
            : const {},
      );
      return false;
    }
  }

  void clearFeedback() {
    state = const ProfileState();
  }
}

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final Map<String, List<String>> fieldErrors;

  final bool isLoading;
  final String? errorMessage;

  ProfileState copyWith({bool? isLoading, Object? errorMessage = _notChanged}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      fieldErrors: const {},
      errorMessage: errorMessage == _notChanged
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _notChanged = Object();

String _messageForError(DioException error) {
  final apiError = error.error;

  if (apiError is ApiProblemException) {
    return problemMessage(apiError.problem);
  }

  return 'profileUpdateError';
}
