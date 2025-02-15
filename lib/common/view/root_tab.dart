import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/defaultLayout.dart';
import 'package:actual/product/view/product_screen.dart';
import 'package:actual/restaurant/view/restaurant_screen.dart';
import 'package:actual/user/view/profile_screen.dart';
import 'package:flutter/material.dart';

class RootTab extends StatefulWidget {
  static String get routeName => 'home';
  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller = TabController(length: 4, vsync: this);
  int index = 0;

  @override
  void inintState() {
    super.initState();

    controller = TabController(length: 4, vsync: this);

    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  void tabListener () {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '코팩 딜리버리',
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          RestaurantScreen(),
          ProductScreen(),
          Center(
            child: Container(
              child: Text('주문'),
            ),
          ),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10.0,
        unselectedFontSize: 10.0,
        type: BottomNavigationBarType.shifting,
        onTap: (int index) {
          controller.animateTo(index);
        },
        currentIndex: this.index,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.fastfood_outlined),
              label: '음식'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: '주문'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: '프로필'
          ),
        ],
      ),
    );
  }
}
