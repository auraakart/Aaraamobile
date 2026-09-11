import 'package:aaraa_kart/core/config/brand_config.dart';

class AppConstants {
  static String get gcpkey => BrandConfig.instance.maps.apiKey;

  static const String userPrefKey = 'USER_INFO';
  static const String guestPrefKey = 'GUEST_MODE';
  static const String cartPrefKey = 'CART_ITEMS';
  static const String favListKey = 'FAV_ITEMS';
  static const String addressPrefKey = 'CUSTOMER_ADDRESS';
}

class AppAssets {
  static String get logoTFV => BrandConfig.instance.images.logo;
  static String get successJson => BrandConfig.instance.images.successLottie;

  static String _categoryIcon(String slug) =>
      BrandConfig.instance.images.categoryIcon(slug);

  static String get iconMilk => _categoryIcon('milk');
  static String get iconCurd => _categoryIcon('curd');
  static String get iconEgg => _categoryIcon('egg');
  static String get iconGhee => _categoryIcon('ghee');
  static String get iconOil => _categoryIcon('oil');
  static String get iconPanner => _categoryIcon('panner');
  static String get iconButter => _categoryIcon('butter');
  static String get iconAll => _categoryIcon('all');
}

final List<Map<String, dynamic>> deliveryTimeSlots = [
  {
    'start': '5:00 AM',
    'end': '7:00 AM',
  },
  {
    'start': '7:00 AM',
    'end': '9:00 AM',
  },
  {
    'start': '5:00 PM',
    'end': '7:00 PM',
  },
];

class OrderStatus {
  static const String pendingPayment = 'pending';
  static const String processing = 'processing';
  static const String readyToShip = 'ready-to-ship';
  static const String refundRequested = 'refund-req';
  static const String onHold = 'on-hold';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
  static const String failed = 'failed';
  static const String draft = 'checkout-draft';
}

class SubscriptionStatus {
  static const String pending = 'pending';
  static const String onHold = 'on-hold';
  static const String active = 'active';
  static const String cancelled = 'cancelled';
  static const String switched = 'switched';
  static const String expired = 'expired';
  static const String draft = 'pending-cance';
}

String getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'milk':
      return AppAssets.iconMilk;
    case 'curd':
      return AppAssets.iconCurd;
    case 'egg':
      return AppAssets.iconEgg;
    case 'ghee':
      return AppAssets.iconGhee;
    case 'oil':
      return AppAssets.iconOil;
    case 'paneer':
      return AppAssets.iconPanner;
    case 'butter':
      return AppAssets.iconButter;
    case 'all':
      return AppAssets.iconAll;
    default:
      return AppAssets.iconMilk;
  }
}


