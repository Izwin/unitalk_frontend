import 'package:dio/dio.dart';
import 'package:unitalk/features/block/data/model/block_model.dart';

class BlockRemoteDataSource {
  final Dio dio;

  BlockRemoteDataSource({required this.dio});

  // Заблокировать пользователя
  Future<BlockModel> blockUser(String userId) async {
    final response = await dio.post('/blocks/$userId');
    return BlockModel.fromJson(response.data['block']);
  }

  // Разблокировать пользователя
  Future<void> unblockUser(String userId) async {
    await dio.delete('/blocks/$userId');
  }

  // Получить список заблокированных пользователей
  Future<Map<String, dynamic>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      '/blocks',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final blocks = (response.data['blocks'] as List)
        .map((json) => BlockModel.fromJson(json))
        .toList();

    return {
      'blocks': blocks,
      'pagination': response.data['pagination'],
    };
  }

  // Проверить статус блокировки
  Future<Map<String, dynamic>> checkBlockStatus(String userId) async {
    final response = await dio.get('/blocks/check/$userId');
    return response.data;
  }

  // Получить статус блокировки для UserModel
  Future<BlockStatusModel> getBlockStatus(String userId) async {
    final response = await dio.get('/blocks/check/$userId');
    return BlockStatusModel.fromJson(response.data);
  }
}