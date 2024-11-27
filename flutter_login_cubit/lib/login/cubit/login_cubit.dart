import 'package:bloc/bloc.dart';
import 'package:flutter_login_cubit/login/models/password.dart';
import 'package:flutter_login_cubit/login/models/username.dart';
import 'package:meta/meta.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState());

  final AuthenticationRepository _authenticationRepository;

  void usernameChanged(String username) {
    final usernameInput = Username.dirty(username);
    emit(
      state.copyWith(
        username: usernameInput,
        isValid: Formz.validate([state.password, usernameInput]),
      ),
    );
  }

  void passwordChanged(String password) {
    final passwordInput = Password.dirty(password);
    emit(
      state.copyWith(
        password: passwordInput,
        isValid: Formz.validate([passwordInput, state.username]),
      ),
    );
  }

  Future<void> logIn() async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await _authenticationRepository.logIn(
          username: state.username.value,
          password: state.password.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
