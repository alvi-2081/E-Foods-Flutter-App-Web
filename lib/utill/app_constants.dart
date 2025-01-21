import 'package:flutter_restaurant/data/model/response/language_model.dart';
import 'package:flutter_restaurant/helper/app_mode.dart';
import 'package:flutter_restaurant/utill/images.dart';

class AppConstants {
  static const String appName = 'eFood';
  static const String appVersion = '10.2';
  static const AppMode appMode = AppMode.release;
  static const String baseUrl = 'https://insightops.eads.pk';
  static const String categoryUri = '/api/v1/categories';
  static const String bannerUri = '/api/v1/banners';
  static const String latestProductUri = '/api/v1/products/latest';
  static const String popularProductUri = '/api/v1/products/popular';
  static const String searchProductUri = '/api/v1/products/details/';
  static const String subCategoryUri = '/api/v1/categories/childes/';
  static const String categoryProductUri = '/api/v1/categories/products/';
  static const String configUri = '/api/v1/config';
  static const String trackUri = '/api/v1/customer/order/track?order_id=';
  static const String messageUri = '/api/v1/customer/message/get';
  static const String sendMessageUri = '/api/v1/customer/message/send';
  static const String forgetPasswordUri = '/api/v1/auth/forgot-password';
  static const String verifyTokenUri = '/api/v1/auth/verify-token';
  static const String resetPasswordUri = '/api/v1/auth/reset-password';
  static const String checkPhoneUri = '/api/v1/auth/check-phone?phone=';
  static const String verifyPhoneUri = '/api/v1/auth/verify-phone';
  static const String checkEmailUri = '/api/v1/auth/check-email';
  static const String verifyEmailUri = '/api/v1/auth/verify-email';
  static const String registerUri = '/api/v1/auth/registration';
  static const String loginUri = '/api/v1/auth/login';
  static const String tokenUri = '/api/v1/customer/cm-firebase-token';
  static const String placeOrderUri = '/api/v1/customer/order/place';
  static const String addressListUri = '/api/v1/customer/address/list';
  static const String removeAddressUri =
      '/api/v1/customer/address/delete?address_id=';
  static const String addAddressUri = '/api/v1/customer/address/add';
  static const String updateAddressUri = '/api/v1/customer/address/update/';
  static const String setMenuUri = '/api/v1/products/set-menu';
  static const String customerInfoUri = '/api/v1/customer/info';
  static const String couponUri = '/api/v1/coupon/list';
  static const String couponApplyUri = '/api/v1/coupon/apply?code=';
  static const String orderListUri = '/api/v1/customer/order/list';
  static const String orderCancelUri = '/api/v1/customer/order/cancel';
  static const String orderDetailsUri =
      '/api/v1/customer/order/details?order_id=';
  static const String wishListGetUri = '/api/v1/customer/wish-list';
  static const String addWishListUri = '/api/v1/customer/wish-list/add';
  static const String removeWishListUri = '/api/v1/customer/wish-list/remove';
  static const String notificationUri = '/api/v1/notifications';
  static const String pushNotificationUri =
      'https://fcm.googleapis.com/fcm/send';
  static const String updateProfileUri = '/api/v1/customer/update-profile';
  static const String searchUri = '/api/v1/products/search?name=';
  static const String reviewUri = '/api/v1/products/reviews/submit';
  static const String productDetailsUri = '/api/v1/products/details/';
  static const String lastLocationUri =
      '/api/v1/delivery-man/last-location?order_id=';
  static const String deliverManReviewUri =
      '/api/v1/delivery-man/reviews/submit';
  static const String distanceMatrixUri = '/api/v1/mapapi/distance-api';
  static const String searchLocationUri =
      '/api/v1/mapapi/place-api-autocomplete';
  static const String placeDetailsUri = '/api/v1/mapapi/place-api-details';
  static const String geocodeUri = '/api/v1/mapapi/geocode-api';
  static const String getImagesUrl = '/api/v1/customer/message/chat-images';
  static const String getDeliverymanMessageUri =
      '/api/v1/customer/message/get-order-message';
  static const String getAdminMessageUrl =
      '/api/v1/customer/message/get-admin-message';
  static const String sendMessageToAdminUrl =
      '/api/v1/customer/message/send-admin-message';
  static const String sendMessageToDeliveryManUrl =
      '/api/v1/customer/message/send/customer';
  static const String emailSubscribeUri = '/api/v1/subscribe-newsletter';
  static const String customerRemove = '/api/v1/customer/remove-account';
  static const String policyPage = '/api/v1/pages';
  static const String socialLogin = '/api/v1/auth/social-customer-login';
  static const String walletTransactionUrl =
      '/api/v1/customer/wallet-transactions';
  static const String loyaltyTransactionUrl =
      '/api/v1/customer/loyalty-point-transactions';
  static const String loyaltyPointTransferUrl =
      '/api/v1/customer/transfer-point-to-wallet';
  static const String walletBonusListUrl = '/api/v1/customer/bonus/list';
  static const String addGuest = '/api/v1/guest/add';
  static const String offlinePaymentMethod =
      '/api/v1/offline-payment-method/list';
  static const String guestTrackUrl = '/api/v1/customer/order/guest-track';
  static const String guestOrderDetailsUrl =
      '/api/v1/customer/order/details-guest';
  static const String firebaseAuthVerify = '/api/v1/auth/firebase-auth-verify';

  // Shared Key
  static const String theme = 'theme';
  static const String token = 'token';
  static const String languageCode = 'language_code';
  static const String countryCode = 'country_code';
  static const String cartList = 'cart_list';
  static const String userPassword = 'user_password';
  static const String userAddress = 'user_address';
  static const String userNumber = 'user_number';
  static const String userLogData = 'user_log_data';
  static const String searchAddress = 'search_address';
  static const String topic = 'notify';
  static const String onBoardingSkip = 'on_boarding_skip';
  static const String placeOrderData = 'place_order_data';
  static const String branch = 'branch';
  static const String cookiesManagement = 'cookies_management';
  static const String guestId = 'guest_id';
  static const String walletToken = 'wallet_token';

  static List<LanguageModel> languages = [
    LanguageModel(
        imageUrl: Images.unitedKingdom,
        languageName: 'English',
        countryCode: 'US',
        languageCode: 'en'),
    LanguageModel(
        imageUrl: Images.arabic,
        languageName: 'Arabic',
        countryCode: 'SA',
        languageCode: 'ar'),
    LanguageModel(
        imageUrl: Images.bd,
        languageName: 'Bengali',
        countryCode: 'BD',
        languageCode: 'bn'),
    LanguageModel(
        imageUrl: Images.india,
        languageName: 'Hindi',
        countryCode: 'IN',
        languageCode: 'hi'),
    LanguageModel(
        imageUrl: Images.spain,
        languageName: 'Spanish',
        countryCode: 'ES',
        languageCode: 'es'),
  ];

  static const int balanceInputLen = 10;

  static final List<Map<String, String>> walletTransactionSortingList = [
    {'title': 'all_transactions', 'value': 'all'},
    {'title': 'order_transactions', 'value': 'order_place'},
    {
      'title': 'converted_from_loyalty_point',
      'value': 'loyalty_point_to_wallet'
    },
    {'title': 'added_via_payment_method', 'value': 'add_fund'},
    {'title': 'earned_by_referral', 'value': 'referral_order_place'},
    {'title': 'earned_by_bonus', 'value': 'add_fund_bonus'},
    {'title': 'added_by_admin', 'value': 'add_fund_by_admin'},
  ];
}
