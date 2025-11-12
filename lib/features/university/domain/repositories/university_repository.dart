import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

abstract class UniversityRepository {
  Future<Either<Failure, List<UniversityModel>>> getUniversities();
  Future<Either<Failure, List<FacultyModel>>> getFacultiesByUniversity(String universityId);
  Future<Either<Failure, UniversityModel>> getUniversityById(String id);
  Future<Either<Failure, FacultyModel>> getFacultyById(String id);
}