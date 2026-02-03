import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import '../../data/model/about_config_model.dart';

abstract class AboutConfigRepository {
  Future<Either<Failure, AboutConfigModel>> getAboutConfig();
}