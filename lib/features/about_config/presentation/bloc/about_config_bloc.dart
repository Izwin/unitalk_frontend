import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/about_config_repository.dart';
import 'about_config_event.dart';
import 'about_config_state.dart';

class AboutConfigBloc extends Bloc<AboutConfigEvent, AboutConfigState> {
  final AboutConfigRepository repository;

  AboutConfigBloc({required this.repository}) : super(const AboutConfigState()) {
    on<LoadAboutConfigEvent>(_onLoad);
    on<RefreshAboutConfigEvent>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadAboutConfigEvent event,
      Emitter<AboutConfigState> emit,
      ) async {
    emit(state.copyWith(status: AboutConfigStatus.loading));

    final result = await repository.getAboutConfig();

    result.fold(
          (failure) => emit(state.copyWith(
        status: AboutConfigStatus.failure,
        errorMessage: failure.message,
      )),
          (config) => emit(state.copyWith(
        status: AboutConfigStatus.success,
        config: config,
      )),
    );
  }

  Future<void> _onRefresh(
      RefreshAboutConfigEvent event,
      Emitter<AboutConfigState> emit,
      ) async {
    final result = await repository.getAboutConfig();

    result.fold(
          (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
          (config) => emit(state.copyWith(
        status: AboutConfigStatus.success,
        config: config,
      )),
    );
  }
}