import 'package:actual/common/layout/defaultLayout.dart';
import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/product/component/product_card.dart';
import 'package:actual/rating/component/rating_card.dart';
import 'package:actual/rating/model/rating_model.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:actual/restaurant/provider/rastaurant_rating_provider.dart';
import 'package:actual/restaurant/provider/restaurant_provider.dart';
import 'package:actual/restaurant/repository/restaurant_rating_repository.dart';
import 'package:actual/restaurant/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletons/skeletons.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const RestaurantDetailScreen({
    required this.id,
    Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController controller =ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    PaginationUtils.paginate(
        controller: controller,
        provider: ref.read(restaurantRatingProvider(widget.id).notifier)
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingsState = ref.watch(restaurantRatingProvider(widget.id));

    if(state == null) {
      return DefaultLayout(
          child: Center(
            child: CircularProgressIndicator(),
          )
      );
    }

    return DefaultLayout(
      title: '불타는떡뽁이',
      child: CustomScrollView(
        controller: controller,
        slivers: [
          renderTop(
            model: state,
            isDetail: true,
          ),

          if(state is! RestaurantDetailModel) renderLaoding(),
          if(state is RestaurantDetailModel) renderLabel(),
          if(state is RestaurantDetailModel)
            renderProduct(
              product: state.products
            ),
          if(ratingsState is CursorPagination<RatingModel>)
            renderRatings(models: ratingsState.data),
        ],
      ),
    );
  }

  SliverPadding renderRatings({
    required List<RatingModel> models,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      sliver: SliverList(
        delegate:  SliverChildBuilderDelegate((_, index) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: RatingCard.fromModel(
            model: models[index],
          ),
        ),
        childCount: models.length
        ),
      ),
    );
  }

  SliverPadding renderLaoding() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 6.0
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  lines: 5,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

   SliverToBoxAdapter renderTop({
     required RestaurantModel model,
     bool isDetail = false
    }) {
      return SliverToBoxAdapter(
          child:RestaurantCard.fromModel(
            model: model,
            isDetail:isDetail,
        ),
      );
   }

  SliverPadding renderLabel() {
     return SliverPadding(
       padding: EdgeInsets.symmetric(horizontal: 16.0),
       sliver: SliverToBoxAdapter(
         child:
         Text(
           '메뉴',
           style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500
           ),
         ),
       ),
     );
   }

  SliverPadding renderProduct({
    required List<RestaurantProductModel> product
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final model = product[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ProductCard.fromJson(
                model: model,
              ),
            );
          },
          childCount: product.length
        )
      ),
    );
  }
}
