import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/data_sources/university_remote_datasource.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/domain/repositories/university_repository.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  final UniversityRemoteDataSource remoteDataSource;

  UniversityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<UniversityModel>>> getUniversities() async {
    try {
      final universities = await remoteDataSource.getUniversities();
      return Right(universities);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get universities: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FacultyModel>>> getFacultiesByUniversity(
      String universityId) async {
    try {
      final faculties = await remoteDataSource.getFacultiesByUniversity(universityId);
      return Right(faculties);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get faculties: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UniversityModel>> getUniversityById(String id) async {
    try {
      final university = await remoteDataSource.getUniversityById(id);
      return Right(university);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get university: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FacultyModel>> getFacultyById(String id) async {
    try {
      final faculty = await remoteDataSource.getFacultyById(id);
      return Right(faculty);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get faculty: ${e.toString()}'));
    }
  }
}