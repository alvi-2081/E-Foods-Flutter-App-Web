import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/base/error_response.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ApiChecker {
  static void checkApi(ApiResponse apiResponse,{bool firebaseResponse = false} ) {
    ErrorResponse error = getError(apiResponse);
    if( error.errors![0].code == '401' || error.errors![0].code == 'auth-001'
        && ModalRoute.of(Get.context!)?.settings.name != RouterHelper.loginScreen) {
      Provider.of<AuthProvider>(Get.context!, listen: false).clearSharedData(Get.context!).then((value) {
        if(Get.context != null && ModalRoute.of(Get.context!)!.settings.name != RouterHelper.loginScreen) {
          RouterHelper.getLoginRoute(action: RouteAction.pushNamedAndRemoveUntil);
        }
      });

    }else {
      showCustomSnackBar(firebaseResponse ? error.errors?.first.message?.replaceAll('_', ' ').toCapitalized() : error.errors!.first.message);
    }
  }

  static ErrorResponse getError(ApiResponse apiResponse){
    ErrorResponse error;

    try{
      error = ErrorResponse.fromJson(apiResponse);
    }catch(e){
      if(apiResponse.error is String){
        error = ErrorResponse(errors: [Errors(code: '', message: apiResponse.error.toString())]);

      }else{
        error = ErrorResponse.fromJson(apiResponse.error);
      }
    }
    return error;
  }
}