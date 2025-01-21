import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/address_model.dart';
import 'package:flutter_restaurant/data/model/response/category_model.dart';
import 'package:flutter_restaurant/data/model/response/order_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/data/model/response/qr_code_mode.dart';
import 'package:flutter_restaurant/helper/html_type.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/branch_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/view/base/map_widget.dart';
import 'package:flutter_restaurant/view/base/not_found.dart';
import 'package:flutter_restaurant/view/screens/address/add_new_address_screen.dart';
import 'package:flutter_restaurant/view/screens/address/address_screen.dart';
import 'package:flutter_restaurant/view/screens/auth/create_account_screen.dart';
import 'package:flutter_restaurant/view/screens/auth/login_screen.dart';
import 'package:flutter_restaurant/view/screens/auth/maintainance_screen.dart';
import 'package:flutter_restaurant/view/screens/branch/branch_list_screen.dart';
import 'package:flutter_restaurant/view/screens/category/branch_category_screen.dart';
import 'package:flutter_restaurant/view/screens/category/category_screen.dart';
import 'package:flutter_restaurant/view/screens/chat/chat_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/checkout_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/order_successful_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/payment_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/order_web_payment.dart';
import 'package:flutter_restaurant/view/screens/coupon/coupon_screen.dart';
import 'package:flutter_restaurant/view/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_restaurant/view/screens/forgot_password/create_new_password_screen.dart';
import 'package:flutter_restaurant/view/screens/forgot_password/forgot_password_screen.dart';
import 'package:flutter_restaurant/view/screens/forgot_password/verification_screen.dart';
import 'package:flutter_restaurant/view/screens/home/widget/image_screen.dart';
import 'package:flutter_restaurant/view/screens/html/html_viewer_screen.dart';
import 'package:flutter_restaurant/view/screens/language/choose_language_screen.dart';
import 'package:flutter_restaurant/view/screens/loyalty_screen/loyalty_screen.dart';
import 'package:flutter_restaurant/view/screens/notification/notification_screen.dart';
import 'package:flutter_restaurant/view/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_restaurant/view/screens/order/order_details_screen.dart';
import 'package:flutter_restaurant/view/screens/order/order_search_screen.dart';
import 'package:flutter_restaurant/view/screens/popular_item_screen/popular_item_screen.dart';
import 'package:flutter_restaurant/view/screens/profile/profile_screen.dart';
import 'package:flutter_restaurant/view/screens/rate_review/rate_review_screen.dart';
import 'package:flutter_restaurant/view/screens/refer_and_earn/refer_and_earn_screen.dart';
import 'package:flutter_restaurant/view/screens/search/search_result_screen.dart';
import 'package:flutter_restaurant/view/screens/search/search_screen.dart';
import 'package:flutter_restaurant/view/screens/setmenu/set_menu_screen.dart';
import 'package:flutter_restaurant/view/screens/splash/splash_screen.dart';
import 'package:flutter_restaurant/view/screens/support/support_screen.dart';
import 'package:flutter_restaurant/view/screens/track/order_tracking_screen.dart';
import 'package:flutter_restaurant/view/screens/update/update_screen.dart';
import 'package:flutter_restaurant/view/screens/wallet/wallet_screen.dart';
import 'package:flutter_restaurant/view/screens/welcome_screen/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum RouteAction{push, pushReplacement, popAndPush, pushNamedAndRemoveUntil}

class RouterHelper {

