import 'package:flutter/material.dart';
import 'package:ganajec/features/admin/data/datasource/admin_remote_ds.dart';
import 'package:ganajec/features/admin/domain/entities/admin_rancho.dart';

enum AdminRanchosStatus { idle, loading, success, error }

class AdminRanchosViewModel extends ChangeNotifier {
  final AdminRemoteDataSource _ds = AdminRemoteDataSource();

  AdminRanchosStatus _status = AdminRanchosStatus.idle;
  String? _error;
  List<AdminRancho> _ranchos = [];

  AdminRanchosStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == AdminRanchosStatus.loading;
  List<AdminRancho> get ranchos => _ranchos;

  Future<void> cargar() async {
    _status = AdminRanchosStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _ranchos = await _ds.getRanchos();
      _status = AdminRanchosStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = AdminRanchosStatus.error;
      _ranchos = [];
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
