import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unitalk/core/failure/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserCredential>> signInWithGoogle();
  Future<Either<Failure, UserCredential>> signInWithApple();
  Future<Either<Failure, UserCredential>> signInWithDemo();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentFirebaseUser();
}