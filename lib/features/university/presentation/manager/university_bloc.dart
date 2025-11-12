// lib/features/university/presentation/bloc/university_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/university/domain/repositories/university_repository.dart';
import 'university_event.dart';
import 'university_state.dart';

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  final UniversityRepository repository;

  UniversityBloc(this.repository) : super(UniversityState.initial()) {
    on<LoadUniversitiesEvent>(_onLoadUniversities);
    on<LoadFacultiesEvent>(_onLoadFaculties);
  }

  Future<void> _onLoadUniversities(
      LoadUniversitiesEvent event,
      Emitter<UniversityState> emit,
      ) async {
    emit(state.copyWith(status: UniversityStatus.loading));

    final result = await repository.getUniversities();
    result.fold(
          (failure) => emit(state.copyWith(
        status: UniversityStatus.failure,
        errorMessage: failure.message,
      )),
          (universities) => emit(state.copyWith(
        status: UniversityStatus.success,
        universities: universities,
      )),
    );
  }

  Future<void> _onLoadFaculties(
      LoadFacultiesEvent event,
      Emitter<UniversityState> emit,
      ) async {
    emit(state.copyWith(status: UniversityStatus.loading));

    final result = await repository.getFacultiesByUniversity(event.universityId);
    result.fold(
          (failure) => emit(state.copyWith(
        status: UniversityStatus.failure,
        errorMessage: failure.message,
      )),
          (faculties) => emit(state.copyWith(
        status: UniversityStatus.success,
        faculties: faculties,
      )),
    );
  }
}