  static const String splashScreen = '/splash';
  static const String languageScreen = '/select-language';
  static const String onBoardingScreen = '/on_boarding';
  static const String welcomeScreen = '/welcome';
  static const String loginScreen = '/login';
  static const String verify = '/verify';
  static const String forgotPassScreen = '/forgot-password';
  static const String createNewPassScreen = '/create-new-password';
  static const String createAccountScreen = '/create-account';
  static const String dashboard = '/';
  static const String maintain = '/maintain';
  static const String update = '/update';
  static const String dashboardScreen = '/main';
  static const String searchScreen = '/search';
  static const String searchResultScreen = '/search-result';
  static const String setMenuScreen = '/set-menu';
  static const String categoryScreen = '/category';
  static const String notificationScreen = '/notification';
  static const String checkoutScreen = '/checkout';
  static const String paymentScreen = '/payment';
  static const String orderSuccessScreen = '/order-completed';
  static const String orderDetailsScreen = '/order-details';
  static const String rateScreen = '/rate-review';
  static const String orderTrackingScreen = '/order-tracking';
  static const String profileScreen = '/profile';
  static const String addressScreen = '/address';
  static const String mapScreen = '/map';
  static const String addAddressScreen = '/add-address';
  static const String selectLocationScreen = '/select-location';
  static const String chatScreen = '/messages';
  static const String couponScreen = '/coupons';
  static const String supportScreen = '/support';
  static const String termsScreen = '/terms';
  static const String policyScreen = '/privacy-policy';
  static const String aboutUsScreen = '/about-us';
  static const String imageDialog = '/image-dialog';
  static const String menuScreenWeb = '/menu_screen_web';
  static const String homeScreen = '/home';
  static const String orderWebPayment = '/order-web-payment';
  static const String popularItemRoute = '/POPULAR_ITEM_ROUTE';
  static const String returnPolicyScreen = '/return-policy';
  static const String refundPolicyScreen = '/refund-policy';
  static const String cancellationPolicyScreen = '/cancellation-policy';
  static const String wallet = '/wallet-screen';
  static const String referAndEarn = '/refer_and_earn';
  static const String branchListScreen = '/branch-list';
  static const String productImageScreen = '/image-screen';
  static const String qrCategoryScreen = '/qr-category-screen';
  static const String loyaltyScreen = '/loyalty-screen';
  static const String orderSearchScreen = '/order-search';



  static String getSplashRoute({RouteAction? action}) => _navigateRoute(splashScreen, route: action);
  static String getLanguageRoute(bool isFromMenu, {RouteAction? action}) => _navigateRoute('$languageScreen?page=${isFromMenu ? 'menu' : 'splash'}', route: action);
  static String getOnBoardingRoute({RouteAction? action}) => _navigateRoute(onBoardingScreen, route: action);
  static String getWelcomeRoute() => _navigateRoute(welcomeScreen, route: RouteAction.pushReplacement);
  static String getLoginRoute({RouteAction? action}) => _navigateRoute(loginScreen, route: action);
  static String getForgetPassRoute() => _navigateRoute(forgotPassScreen);
  static String getNewPassRoute(String emailOrPhone, String token) => _navigateRoute('$createNewPassScreen?email_or_phone=${Uri.encodeComponent(emailOrPhone)}&token=$token');
  static String getVerifyRoute(String page, String email,  {String? session, RouteAction? action}) {
    String data = Uri.encodeComponent(jsonEncode(email));
    String authSession = base64Url.encode(utf8.encode(session ?? ''));
    return _navigateRoute('$verify?page=$page&email=$data&data=$authSession', route: action);
  }

  static String getCreateAccountRoute()=> _navigateRoute(createAccountScreen);
  static String getMainRoute({RouteAction? action}) => _navigateRoute(dashboard, route: action);
  static String getMaintainRoute({RouteAction? action}) => _navigateRoute(maintain, route: RouteAction.pushReplacement);
  static String getUpdateRoute({RouteAction? action}) => _navigateRoute(update, route: action);
  static String getHomeRoute({required String fromAppBar})=> _navigateRoute('$homeScreen?from=$fromAppBar');
  static String getDashboardRoute(String page, {RouteAction? action}) => _navigateRoute('$dashboardScreen?page=$page', route: action);
  static String getSearchRoute() => _navigateRoute(searchScreen);
  static String getSearchResultRoute(String text) {
    return _navigateRoute('$searchResultScreen?text=${Uri.encodeComponent(jsonEncode(text))}');
  }
  static String getSetMenuRoute() => _navigateRoute(setMenuScreen);
  static String getNotificationRoute() => _navigateRoute(notificationScreen);
  static String getCategoryRoute(CategoryModel categoryModel ,{RouteAction? action} ) {
    String imageUrl = base64Url.encode(utf8.encode(categoryModel.bannerImage ?? ''));
    return _navigateRoute('$categoryScreen?id=${categoryModel.id}&name=${categoryModel.name}&img=$imageUrl', route: action);  }
  static String getCheckoutRoute(double? amount, String page, String? type, String? code) {
    String amount0= base64Url.encode(utf8.encode(amount.toString()));
    return _navigateRoute('$checkoutScreen?amount=$amount0&page=$page&type=$type&code=$code');
  }

