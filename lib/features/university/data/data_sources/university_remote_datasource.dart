import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

class UniversityRemoteDataSource {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  UniversityRemoteDataSource({
    required this.dio,
    required this.firebaseAuth,
  });

  Future<String?> _getAuthToken() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<List<UniversityModel>> getUniversities() async {
    final response = await dio.get('/universities');

    return (response.data as List)
        .map((json) => UniversityModel.fromJson(json))
        .toList();
  }

  Future<List<FacultyModel>> getFacultiesByUniversity(String universityId) async {
    final response = await dio.get('/universities/$universityId/faculties');

    return (response.data as List)
        .map((json) => FacultyModel.fromJson(json))
        .toList();
  }

  Future<UniversityModel> getUniversityById(String id) async {
    final response = await dio.get('/universities/$id');
    return UniversityModel.fromJson(response.data);
  }

  Future<FacultyModel> getFacultyById(String id) async {
    final response = await dio.get('/faculties/$id');
    return FacultyModel.fromJson(response.data);
  }
}