class AppRoutes {
  static const splash = _RouteInfo('/', 'splash');
  static const login = _RouteInfo('/login', 'login');
  static const otp = _RouteInfo('/otp', 'otp');
  static const bottomBar = _RouteInfo('/bottom-bar', 'bottomBar');
  static const home = _RouteInfo('/home', 'home');
  static const profile = _RouteInfo('/profile', 'profile');
  static const productList = _RouteInfo('/product-list', 'productList');
  static const payment = _RouteInfo('/payment-screen', 'paymentScreen');
  static const paytmPayment = _RouteInfo('/paytm-payment', 'paytmPaymentScreen');
  static const productDetails = _RouteInfo('/product-details', 'productDetails');
  static const googleMaps = _RouteInfo('/google-maps', 'googleMaps');
  static const locationSelection = _RouteInfo('/location-selection', 'locationSelection');
  static const wallet = _RouteInfo('/wallet', 'wallet');
  static const cart = _RouteInfo('/cart', 'cart');
  static const checkout = _RouteInfo('/checkout', 'checkout');
  static const nameScreen = _RouteInfo('/name-screen', 'nameScreen');
  static const emailScreen = _RouteInfo('/email-screen', 'emailScreen');
  static const welcome = _RouteInfo('/welcome', 'welcome');
  static const editProfile = _RouteInfo('/edit-profile', 'editProfile');
  static const orderSuccess = _RouteInfo('/order-success', 'orderSuccess');
  static const orderFailed = _RouteInfo('/order-failed', 'orderFailed');
  static const createSubscription = _RouteInfo('/create-subscription', 'createSubscription');
  static const subSettings = _RouteInfo('/sub-settings', 'subSettings');
  static const tnc = _RouteInfo('/tnc', 'tnc');
  static const privacy = _RouteInfo('/privacy', 'privacy');
  static const favList = _RouteInfo('/fav-list-screen', 'favListScreen');
  static const subsCalendar = _RouteInfo('/subs-calendar', 'subsCalendar');
  static const faq = _RouteInfo('/faq-screen', 'faqScreen');
  static const gallery = _RouteInfo('/gallery-screen', 'galleryScreen');
  static const subHistory = _RouteInfo('/sub-history', 'subHistory');
}

class _RouteInfo {
  final String path;
  final String name;

  const _RouteInfo(this.path, this.name);
}


