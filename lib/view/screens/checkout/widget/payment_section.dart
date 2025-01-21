import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_image.dart';
import 'package:provider/provider.dart';

import 'payment_method_bottom_sheet.dart';
class PaymentSection extends StatelessWidget {
  final double total;
  const PaymentSection({Key? key,  required this.total}) : super(key: key);


  void openDialog(BuildContext context){
    if(!ResponsiveHelper.isMobile()){
      showDialog(
        context: context,
        builder: (con) => PaymentMethodBottomSheet(totalPrice: total),
      );
    }else{
      showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (con) => PaymentMethodBottomSheet(totalPrice: total),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
      bool showPayment = orderProvider.selectedPaymentMethod != null || (orderProvider.selectedOfflineValue != null && orderProvider.isOfflineSelected);
      return Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(
          color: Theme.of(context).disabledColor.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 4, spreadRadius: -2,
        )]),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getTranslated('payment_method', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

            IconButton(
              onPressed: ()=> openDialog(context),
              icon: Image.asset(Images.edit),
            )
          ]),

          const Divider(height: 1),

           if(orderProvider.partialAmount != null || !showPayment ) Padding(
             padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
             child: InkWell(
               onTap: ()=> openDialog(context),
               child: Row(children: [
                 Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                 const SizedBox(width: Dimensions.paddingSizeDefault),

                 Text(
                   getTranslated('add_payment_method', context)!,
                   style: rubikMedium.copyWith(color: Theme.of(context).primaryColor),
                 ),

               ]),
             ),
           ),

           if(showPayment) SelectedPaymentView(total: orderProvider.partialAmount ??  total),

          ]),
      );
    });
  }
}

class SelectedPaymentView extends StatelessWidget {
  const SelectedPaymentView({
    Key? key,
    required this.total,
  }) : super(key: key);

  final double total;

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return  Container(
       decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
         borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
         color: Theme.of(context).cardColor,
         border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3), width: 1),
       ) : const BoxDecoration(),
       padding: EdgeInsets.symmetric(
         vertical: Dimensions.paddingSizeSmall,
         horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0,
       ),

       child: Column(children: [
         Row(children: [
             orderProvider.selectedOfflineMethod != null ? Image.asset(
               Images.offlinePayment,
               width: 20, height: 20,
             ) : orderProvider.selectedPaymentMethod?.type == 'online'? CustomImage(
               height: Dimensions.paddingSizeLarge,
               image: '${configModel.baseUrls?.getWayImageUrl}/${orderProvider.paymentMethod?.getWayImage}',
             ) : Image.asset(
               orderProvider.selectedPaymentMethod?.type == 'cash_on_delivery' ? Images.cashOnDelivery : Images.walletPayment,
               width: 20, height: 20, color: Theme.of(context).secondaryHeaderColor,
             ),

             const SizedBox(width: Dimensions.paddingSizeSmall),

             Expanded(child: Text(orderProvider.selectedOfflineMethod != null ? '${
                 getTranslated('pay_offline', context)}   (${orderProvider.selectedOfflineMethod?.methodName})' : orderProvider.selectedPaymentMethod!.getWayTitle ?? '',
               style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
             )),

             Text(
               PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
               style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
             )

           ]),

        if(orderProvider.selectedOfflineValue != null) Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraLarge),
          child: Column(children: orderProvider.selectedOfflineValue!.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
               Flexible(child: Text(method.keys.single, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
               const SizedBox(width: Dimensions.paddingSizeSmall),

               Flexible(child: Text(' :  ${method.values.single}', style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
             ]),
          )).toList()),
        ),
       ]),
    );
  }
}
