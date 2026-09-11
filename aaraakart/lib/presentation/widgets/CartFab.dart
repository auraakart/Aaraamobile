import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class CartFAB extends StatefulWidget {
  const CartFAB({super.key});

  @override
  State<CartFAB> createState() => _CartFABState();
}

class _CartFABState extends State<CartFAB> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _badgeController;

  late Animation<double> _scaleAnim;
  late Animation<Offset> _badgeSlideAnim;
  late Animation<double> _badgeFadeAnim;

  int _oldItemsCount = 0;
  String? _message;
  Color _badgeColor = Colors.green;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _badgeController = AnimationController(
      duration: Duration(milliseconds: 450),
      vsync: this,
    );

    _badgeSlideAnim = Tween<Offset>(
      begin: Offset(1.4, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOutBack),
    );

    _badgeFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeIn),
    );
  }

  void _triggerAnimation({
    required int newItemsCount,
    required String prdName,
  }) {
    int diff = newItemsCount - _oldItemsCount;

    if (diff > 0) {
      _message = "$prdName added to cart";
      _badgeColor = Colors.green.shade600;
    } else if (diff < 0) {
      _message = "$prdName removed from cart";
      _badgeColor = Colors.red.shade600;
    } else {
      return;
    }

    setState(() {});

    _badgeController.forward();
    Future.delayed(Duration(milliseconds: 1400), () {
      if (mounted) {
        _badgeController.reverse().then((_) {
          if (mounted) setState(() => _message = null);
        });
      }
    });

    _scaleController.forward().then((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) _scaleController.reverse();
      });
    });

    _oldItemsCount = newItemsCount;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        final newItemCount = state.items.length;
        final qty = state.items.fold<int>(
          0,
          (s, i) => s + (i.quantity ?? 1),
        );

        if (newItemCount != 0) {
          _triggerAnimation(
              newItemsCount: qty ?? newItemCount,
              prdName: state.items[0].name.toString());
        }
      },
      builder: (context, state) {
        final qty = state.items.fold<int>(
          0,
          (s, i) => s + (i.quantity ?? 1),
        );
        final newItemCount = state.items.length;
        if (newItemCount == 0 || qty == 0) return SizedBox();

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: FloatingActionButton.extended(
                  backgroundColor: AppColors.brandPrimaryDark,
                  onPressed: () => context.push('/cart'),
                  icon: Icon(Iconsax.shopping_bag_bold,
                      color: Colors.white, size: 18),
                  label: Column(
                    children: [
                      Text("View Cart",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text(
                        "$qty item${qty == 1 ? '' : 's'}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // if (_message != null)
              //   Positioned(
              //     top: -45,
              //     left: 0,
              //     right: 0,
              //     child: SlideTransition(
              //       position: _badgeSlideAnim,
              //       child: FadeTransition(
              //         opacity: _badgeFadeAnim,
              //         child: Container(
              //           width: double.infinity,
              //           padding:
              //               EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              //           decoration: BoxDecoration(
              //               color: _badgeColor,
              //               borderRadius: BorderRadius.circular(10)),
              //           child: Text(
              //             _message!,
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 9,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _badgeController.dispose();
    super.dispose();
  }
}


