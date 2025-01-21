// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/response_model.dart';
import 'package:flutter_restaurant/data/model/response/signup_model.dart';
import 'package:flutter_restaurant/data/model/response/social_login_model.dart';
import 'package:flutter_restaurant/data/model/response/user_log_data.dart';
import 'package:flutter_restaurant/data/repository/auth_repo.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../helper/api_checker.dart';
import '../localization/language_constrants.dart';
import '../view/base/custom_snackbar.dart';


class AuthProvider with ChangeNotifier {
  final AuthRepo? authRepo;

  AuthProvider({required this.authRepo});

  // for registration section
  bool _isLoading = false;
  String? _registrationErrorMessage = '';
  bool _isCheckedPhone = false;
  Timer? _timer;


  bool get isLoading => _isLoading;
  bool get isCheckedPhone => _isCheckedPhone;
  String? get registrationErrorMessage => _registrationErrorMessage;

  int? currentTime;
  set setIsLoading(bool value)=> _isLoading = value;


  updateRegistrationErrorMessage(String message) {
    _registrationErrorMessage = message;
    notifyListeners();
  }

  Future<ResponseModel> registration(SignUpModel signUpModel, ConfigModel config) async {
    _isLoading = true;
    _isCheckedPhone = false;
    _registrationErrorMessage = '';

    ResponseModel responseModel;
    String? token;
    String? tempToken;

    notifyListeners();

    ApiResponse apiResponse = await authRepo!.registration(signUpModel);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar(getTranslated('registration_successful', Get.context!), isError: false);

      Map map = apiResponse.response!.data;
      if(map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      }else if(map.containsKey('token')){
        token = map["token"];
      }

      if(token != null){
        await login(signUpModel.email, signUpModel.password);
        responseModel = ResponseModel(true, 'successful');
      }else{
        _isCheckedPhone = true;
        sendVerificationCode(config, signUpModel);
        responseModel = ResponseModel(false, tempToken);
      }

    } else {

      _registrationErrorMessage = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _registrationErrorMessage);
    }
    _isLoading = false;
    notifyListeners();

    return responseModel;
  }

  // for login section
  String? _loginErrorMessage = '';

  String? get loginErrorMessage => _loginErrorMessage;

  Future<ResponseModel> login(String? email, String? password) async {
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.login(email: email, password: password);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      String? token;
      String? tempToken;
      Map map = apiResponse.response!.data;
      if(map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      }else if(map.containsKey('token')){
        token = map["token"];

      }

      if(token != null){
        authRepo!.saveUserToken(token);
        final ProfileProvider profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
        profileProvider.getUserInfo(false, isUpdate: false);

        _updateAuthToken(token);

      }else if(tempToken != null){

        await sendVerificationCode(Provider.of<SplashProvider>(Get.context!, listen: false).configModel!, SignUpModel(email: email, phone: email));
      }

      responseModel = ResponseModel(token != null, 'verification');

    } else {

      _loginErrorMessage = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  // for forgot password
  bool _isForgotPasswordLoading = false;

  bool get isForgotPasswordLoading => _isForgotPasswordLoading;
  set setForgetPasswordLoading(bool value) => _isForgotPasswordLoading = value;

  Future<ResponseModel?> forgetPassword({required ConfigModel config, required String phoneOrEmail}) async {
    ResponseModel? responseModel;
    _isForgotPasswordLoading = true;
    notifyListeners();

    if(config.customerVerification!.status! && config.customerVerification?.type ==  'firebase') {
     await firebaseVerifyPhoneNumber(phoneOrEmail, isForgetPassword: true);

    }else{
     responseModel = await _forgetPassword(phoneOrEmail);

    }
    _isForgotPasswordLoading = false;
    notifyListeners();

    return responseModel;
  }

  Future<ResponseModel> _forgetPassword(String email) async {
    _isForgotPasswordLoading = true;
    resendButtonLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await authRepo!.forgetPassword(email);
    ResponseModel responseModel;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false, ApiChecker.getError(apiResponse).errors![0].message);
      ApiChecker.checkApi(apiResponse);
    }
    resendButtonLoading = false;
    _isForgotPasswordLoading = false;
    notifyListeners();

    return responseModel;
  }

  Future<void> updateToken() async {
    if(await authRepo!.getDeviceToken() != '@'){
      await authRepo!.updateToken();
    }
  }

  Future<ResponseModel> verifyToken(String email) async {
    _isPhoneNumberVerificationButtonLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.verifyToken(email, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false, ApiChecker.getError(apiResponse).errors![0].message);
    }
    return responseModel;
  }

  Future<ResponseModel> resetPassword(String? mail, String? resetToken, String password, String confirmPassword) async {
    _isForgotPasswordLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.resetPassword(mail, resetToken, password, confirmPassword);
    _isForgotPasswordLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false, ApiChecker.getError(apiResponse).errors![0].message);
    }
    return responseModel;
  }

  // for phone verification
  bool _isPhoneNumberVerificationButtonLoading = false;
  bool resendButtonLoading = false;


  bool get isPhoneNumberVerificationButtonLoading => _isPhoneNumberVerificationButtonLoading;
  String? _verificationMsg = '';

  String? get verificationMessage => _verificationMsg;
  String _email = '';
  String _phone = '';

  String get email => _email;
  String get phone => _phone;

  set setIsPhoneVerificationButttonLoading(bool value) => _isPhoneNumberVerificationButtonLoading = value;

  updateEmail(String email) {
    _email = email;
    notifyListeners();
  }
  updatePhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void clearVerificationMessage() {
    _verificationMsg = '';
  }

  Future<ResponseModel> checkEmail(String email) async {
    _isPhoneNumberVerificationButtonLoading = true;
    resendButtonLoading = true;

    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.checkEmail(email);

    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["token"]);
    } else {
      _verificationMsg = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _verificationMsg);

    }
    _isPhoneNumberVerificationButtonLoading = false;
    resendButtonLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> verifyEmail(String email) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.verifyEmail(email, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      String token = apiResponse.response!.data["token"];
      await _updateAuthToken(token);

      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {

      _verificationMsg = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _verificationMsg);
    }
    notifyListeners();
    return responseModel;
  }
  //phone
  Future<ResponseModel> checkPhone(String phone) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.checkPhone(phone);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["token"]);
    } else {

      _verificationMsg = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _verificationMsg);
    }
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> verifyPhone(String phone) async {
    _isPhoneNumberVerificationButtonLoading = true;
    String phoneNumber = phone;
    if(phone.contains('++')) {
     phoneNumber =  phone.replaceAll('++', '+');
    }
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.verifyPhone(phoneNumber, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {

      _verificationMsg = ApiChecker.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _verificationMsg);
    }
    notifyListeners();
    return responseModel;
  }

  // for verification Code
  String _verificationCode = '';

  String get verificationCode => _verificationCode;
  bool _isEnableVerificationCode = false;

  bool get isEnableVerificationCode => _isEnableVerificationCode;

  updateVerificationCode(String query) {
    if (query.length == 6) {
      _isEnableVerificationCode = true;
    } else {
      _isEnableVerificationCode = false;
    }
    _verificationCode = query;
    notifyListeners();
  }

  // for Remember Me Section

  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    notifyListeners();
  }

  bool isLoggedIn() {
    return authRepo!.isLoggedIn();
  }

  Future<bool> clearSharedData(BuildContext context) async {
    final authProvider =  Provider.of<AuthProvider>(context, listen: false);
    final cartProvider =  Provider.of<CartProvider>(context, listen: false);

    _isLoading = true;
    notifyListeners();

    bool isSuccess = await authRepo!.clearSharedData();
    await authProvider.socialLogout();
    await authRepo?.dioClient?.updateHeader(getToken: null);
    cartProvider.getCartData();

    if(getGuestId() != null){
      authRepo?.updateToken();
    }

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void saveUserNumberAndPassword(UserLogData userLogData) {
    authRepo!.saveUserNumberAndPassword(jsonEncode(userLogData.toJson()));
  }

  UserLogData? getUserData() {
    UserLogData? userData;

    try{
      userData = UserLogData.fromJson(jsonDecode(authRepo!.getUserLogData()));
    }catch(error) {
      debugPrint('error ===> $error');
    }

    return userData;
  }

  Future<bool> clearUserLogData() async {
    return authRepo!.clearUserLog();
  }

  String getUserToken() {
    return authRepo!.getUserToken();
  }

  Future deleteUser() async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await authRepo!.deleteUser();
    _isLoading = false;
    if (response.response!.statusCode == 200) {
      Provider.of<SplashProvider>(Get.context!, listen: false).removeSharedData();
      showCustomSnackBar(getTranslated('your_account_remove_successfully', Get.context!) );
      RouterHelper.getLoginRoute(action: RouteAction.pushReplacement);
    }else{
      Get.context?.pop();
      ApiChecker.checkApi(response);
    }
  }


  final GoogleSignIn _googleSignIn = GoogleSignIn(
  );
  GoogleSignInAccount? googleAccount;

  Future<GoogleSignInAuthentication> googleLogin() async {
    GoogleSignInAuthentication auth;
    googleAccount = await _googleSignIn.signIn();
    auth = await googleAccount!.authentication;
    return auth;
  }

  Future socialLogin(SocialLoginModel socialLogin, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.socialLogin(socialLogin);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String? message = '';
      String? token = '';
      try{
        message = map['error_message'] ?? '';
      }catch(e){
        debugPrint('error ===> $e');
      }
      try{
        token = map['token'];
      }catch(e){

      }

      if(token != null){
        authRepo!.saveUserToken(token);
        await authRepo!.updateToken();
      }

      callback(true, token, message);
      notifyListeners();

    }else {

      String? errorMessage = ApiChecker.getError(apiResponse).errors?.first.message;
      callback(false, '', errorMessage);
      notifyListeners();
    }
  }

  Future<void> socialLogout() async {
    final user = Provider.of<ProfileProvider>(Get.context!, listen: false).userInfoModel!;
    if(user.loginMedium!.toLowerCase() == 'google') {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      googleSignIn.disconnect();
    }else if(user.loginMedium!.toLowerCase() == 'facebook'){
      await FacebookAuth.instance.logOut();
    }

  }

  void startVerifyTimer(){
    _timer?.cancel();
    currentTime = Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.otpResendTime ?? 0;


    _timer =  Timer.periodic(const Duration(seconds: 1), (_){

      if(currentTime! > 0) {
        currentTime = currentTime! - 1;
      }else{
        _timer?.cancel();
      }notifyListeners();
    });

  }


  Future<void> addGuest() async {
    String? fcmToken = await  authRepo?.getDeviceToken();
    ApiResponse apiResponse = await authRepo!.addGuest(fcmToken);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200
        && apiResponse.response?.data['guest']['id'] != null) {
      authRepo?.saveGuestId('${apiResponse.response?.data['guest']['id']}');
    }
  }

  String? getGuestId()=> isLoggedIn() ? null : authRepo?.getGuestId();

  Future<void> firebaseVerifyPhoneNumber(String phoneNumber, {bool isForgetPassword = false})async {
    _isPhoneNumberVerificationButtonLoading = true;
    notifyListeners();


    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isPhoneNumberVerificationButtonLoading = false;
        notifyListeners();

        Get.context!.pop();

        if(e.code == 'invalid-phone-number') {
          showCustomSnackBar(getTranslated('please_submit_a_valid_phone_number', Get.context!));

        }else{
          showCustomSnackBar(getTranslated('${e.message}'.replaceAll('_', ' ').toCapitalized(), Get.context!));
        }

      },
      codeSent: (String vId, int? resendToken) {
        _isPhoneNumberVerificationButtonLoading = false;
        notifyListeners();

        bool isReplaceRoute = GoRouter.of(Get.context!).routeInformationProvider.value.uri.path == RouterHelper.verify;

        RouterHelper.getVerifyRoute(
          isForgetPassword ? 'forget-password' : 'sign-up',
          phoneNumber, session: vId,
          action: isReplaceRoute ? RouteAction.pushReplacement : RouteAction.push,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

  }

  Future<void> firebaseOtpLogin({required String phoneNumber, required String session, required String otp, bool isForgetPassword = false}) async {

    _isPhoneNumberVerificationButtonLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.firebaseAuthVerify(
      session: session, phoneNumber: phoneNumber,
      otp: otp, isForgetPassword: isForgetPassword,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String? token;
      String? tempToken;


      try{
        token = map["token"];
        tempToken = map["temp_token"];
      }catch(error){
      }

      if(isForgetPassword) {
        RouterHelper.getNewPassRoute(phoneNumber, otp);
      }else{
        if(token != null) {
          await _updateAuthToken(token);
           RouterHelper.getMainRoute(action: RouteAction.pushReplacement);

        }else if(tempToken != null){
          RouterHelper.getCreateAccountRoute();
        }
      }
    } else {
      ApiChecker.checkApi(apiResponse, firebaseResponse: true);
    }

    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
  }


  Future<void> sendVerificationCode(ConfigModel config, SignUpModel signUpModel) async {
    resendButtonLoading = true;
    notifyListeners();
    if(config.customerVerification!.status! && config.customerVerification?.type ==  'phone'){
      checkPhone(signUpModel.phone!);
    }else if(config.customerVerification!.status! && config.customerVerification?.type ==  'email'){
      checkEmail(signUpModel.email!);
    }else if(config.customerVerification!.status! && config.customerVerification?.type ==  'firebase'){
      firebaseVerifyPhoneNumber(signUpModel.phone!);
    }
    resendButtonLoading = false;
    notifyListeners();

  }


  Future<void> _updateAuthToken(String token) async {
     authRepo!.saveUserToken(token);
    await authRepo!.updateToken();
  }



}