  static String getPaymentRoute(String url, {bool fromCheckout = true}) {
    return _navigateRoute('$paymentScreen?url=${Uri.encodeComponent(url)}&from_checkout=$fromCheckout');
  }
  static String getOrderDetailsRoute(String? id, {String? phoneNumber}) => _navigateRoute('$orderDetailsScreen?id=$id&phone=${Uri.encodeComponent('$phoneNumber')}');
  static String getRateReviewRoute({required orderId, String? phoneNumber}) => _navigateRoute('$rateScreen?id=$orderId&phone=${Uri.encodeComponent('$phoneNumber')}');
  static String getOrderTrackingRoute(int? id, {String? phoneNumber}) => _navigateRoute('$orderTrackingScreen?id=$id&phone=${Uri.encodeComponent('$phoneNumber')}');
  static String getProfileRoute() => _navigateRoute(profileScreen);
  static String getAddressRoute() => _navigateRoute(addressScreen);
  static String getMapRoute(AddressModel addressModel, {DeliveryAddress? deliveryAddress}) {
    List<int> encoded = utf8.encode(jsonEncode(deliveryAddress != null ? deliveryAddress.toJson() : addressModel.toJson()));
    String data = base64Encode(encoded);
    return _navigateRoute('$mapScreen?address=$data');
  }
  static String getAddAddressRoute(String page, String action, AddressModel addressModel) {
    String data = base64Url.encode(utf8.encode(jsonEncode(addressModel.toJson())));
    return _navigateRoute('$addAddressScreen?page=$page&action=$action&address=$data');
  }
  static String getSelectLocationRoute() => _navigateRoute(selectLocationScreen);
  static String getChatRoute({OrderModel? orderModel}) {
    String orderModel0 = base64Url.encode(utf8.encode(jsonEncode(orderModel?.toJson())));

    return _navigateRoute('$chatScreen?order=$orderModel0');
  }
  static String getCouponRoute() => _navigateRoute(couponScreen);
  static String getSupportRoute() => _navigateRoute(supportScreen);
  static String getTermsRoute() => _navigateRoute(termsScreen);
  static String getPolicyRoute() => _navigateRoute(policyScreen);
  static String getAboutUsRoute() => _navigateRoute(aboutUsScreen);
  static String getPopularItemScreen() => _navigateRoute(popularItemRoute);
  static String getReturnPolicyRoute() => _navigateRoute(returnPolicyScreen);
  static String getCancellationPolicyRoute() => _navigateRoute(cancellationPolicyScreen);
  static String getRefundPolicyRoute() => _navigateRoute(refundPolicyScreen);
  static String getWalletRoute(bool fromWallet, {String? token, String? flag, RouteAction? action}) => _navigateRoute('$wallet?page=${fromWallet ? 'wallet' : 'loyalty_points'}&&token=$token&&flag=$flag', route: action);
  static String getReferAndEarnRoute() => _navigateRoute(referAndEarn);
  static String getBranchListScreen({RouteAction action = RouteAction.push}) => _navigateRoute(branchListScreen, route: action);
  static String getProductImageScreen(Product product)  {
    String productJson = base64Encode(utf8.encode(jsonEncode(product)));
    return _navigateRoute('$productImageScreen?product=$productJson');
  }
  static getQrCategoryScreen({String? qrData}) => _navigateRoute('$qrCategoryScreen?qrcode=$qrData');
  static String getLoyaltyScreen() => _navigateRoute(loyaltyScreen);
  static String getOrderSearchScreen() => _navigateRoute(orderSearchScreen);
  static String getOrderSuccessScreen(String orderId, String statusMessage) => _navigateRoute('$orderSuccessScreen?order_id=$orderId&status=$statusMessage', route: RouteAction.pushReplacement);

