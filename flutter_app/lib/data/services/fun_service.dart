import '../repositories/fun_repository.dart';

class FunService {
  FunService({FunRepository? repository})
    : _repository = repository ?? FunRepository();

  final FunRepository _repository;

  Future<List<dynamic>> getFun() => _repository.getFun();
}
