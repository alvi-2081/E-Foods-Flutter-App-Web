import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/partial_pay_dialog.dart';
import 'package:provider/provider.dart';

class PartialPayView extends StatelessWidget {
  final double totalPrice;
  const PartialPayView({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<OrderProvider>(builder: (ctx, orderProvider, _) {

      bool isPartialPayment = authProvider.isLoggedIn() && splashProvider.configModel!.isPartialPayment!
          && splashProvider.configModel!.walletStatus!
          && (profileProvider.userInfoModel != null
              && (profileProvider.userInfoModel!.walletBalance ?? 0) > 0
              &&  profileProvider.userInfoModel!.walletBalance! <= totalPrice);

      bool isSelected = (orderProvider.paymentMethodIndex == 1 && orderProvider.selectedPaymentMethod != null);

      return isPartialPayment ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.01),
          border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          image: !ResponsiveHelper.isDesktop(context) ? DecorationImage(
            alignment: Alignment.bottomRight,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
            image: const AssetImage(Images.walletPayment),
          ) : null,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset(Images.partialPay, height: 30, width: 30),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                PriceConverter.convertPrice(profileProvider.userInfoModel!.walletBalance!),
                style: rubikBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                orderProvider.partialAmount != null ? getTranslated('has_paid_by_your_wallet', context)! : getTranslated('your_have_balance_in_your_wallet', context)!,
                style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ]),

          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            orderProvider.partialAmount != null || isSelected ? Row(children: [
              Container(
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(
                getTranslated('applied', context)!,
                style: rubikRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              )
            ]) : Text(
              getTranslated('do_you_want_to_use_now', context)!,
              style: rubikRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
            ),

            InkWell(
              onTap: (){
                if(orderProvider.partialAmount != null || isSelected){
                  orderProvider.changePartialPayment();
                  orderProvider.savePaymentMethod(index: null, method: null);
                }else{
                  showDialog(context: context, builder: (ctx)=> PartialPayDialog(
                    isPartialPay: profileProvider.userInfoModel!.walletBalance! < totalPrice,
                    totalPrice: totalPrice,
                  ));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: orderProvider.partialAmount != null || isSelected ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                  border: Border.all(color: orderProvider.partialAmount != null || isSelected ? Colors.red : Theme.of(context).primaryColor, width: 0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  orderProvider.partialAmount != null || isSelected ? getTranslated('remove', context)! : getTranslated('use', context)!,
                  style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderProvider.partialAmount != null || isSelected ? Colors.red : Colors.white),
                ),
              ),
            ),

          ]),

          isSelected ? Text(
            '${getTranslated('remaining_wallet_balance', context)}: ${PriceConverter.convertPrice(profileProvider.userInfoModel!.walletBalance! - totalPrice)}',
            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ) : const SizedBox(),

        ]),
      ) : const SizedBox();
    }
    );

  }
}
