import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/offline_payment_model.dart';
import 'package:flutter_restaurant/data/model/response/userinfo_model.dart';

class CheckOutHelper{
  static bool isWalletPayment({required ConfigModel configModel, required bool isLogin, required double? partialAmount, required bool isPartialPayment}){
    return configModel.walletStatus! && configModel.isPartialPayment! && isLogin && (partialAmount == null) && !isPartialPayment;
  }

  static bool isPartialPayment({required ConfigModel configModel, required bool isLogin, required UserInfoModel? userInfoModel}){
    return isLogin && configModel.isPartialPayment! && configModel.walletStatus! && (userInfoModel != null && userInfoModel.walletBalance! > 0);
  }

  static bool isPartialPaymentSelected({required int? paymentMethodIndex, required PaymentMethod? selectedPaymentMethod}){
    return (paymentMethodIndex == 1 && selectedPaymentMethod != null);
  }

  static List<Map<String, dynamic>> getOfflineMethodJson(List<MethodField>? methodList){
    List<Map<String, dynamic>> mapList = [];
    List<String?> keyList = [];
    List<String?> valueList = [];

    for(MethodField methodField in (methodList ?? [])){
      keyList.add(methodField.fieldName);
      valueList.add(methodField.fieldData);
    }

    for(int i = 0; i < keyList.length; i++) {
      mapList.add({'${keyList[i]}' : '${valueList[i]}'});
    }

    return mapList;
  }

}