  static String _navigateRoute( String path,{ RouteAction? route = RouteAction.push}) {
    if(route == RouteAction.pushNamedAndRemoveUntil){
      Get.context?.go(path);
    }else if(route == RouteAction.pushReplacement){
      Get.context?.pushReplacement(path);
    }else{
      Get.context?.push(path);
    }
    return path;
  }




  static  Widget _routeHandler(BuildContext context, Widget route, {bool isBranchCheck = false}) {
   return Provider.of<SplashProvider>(context, listen: false).configModel!.maintenanceMode!
       ? const MaintenanceScreen() : (Provider.of<BranchProvider>(context, listen: false).getBranchId() != -1 || !isBranchCheck)
       ?  route : const BranchListScreen();

  }

  static final goRoutes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: ResponsiveHelper.isMobilePhone() ? getSplashRoute() : getMainRoute(),
    errorBuilder: (ctx, _)=> const NotFound(),
    routes: [
      GoRoute(path: splashScreen, builder: (context, state) => const SplashScreen()),
      GoRoute(path: maintain, builder: (context, state) => _routeHandler(context, const MaintenanceScreen())),
      GoRoute(path: languageScreen, builder: (context, state) => ChooseLanguageScreen(fromMenu: state.uri.queryParameters['page'] == 'menu')),
      GoRoute(path: onBoardingScreen, builder: (context, state) => OnBoardingScreen()),
      GoRoute(path: welcomeScreen, builder: (context, state) => _routeHandler(context, const WelcomeScreen())),
      GoRoute(path: loginScreen, builder: (context, state) => _routeHandler(context, const LoginScreen())),
      GoRoute(path: verify, builder: (context, state) {
        return _routeHandler(context, VerificationScreen(
          fromSignUp: state.uri.queryParameters['page'] == 'sign-up',
          emailAddress: jsonDecode(state.uri.queryParameters['email'] ?? ''),
          session: state.uri.queryParameters['data'] == 'null'
              ? null
              : utf8.decode(base64Url.decode(state.uri.queryParameters['data'] ?? '')),
        ));
      }),
      GoRoute(path: forgotPassScreen, builder: (context, state) => _routeHandler(context, const ForgotPasswordScreen())),
      GoRoute(path: createNewPassScreen, builder: (context, state) => _routeHandler(context, CreateNewPasswordScreen(
        emailOrPhone: Uri.decodeComponent(state.uri.queryParameters['email_or_phone'] ?? ''),
        resetToken: state.uri.queryParameters['token'],
      ))),
      GoRoute(path: createAccountScreen, builder: (context, state) => _routeHandler(context,  const CreateAccountScreen())),

      GoRoute(path: dashboardScreen, builder: (context, state) {
        return _routeHandler(context, DashboardScreen(
          pageIndex: state.uri.queryParameters['page'] == 'home'
              ? 0 : state.uri.queryParameters['page'] == 'cart'
              ? 1 : state.uri.queryParameters['page'] == 'order'
              ? 2 : state.uri.queryParameters['page'] == 'favourite'
              ? 3 : state.uri.queryParameters['page'] == 'menu'
              ? 4 : 0,
        ), isBranchCheck: true);
      }),

      GoRoute(path: homeScreen, builder: (context, state) => _routeHandler(context,  const DashboardScreen(pageIndex: 0), isBranchCheck: true)),
      GoRoute(path: dashboard, builder: (context, state) => _routeHandler(context,  const DashboardScreen(pageIndex: 0), isBranchCheck: true)),
      GoRoute(path: searchScreen, builder: (context, state) => _routeHandler(context,const SearchScreen())),
      GoRoute(path: searchResultScreen, builder: (context, state) => _routeHandler(
        context, SearchResultScreen(searchString: jsonDecode(state.uri.queryParameters['text'] ?? '')), isBranchCheck: true,
      )),
      GoRoute(path: update, builder: (context, state) => _routeHandler(context, const UpdateScreen())),
      GoRoute(path: setMenuScreen, builder: (context, state) => _routeHandler(context, const SetMenuScreen(), isBranchCheck: true)),
      GoRoute(path: categoryScreen,  builder: (context, state) {
        String image  = utf8.decode(base64Decode(state.uri.queryParameters['img'] ?? ''));

        return _routeHandler(context, CategoryScreen(
          categoryId: state.uri.queryParameters['id']!,
          categoryName: state.uri.queryParameters['name'],
          categoryBannerImage: image,
        ), isBranchCheck: true);
      }),

      GoRoute(path: notificationScreen, builder: (context, state) => _routeHandler(context, const NotificationScreen())),
      GoRoute(path: checkoutScreen, builder: (context, state){
        String amount  = '${jsonDecode(utf8.decode(base64Decode(state.uri.queryParameters['amount'] ?? '')))}';
        bool fromCart = state.uri.queryParameters['page'] == 'cart';
        return _routeHandler(context, (!fromCart ? const NotFound() : CheckoutScreen(
          amount: double.tryParse(amount), orderType: state.uri.queryParameters['type'], cartList: null,
          fromCart: state.uri.queryParameters['page'] == 'cart', couponCode: state.uri.queryParameters['code'],
        )), isBranchCheck: true);
      }),

      GoRoute(path: paymentScreen, builder: (context, state)=> _routeHandler(context,  PaymentScreen(
        url: Uri.decodeComponent('${state.uri.queryParameters['url']}'), formCheckout: state.uri.queryParameters['from_checkout'] == 'true',
      ), isBranchCheck: true)),

      GoRoute(path: orderWebPayment, builder: (context, state) =>  _routeHandler(context, OrderWebPayment(token: state.uri.queryParameters['token']), isBranchCheck: true)),
      GoRoute(path: orderDetailsScreen, builder: (context, state) =>  _routeHandler(context, OrderDetailsScreen(
        orderId: int.parse(state.uri.queryParameters['id'] ?? ''), orderModel: null,
        phoneNumber: '${state.uri.queryParameters['phone']}' != 'null' && '${state.uri.queryParameters['phone']}' != ''
            ? '+${state.uri.queryParameters['phone']}'.replaceAll('++', '+').replaceAll(' ', '') : null,
      ))),

      GoRoute(path: rateScreen, builder: (context, state) =>  _routeHandler(context, RateReviewScreen(
        orderId: int.parse('${state.uri.queryParameters['id']}'),
        phoneNumber: '${state.uri.queryParameters['phone']}' != 'null' && '${state.uri.queryParameters['phone']}' != ''
            ? '${state.uri.queryParameters['phone']}' : null,
      ))),
      GoRoute(path: orderTrackingScreen, builder: (context, state) => _routeHandler(context, OrderTrackingScreen(
        orderID: state.uri.queryParameters['id'] == 'null' ? null : state.uri.queryParameters['id'],
        phoneNumber: '${state.uri.queryParameters['phone']}' != 'null' && '${state.uri.queryParameters['phone']}' != '' ? '${state.uri.queryParameters['phone']}' : null,
      ))),
      GoRoute(path: profileScreen, builder: (context, state) => _routeHandler(context,  const ProfileScreen())),
      GoRoute(path: addressScreen, builder: (context, state) => _routeHandler(context,  const AddressScreen())),
      GoRoute(path: mapScreen, builder: (context, state) {
        List<int> decode = base64Decode('${state.uri.queryParameters['address']?.replaceAll(' ', '+')}');
        DeliveryAddress data = DeliveryAddress.fromJson(jsonDecode(utf8.decode(decode)));
        return _routeHandler(context,  MapWidget(address: data));
      }),
      GoRoute(path: addAddressScreen, builder: (context, state) {
        bool isUpdate = state.uri.queryParameters['action'] == 'update';
        AddressModel? addressModel;
        if(isUpdate) {
          String decoded = utf8.decode(base64Url.decode('${state.uri.queryParameters['address']?.replaceAll(' ', '+')}'));
          addressModel = AddressModel.fromJson(jsonDecode(decoded));
        }
        return _routeHandler(context, AddNewAddressScreen(
            fromCheckout: state.uri.queryParameters['page'] == 'checkout',
            isEnableUpdate: isUpdate,
            address: isUpdate ? addressModel : null),
        );
      }),
      GoRoute(path: chatScreen, builder: (context, state) {
        OrderModel? orderModel;
        try{
          orderModel = OrderModel.fromJson(jsonDecode(utf8.decode(base64Url.decode('${state.uri.queryParameters['order']?.replaceAll(' ', '+')}'))));

        }catch(error){
          debugPrint('route- order_model - $error');
        }
        return _routeHandler(context,  ChatScreen(
          orderModel : orderModel,
        ));
      }),

      GoRoute(path: couponScreen, builder: (context, state) => _routeHandler(context,  const CouponScreen())),
      GoRoute(path: supportScreen, builder: (context, state) => const SupportScreen()),
      GoRoute(path: termsScreen, builder: (context, state) => const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition)),
      GoRoute(path: policyScreen, builder: (context, state) => const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy)),
      GoRoute(path: aboutUsScreen, builder: (context, state) => const HtmlViewerScreen(htmlType: HtmlType.aboutUs)),
      GoRoute(path: refundPolicyScreen, builder: (context, state) => const HtmlViewerScreen(htmlType: HtmlType.refundPolicy)),
      GoRoute(path: cancellationPolicyScreen, builder: (context, state) => const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy)),
      GoRoute(path: returnPolicyScreen, builder: (context, state) => _routeHandler(context, const HtmlViewerScreen(htmlType: HtmlType.returnPolicy))),
      GoRoute(path: popularItemRoute, builder: (context, state) => _routeHandler(context, const PopularItemScreen(), isBranchCheck: true)),
      GoRoute(path: wallet, builder: (context, state) => _routeHandler(context,  WalletScreen(
        token: state.uri.queryParameters['token'], status: state.uri.queryParameters['flag'],
      ))),
      
      GoRoute(path: referAndEarn, builder: (context, state) => _routeHandler(context,  const ReferAndEarnScreen())),
      GoRoute(path: branchListScreen, builder: (context, state) => _routeHandler(context,  const BranchListScreen())),
      GoRoute(path: productImageScreen, builder: (context, state){
        final productJson = jsonDecode(utf8.decode(base64Url.decode('${state.uri.queryParameters['product']?.replaceAll(' ', '+')}')));
        return _routeHandler(context, ProductImageScreen(product: Product.fromJson(productJson)), isBranchCheck: true);
      }),
      GoRoute(path: qrCategoryScreen, builder: (context, state){
        return Provider.of<SplashProvider>(context, listen: false).configModel == null ? SplashScreen(routeTo: '$qrCategoryScreen?qrcode=${state.uri.queryParameters['qrcode']}') :
        BranchCategoryScreen(
          qrCodeModel: '${state.uri.queryParameters['qrcode']}' == 'null' ? null :  QrCodeModel.fromMap(jsonDecode(utf8.decode(base64Url.decode('${state.uri.queryParameters['qrcode']?.replaceAll(' ', '+')}')))),
        );
      }),
      GoRoute(path: loyaltyScreen, builder: (context, state) => _routeHandler(context,  const LoyaltyScreen())),
      GoRoute(path: orderSearchScreen, builder: (context, state) => _routeHandler(context,  const OrderSearchScreen())),

      GoRoute(path: qrCategoryScreen, builder: (context, state) => Provider.of<SplashProvider>(context, listen: false).configModel == null ? SplashScreen(routeTo: getQrCategoryScreen(qrData: state.uri.queryParameters['qrcode'])) : BranchCategoryScreen(
        qrCodeModel: '${state.uri.queryParameters['qrcode']}' == 'null' ? null :  QrCodeModel.fromMap(jsonDecode(utf8.decode(base64Url.decode(state.uri.queryParameters['qrcode']!.replaceAll(' ', '+'))))),
      )),

      GoRoute(path: orderSuccessScreen, builder: (context, state) {
        int status = (state.uri.queryParameters['status'] == 'success' || state.uri.queryParameters['status'] == 'payment-success')
            ? 0 : state.uri.queryParameters['status'] == 'payment-fail'
            ? 1 : state.uri.queryParameters['status'] == 'order-fail' ?  2 : 3;
        return _routeHandler(context, OrderSuccessfulScreen(orderID: state.uri.queryParameters['order_id'], status: status), isBranchCheck: true);
      }),

      GoRoute(path: orderSuccessScreen, builder: (context, state)=> _routeHandler(context, OrderWebPayment(token: state.uri.queryParameters['token']), isBranchCheck: true)),





    ],
  );
}