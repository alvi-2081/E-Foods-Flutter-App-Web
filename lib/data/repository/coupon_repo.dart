import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';

class CouponRepo {
  final DioClient? dioClient;
  CouponRepo({required this.dioClient});

  Future<ApiResponse> getCouponList({String? guestId}) async {
    try {
      final response = await dioClient!.get(guestId != null ? '${AppConstants.couponUri}?guest_id=$guestId' : AppConstants.couponUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> applyCoupon(String couponCode, {String? guestId}) async {
    try {
      final response = await dioClient!.get('${AppConstants.couponApplyUri}$couponCode${guestId != null ? '&&guest_id=$guestId' : ''}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}