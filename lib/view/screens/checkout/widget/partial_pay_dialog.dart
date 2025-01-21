import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class PartialPayDialog extends StatelessWidget {
  final bool isPartialPay;
  final double totalPrice;
  const PartialPayDialog({Key? key, required this.isPartialPay, required this.totalPrice}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Align(alignment: Alignment.topRight, child: InkWell(
            onTap: ()=> context.pop(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.clear, size: 24),
            ),
          )),


          Image.asset(Images.note, width: 35, height: 35),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            getTranslated('note', context)!, textAlign: TextAlign.center,
            style: rubikBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Text(
              getTranslated(isPartialPay ? 'you_do_not_have_sufficient_balance_to_pay_full_amount_via_wallet'
                  : 'you_can_pay_the_full_amount_with_your_wallet', context)!,
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
            ),
          ),

          Text(
            getTranslated(isPartialPay ? 'want_to_pay_partially_with_wallet' : 'want_to_pay_via_wallet', context)!,

            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor), textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Image.asset(Images.partialPay, height: 35, width: 35),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            PriceConverter.convertPrice(profileProvider.userInfoModel?.walletBalance),
            style: rubikBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(
              isPartialPay ? getTranslated('can_be_paid_via_wallet', context)!
                  : '${getTranslated('remaining_wallet_balance', context)}: ${PriceConverter.convertPrice(profileProvider.userInfoModel!.walletBalance! - totalPrice)}',
              style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor), textAlign: TextAlign.center,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Row(children: [
              Expanded(child: CustomButton(
                btnTxt: getTranslated('no', context),
                backgroundColor: Theme.of(context).disabledColor,
                onTap: (){
                  orderProvider.savePaymentMethod(index: null, method: null);
                if(orderProvider.partialAmount != null){
                  orderProvider.changePartialPayment();
                }
                context.pop();
                },
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: CustomButton(btnTxt: getTranslated('yes_pay', context), onTap: (){
                if(isPartialPay){
                  orderProvider.changePartialPayment(amount: totalPrice - profileProvider.userInfoModel!.walletBalance!);
                }else{
                  orderProvider.setPaymentIndex(1);
                  orderProvider.clearOfflinePayment();
                  orderProvider.savePaymentMethod(index: orderProvider.paymentMethodIndex, method: orderProvider.paymentMethod);
                }
                context.pop();
              })),
            ]),
          ),
        ]),
      ),
    );
  }
}
