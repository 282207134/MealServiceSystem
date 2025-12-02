import 'package:go_router/go_router.dart';

import '../screens/cart_screen.dart';
import '../screens/menu_screen.dart';

class AppRouter {
  static GoRouter get router => GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MenuScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
        ],
      );
}
