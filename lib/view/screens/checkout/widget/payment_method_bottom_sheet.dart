import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/offline_payment_view.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/partial_pay_dialog.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/payment_button_new.dart';
import 'package:flutter_restaurant/view/screens/wallet/widget/add_fund_dialogue.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class PaymentMethodBottomSheet extends StatefulWidget {
  final double totalPrice;
  const PaymentMethodBottomSheet({Key? key, required this.totalPrice}) : super(key: key);

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = false;
  bool notHideCod = true;
  bool notHideDigital = true;
  bool notHideOffline = true;
  List<PaymentMethod> paymentList = [];

  @override
  void initState() {
    super.initState();

    final OrderProvider orderProvider =  Provider.of<OrderProvider>(context, listen: false);
    final AuthProvider authProvider =  Provider.of<AuthProvider>(context, listen: false);

    double? walletBalance = Provider.of<ProfileProvider>(context, listen: false).userInfoModel?.walletBalance;
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    orderProvider.setPaymentIndex(null, isUpdate: false);
    orderProvider.setOfflineSelectedValue(null, isUpdate: false);
    Future.delayed(const Duration(milliseconds: 500)).then((value){
      orderProvider.changePaymentMethod(isClear: true, isUpdate: true);
    });

    if(authProvider.isLoggedIn() && walletBalance != null && walletBalance > 0 && walletBalance >= widget.totalPrice){
      canSelectWallet = true;
    }
    if(orderProvider.partialAmount != null){
      if(configModel.partialPaymentCombineWith!.toLowerCase() == 'cod'){
        notHideCod = true;
        notHideDigital = false;
        notHideOffline = false;
      } else if(configModel.partialPaymentCombineWith!.toLowerCase() == 'digital_payment'){
        notHideCod = false;
        notHideDigital = true;
        notHideOffline = false;
      } else if(configModel.partialPaymentCombineWith!.toLowerCase() == 'offline_payment'){
        notHideCod = false;
        notHideDigital = false;
        notHideOffline = true;

      } else if(configModel.partialPaymentCombineWith!.toLowerCase() == 'all'){
        notHideCod = true;
        notHideDigital = true;
        notHideOffline = true;
      }
    }




    if(notHideDigital) {
      paymentList.addAll(configModel.activePaymentMethodList ?? []);
    }

    if(configModel.isOfflinePayment! && notHideOffline){
      paymentList.add(PaymentMethod(
        getWay: 'offline', getWayTitle: getTranslated('offline', context),
        type: 'offline',
        getWayImage: Images.offlinePayment,
      ));
    }

  }
  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ProfileProvider profileProvider  = Provider.of<ProfileProvider>(context, listen: false);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    bool isPartialPayment = authProvider.isLoggedIn() && configModel.isPartialPayment!
        && configModel.walletStatus!
        && (profileProvider.userInfoModel != null
            && (profileProvider.userInfoModel!.walletBalance ?? 0) > 0
            &&  profileProvider.userInfoModel!.walletBalance! <= widget.totalPrice);

    return SingleChildScrollView(
      child: Center(child: SizedBox(width: 550, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if(ResponsiveHelper.isDesktop(context)) SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

        if(ResponsiveHelper.isDesktop(context)) Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () => context.pop(),
            child: Container(
              height: 30, width: 30,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.clear),
            ),
          ),
        ),

        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          width: 550,
          margin: const EdgeInsets.only(top: kIsWeb ? 0 : 30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ResponsiveHelper.isMobile() ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
                : const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
          child: Consumer<OrderProvider>(
              builder: (ctx, orderProvider, _) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  !ResponsiveHelper.isDesktop(context) ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4, width: 35,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                    ),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(children: [
                    notHideCod ? Text(getTranslated('choose_payment_method', context)!, style: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault)) : const SizedBox(),
                    SizedBox(width: notHideCod ? Dimensions.paddingSizeExtraSmall : 0),
                  ]),


                  SizedBox(height: notHideCod ? Dimensions.paddingSizeLarge : 0),

                  Row(children: [
                    configModel.cashOnDelivery! && notHideCod ? Expanded(
                      child: PaymentButtonNew(
                        icon: Images.cart,
                        title: getTranslated('cash_on_delivery', context)!,
                        isSelected: orderProvider.paymentMethodIndex == 0,
                        onTap: () {
                         orderProvider.setPaymentIndex(0);
                        },
                      ),
                    ) : const SizedBox(),
                    SizedBox(width: configModel.cashOnDelivery! ? Dimensions.paddingSizeLarge : 0),

                    configModel.walletStatus! && authProvider.isLoggedIn() && (orderProvider.partialAmount == null) && !isPartialPayment ? Expanded(
                      child: PaymentButtonNew(
                        icon: Images.walletPayment,
                        title: getTranslated('pay_via_wallet', context)!,
                        isSelected: orderProvider.paymentMethodIndex == 1,
                        onTap: () {
                          if(canSelectWallet) {
                            context.pop();
                            showDialog(context: context, builder: (ctx)=> PartialPayDialog(
                              isPartialPay: profileProvider.userInfoModel!.walletBalance! < widget.totalPrice,
                              totalPrice: widget.totalPrice,
                            ));
                          }else{
                            showCustomSnackBar(getTranslated('your_wallet_have_not_sufficient_balance', context));
                          }
                        },
                      ),
                    ) : const SizedBox(),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                 if(paymentList.isNotEmpty) Row(children: [
                    Text(getTranslated('pay_via_online', context)!, style: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('(${getTranslated('faster_and_secure_way_to_pay_bill', context)})', style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                    )),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Expanded(child: PaymentMethodView(
                    paymentList: paymentList,
                    onTap: (index){
                      if(notHideOffline &&  paymentList[index].type == 'offline'){
                        orderProvider.changePaymentMethod(digitalMethod: paymentList[index]);
                      }else if(!notHideDigital){
                        showCustomSnackBar('${getTranslated('you_can_not_use', context)} ${getTranslated('digital_payment', context)} ${getTranslated('in_partial_payment', context)}');
                      }else{
                        orderProvider.changePaymentMethod(digitalMethod: paymentList[index]);
                      }
                    }
                  )),
                  const SizedBox(height: Dimensions.paddingSizeSmall),


                  SafeArea(child: CustomButton(
                    btnTxt: getTranslated('select', context),
                    onTap: orderProvider.paymentMethodIndex == null
                        && orderProvider.paymentMethod == null
                        || (orderProvider.paymentMethod != null && orderProvider.paymentMethod?.type == 'offline' && orderProvider.selectedOfflineMethod == null)
                        ? null : () {
                      if(orderProvider.paymentMethod?.type == 'offline'){
                        if(orderProvider.selectedOfflineValue != null){
                          orderProvider.setOfflineSelect(true);
                          context.pop();
                        }else{
                          showDialog(context: context, builder: (ctx)=> OfflinePaymentView(totalAmount: widget.totalPrice));
                        }



                      }else{
                        orderProvider.savePaymentMethod(index: orderProvider.paymentMethodIndex, method: orderProvider.paymentMethod);
                        context.pop();

                      }
                    },
                  )),

                ]);
              }
          ),
        ),
      ]))),
    );
  }
}
