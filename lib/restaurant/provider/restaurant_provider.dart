import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/pagination_params.dart';
import 'package:actual/common/provider/pagination_provider.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:actual/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if(state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhereOrNull((element) => element.id == id);
});


final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
    (ref) {
      final repository= ref.watch(restaurantRepositoryProvider);
      final notifier = RestaurantStateNotifier(repository: repository);

      return notifier;
    }
);

class RestaurantStateNotifier extends PaginationProvider<RestaurantModel, RestaurantRepository>{

  RestaurantStateNotifier({
    required super.repository
  });

  void getDetail({
    required String id
  }) async {
    // 만약 데이터가 하나도 없는 상태라면
    if(state is! CursorPagination) {
      await this.paginate();
    }

    // state가 CursorPagination 아닐때 그냥 리턴
    if(state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);

    // 예외 케이스 요청아이디가 존재하지 않을 경우
    if(pState.data.where((element) => element.id == id).isEmpty) {
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          resp,
        ]
      );
    } else  {
      state = pState.copyWith(
        data: pState.data.map<RestaurantModel>((e) => e.id == id ? resp : e).toList(),
      );
    }
  }
}