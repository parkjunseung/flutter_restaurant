import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/model_with_id.dart';
import 'package:actual/common/model/pagination_params.dart';
import 'package:actual/common/repository/base_paginaton_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationProvider<
T extends IModelWithId,
U extends IBasePaginatonReposiory<T>
> extends StateNotifier<CursorPaginationBase> {
  final U repository;

  PaginationProvider({
    required this.repository
  }): super(CursorPaginationLoading()){
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    try {
      // State의 상태
      // 1) 정상적으로 데이터가 있는 상태 - CursorPagination
      // 2) 데이터가 로딩중인 상태 (현재 캐시 없음) - CursorPaginationLoding
      // 3) 에러 - CursorPaginationError
      // 4) 첫번째 페이지부터 - CursorPaginationRefetching
      // 5) 추가 데이터를 paginate 해오라는 요청 - CursorPaginationFetchMore

      // 바로 반환하는 상황
      // 1) hasMore = false
      // 2) fetchMore = 로딩중
      if(state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        if(!pState.meta.hasMore) {
          return;
        }
      }

      final isLoading= state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // paginatonParams
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchMore
      // 데이터를 추가적으로 가져오는 ㄴ상황
      if(fetchMore) {
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
            meta: pState.meta,
            data: pState.data
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      } else {
        // 만약에 데이터가 있는 상활이라면
        // 기존 데이터를 보존한채로 fetch
        if(state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(
              meta: pState.meta,
              data: pState.data
          );

        } else {
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(
          paginationParams: paginationParams
      );

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore<T>;

        state = resp.copyWith(
            data: [
              ...pState.data,
              ...resp.data,
            ]
        );
      } else {
        state = resp;
      }
    } catch(e, stack) {
      print(e);
      print(stack);
      state = CursorPaginationError(message: '데이터 못가져옴');
    }
  }
}