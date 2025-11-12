import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

enum UniversityStatus { initial, loading, success, failure }

class UniversityState {
  final UniversityStatus status;
  final List<UniversityModel> universities;
  final List<FacultyModel> faculties;
  final String? errorMessage;

  UniversityState({
    required this.status,
    required this.universities,
    required this.faculties,
    this.errorMessage,
  });

  factory UniversityState.initial() {
    return UniversityState(
      status: UniversityStatus.initial,
      universities: [],
      faculties: [],
    );
  }

  UniversityState copyWith({
    UniversityStatus? status,
    List<UniversityModel>? universities,
    List<FacultyModel>? faculties,
    String? errorMessage,
  }) {
    return UniversityState(
      status: status ?? this.status,
      universities: universities ?? this.universities,
      faculties: faculties ?? this.faculties,
      errorMessage: errorMessage,
    );
  }
}