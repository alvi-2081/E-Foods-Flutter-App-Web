import 'dart:convert'as convert;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/body/place_order_body.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/checkout_helper.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/branch_provider.dart';
import 'package:flutter_restaurant/provider/coupon_provider.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class ConfirmButtonView extends StatelessWidget {
  final  bool kmWiseCharge;
  final double? deliveryCharge;
  final double orderAmount;
  final List<CartModel?> cartList;
  final String orderType;
  final String? couponCode;
  final TextEditingController noteController;
  final Function callBack;

  const ConfirmButtonView({Key? key, required this.kmWiseCharge, this.deliveryCharge, required this.cartList, required this.orderAmount, required this.orderType, this.couponCode, required this.noteController, required this.callBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BranchProvider branchProvider = Provider.of<BranchProvider>(context, listen: false);
    final takeAway =  orderType == 'take_away';

    return Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
          return Container(
            width: 1170,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: !orderProvider.isLoading ? Builder(
              builder: (context) => CustomButton(
                  btnTxt: getTranslated('confirm_order', context),
                  onTap: () {
                    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
                    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);


                    if(orderProvider.selectedPaymentMethod != null || orderProvider.selectedOfflineValue != null){
                      bool isAvailable = true;
                      DateTime scheduleStartDate = DateTime.now();
                      DateTime scheduleEndDate = DateTime.now();
                      if(orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
                        isAvailable = false;
                      }else {
                        DateTime date = orderProvider.selectDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
                        DateTime startTime = orderProvider.timeSlots![orderProvider.selectTimeSlot].startTime!;
                        DateTime endTime = orderProvider.timeSlots![orderProvider.selectTimeSlot].endTime!;
                        scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
                        scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
                        for (CartModel? cart in cartList) {
                          if (!DateConverter.isAvailable(cart!.product!.availableTimeStarts!, cart.product!.availableTimeEnds!, context, time: scheduleStartDate,)
                              && !DateConverter.isAvailable(cart.product!.availableTimeStarts!, cart.product!.availableTimeEnds!, context, time: scheduleEndDate)
                          ) {
                            isAvailable = false;
                            break;
                          }
                        }
                      }

                      if(orderAmount < configModel.minimumOrderValue!) {
                        showCustomSnackBar('Minimum order amount is ${configModel.minimumOrderValue}');
                      }else if(orderProvider.partialAmount != null && (orderProvider.selectedPaymentMethod == null ? (orderProvider.selectedOfflineValue == null) : orderProvider.selectedPaymentMethod == null )){
                        showCustomSnackBar(getTranslated('add_a_payment_method', context));

                      } else if(!takeAway && (locationProvider.addressList == null || locationProvider.addressList!.isEmpty || orderProvider.addressIndex < 0)) {
                        showCustomSnackBar(getTranslated('select_an_address', context));
                      }else if (orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
                        showCustomSnackBar(getTranslated('select_a_time', context));
                      }else if (!isAvailable) {
                        showCustomSnackBar(getTranslated('one_or_more_products_are_not_available_for_this_selected_time', context));
                      }else if (!takeAway && kmWiseCharge && orderProvider.distance == -1) {
                        showCustomSnackBar(getTranslated('delivery_fee_not_set_yet', context));
                      }else {
                        List<Cart> carts = [];
                        for (int index = 0; index < cartList.length; index++) {
                          CartModel cart = cartList[index]!;
                          List<int?> addOnIdList = [];
                          List<int?> addOnQtyList = [];
                          List<OrderVariation> variations = [];

                          for (var addOn in cart.addOnIds!) {
                            addOnIdList.add(addOn.id);
                            addOnQtyList.add(addOn.quantity);
                          }

                          if(cart.product!.variations != null && cart.variations != null && cart.variations!.isNotEmpty){
                            for(int i=0; i<cart.product!.variations!.length; i++) {
                              if(  cart.variations![i].contains(true)) {
                                variations.add(OrderVariation(
                                  name: cart.product!.variations![i].name,
                                  values: OrderVariationValue(label: []),
                                ));

                                for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
                                  if(cart.variations![i][j]!) {
                                    variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
                                  }
                                }
                              }
                            }
                          }


                          carts.add(Cart(
                            cart.product!.id.toString(), cart.discountedPrice.toString(), [], variations,
                            cart.discountAmount, cart.quantity, cart.taxAmount, addOnIdList, addOnQtyList,
                          ));
                        }

                        PlaceOrderBody placeOrderBody = PlaceOrderBody(
                          cart: carts, couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount,
                          couponDiscountTitle: couponCode,
                          deliveryAddressId: !takeAway ? Provider.of<LocationProvider>(context, listen: false)
                              .addressList![orderProvider.addressIndex].id : 0,
                          orderAmount: double.parse(orderAmount.toStringAsFixed(2)),
                          orderNote: noteController.text, orderType: orderType,
                          paymentMethod: orderProvider.selectedOfflineValue != null
                              ? 'offline_payment' : orderProvider.selectedPaymentMethod!.getWay!,
                          couponCode: couponCode,
                          distance: takeAway ? 0 : orderProvider.distance,
                          branchId: branchProvider.getBranch()?.id,
                          deliveryDate: DateFormat('yyyy-MM-dd').format(scheduleStartDate),
                          paymentInfo: orderProvider.selectedOfflineValue != null ?  OfflinePaymentInfo(
                            methodFields: CheckOutHelper.getOfflineMethodJson(orderProvider.selectedOfflineMethod?.methodFields),
                            methodInformation: orderProvider.selectedOfflineValue,
                            paymentName: orderProvider.selectedOfflineMethod?.methodName,
                            paymentNote: orderProvider.selectedOfflineMethod?.paymentNote,
                          ) : null,
                          deliveryTime: (orderProvider.selectTimeSlot == 0 && orderProvider.selectDateSlot == 0) ? 'now' : DateFormat('HH:mm').format(scheduleStartDate),
                          isPartial: orderProvider.partialAmount == null ? '0' : '1' ,
                        );

                        if(placeOrderBody.paymentMethod == 'wallet_payment'
                            || placeOrderBody.paymentMethod == 'cash_on_delivery'
                            || placeOrderBody.paymentMethod == 'offline_payment') {
                          orderProvider.placeOrder(placeOrderBody, callBack);
                        }
                        else {
                          String? hostname = html.window.location.hostname;
                          String protocol = html.window.location.protocol;
                          String port = html.window.location.port;
                          final String placeOrder =  convert.base64Url.encode(convert.utf8.encode(convert.jsonEncode(placeOrderBody.toJson())));

                          String url = "customer_id=${authProvider.getGuestId() ?? profileProvider.userInfoModel!.id}&&is_guest=${authProvider.getGuestId() != null ? '1' :'0'}"
                              "&&callback=${AppConstants.baseUrl}${RouterHelper.orderSuccessScreen}&&order_amount=${(orderAmount + (deliveryCharge ?? 0)).toStringAsFixed(2)}";

                          String webUrl = "customer_id=${authProvider.getGuestId() ?? profileProvider.userInfoModel!.id}&&is_guest=${authProvider.getGuestId() != null ? '1' :'0'}"
                              "&&callback=$protocol//$hostname${kDebugMode ? ':$port' : ''}${RouterHelper.orderWebPayment}&&order_amount=${(orderAmount + (deliveryCharge ?? 0)).toStringAsFixed(2)}&&status=";


                          String tokenUrl = convert.base64Encode(convert.utf8.encode(ResponsiveHelper.isWeb() ? (webUrl) : url));
                          String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?token=$tokenUrl&&payment_method=${orderProvider.selectedPaymentMethod?.getWay}&&payment_platform=${kIsWeb ? 'web' : 'app'}&&is_partial=${orderProvider.partialAmount == null ? '0' : '1'}';

                          orderProvider.clearPlaceOrder().then((_) => orderProvider.setPlaceOrder(placeOrder).then((value) {
                            if(kIsWeb){
                              html.window.open(selectedUrl,"_self");
                            }else{
                              context.pop();
                              RouterHelper.getPaymentRoute(selectedUrl, fromCheckout: true);
                            }

                          }));
                        }
                      }
                    } else{
                      showCustomSnackBar(getTranslated('select_payment_method', context));
                    }
                  }),
            ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
          );
        }
    );
  }
}