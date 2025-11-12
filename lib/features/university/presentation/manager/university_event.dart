abstract class UniversityEvent {}

class LoadUniversitiesEvent extends UniversityEvent {}

class LoadFacultiesEvent extends UniversityEvent {
  final String universityId;

  LoadFacultiesEvent(this.universityId);
}