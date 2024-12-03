import 'package:flutter/material.dart';
import 'package:safe_mama/api/models/data_state.dart';
import 'package:safe_mama/cache/utility_datasource.dart';
import 'package:safe_mama/models/resource_model.dart';
import 'package:safe_mama/repository/utility_repository.dart';

class CategoriesState {
  List<ResourceTypeModel> categories = [];
  bool isSuccess = false;
  String errorMessage = '';

  CategoriesState();
  CategoriesState.success(this.isSuccess, this.categories);
  CategoriesState.error(this.isSuccess, this.errorMessage);
}

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesState state = CategoriesState();

  final UtilityDatasource utilityDatasource;
  final UtilityRepository utilityRepository;

  CategoriesViewModel(this.utilityDatasource, this.utilityRepository);

  Future<CategoriesState> getCategories() async {
    try {
      final cachedCategories = await utilityDatasource.getResourceTypes();

      if (cachedCategories.isEmpty) {
        final result = await utilityRepository.fetchResourceTypes();

        if (result is DataSuccess) {
          final list = result.data ?? [];
          return CategoriesState.success(true, list);
        }

        if (result is DataError) {
          return CategoriesState.error(false, result.error ?? 'Error occurred');
        }
      }

      return CategoriesState.success(true, cachedCategories);
    } catch (e) {
      return CategoriesState.error(false, e.toString());
    }
  }
}
