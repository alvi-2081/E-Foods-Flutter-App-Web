import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wallet_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_image.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert'as convert;
import 'package:go_router/go_router.dart';



class AddFundDialogue extends StatefulWidget {
  final String? status;
  const AddFundDialogue({Key? key, this.status}) : super(key: key);

  @override
  State<AddFundDialogue> createState() => _AddFundDialogueState();
}

class _AddFundDialogueState extends State<AddFundDialogue> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).changePaymentMethod(isUpdate: false, isClear: true);

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if(ResponsiveHelper.isDesktop(context)) SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),

        SizedBox(
          width: ResponsiveHelper.isDesktop(context) ? width * 0.35 : width * 0.9,
          child: Align(alignment: Alignment.topRight, child: InkWell(
            onTap: ()=> context.pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor.withOpacity(0.5),
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.clear),
            ),
          )),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
          ),
          width: ResponsiveHelper.isDesktop(context) ? width * 0.35 : width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 50 : Dimensions.paddingSizeLarge),
          child: Consumer<WalletProvider>(builder: (context, walletProvider, _) {
            return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(getTranslated('add_fund_to_wallet', context)!, style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    getTranslated('add_fund_by_from', context)!,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  TextField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    controller: inputAmountController,
                    focusNode: focusNode,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.titleLarge!.color),
                    decoration: InputDecoration(
                      // isCollapsed : true,
                      hintText: getTranslated('enter_amount', context),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 1, color: Theme.of(context).primaryColor),
                      ),
                      border : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: BorderSide(style: BorderStyle.solid, width: 0.3, color: Theme.of(context).primaryColor),
                      ),
                      hintStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.7),
                      ),
                    ),
                    onChanged: (String value){
                      setState(() {
                      });
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  inputAmountController.text.isNotEmpty ? Row(children: [
                    Text(getTranslated('payment_method', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Expanded(child: Text(
                      '(${getTranslated('faster_and_secure_way_to_pay_bill', context)})',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    )),
                  ]) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // walletProvider.amountEmpty ? ListView.builder(
                  if(inputAmountController.text.isNotEmpty) Flexible(child: PaymentMethodView(
                    onTap: (index) => orderProvider.changePaymentMethod(
                      digitalMethod: configModel?.activePaymentMethodList![index],
                    ),
                    paymentList: configModel?.activePaymentMethodList ?? [],
                  )),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomButton(
                    btnTxt: getTranslated('add_fund', context),
                    onTap: (){
                      final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                      if(inputAmountController.text.isEmpty){
                        showCustomSnackBar(getTranslated('please_enter_amount', context));
                      }else if(orderProvider.paymentMethod == null){
                        showCustomSnackBar(getTranslated('please_select_payment_method', context));
                      }else{
                        context.pop();
                        double amount = double.parse(inputAmountController.text.replaceAll(configModel!.currencySymbol!, ''));

                        String? hostname = html.window.location.hostname;
                        String protocol = html.window.location.protocol;
                        String port = html.window.location.port;


                        String url = "customer_id=${profileProvider.userInfoModel!.id}"
                            "&&callback=${AppConstants.baseUrl}${RouterHelper.wallet}&&order_amount=${amount.toStringAsFixed(2)}";

                        String webUrl = "customer_id=${profileProvider.userInfoModel!.id}"
                            "&&callback=$protocol//$hostname${RouterHelper.wallet}&&order_amount=${amount.toStringAsFixed(2)}&&status=";

                        String webUrlDebug = "customer_id=${profileProvider.userInfoModel!.id}"
                            "&&callback=$protocol//$hostname:$port${RouterHelper.wallet}&&order_amount=${amount.toStringAsFixed(2)}&&status=";


                        String tokenUrl = '${convert.base64Encode(convert.utf8.encode(ResponsiveHelper.isWeb() ? (kDebugMode ? webUrlDebug : webUrl) : url))}&&payment_platform=${kIsWeb ? 'web' : 'app'}&&is_add_fund=1';
                        String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?token=$tokenUrl&&payment_method=${orderProvider.paymentMethod?.getWay}';

                          if(kIsWeb){
                            html.window.open(selectedUrl,"_self");
                          }else{
                            context.pop();
                            RouterHelper.getPaymentRoute(selectedUrl, fromCheckout: false);
                          }

                      }
                    },
                  ) ,

                ]);
              }
            );
          }),
        ),

      ]),
    );
  }
}

class PaymentMethodView extends StatelessWidget {
  final Function(int index) onTap;
  final List<PaymentMethod> paymentList;
  const PaymentMethodView({
    Key? key, required this.onTap, required this.paymentList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);



    return SingleChildScrollView(child: ListView.builder(
       itemCount: paymentList.length,
       shrinkWrap: true,
       physics: const NeverScrollableScrollPhysics(),
       itemBuilder: (context, index){
         bool isSelected = paymentList[index] == orderProvider.paymentMethod;
         bool isOffline = paymentList[index].type == 'offline';
         return InkWell(
           onTap: ()=> onTap(index),
           child: Container(
             decoration: BoxDecoration(
                 color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                 borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
             ),
             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Row(children: [
                   Container(
                     height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge,
                     decoration: BoxDecoration(
                         shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                         border: Border.all(color: Theme.of(context).disabledColor)
                     ),
                     child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                   ),
                   const SizedBox(width: Dimensions.paddingSizeDefault),

                    isOffline ? Image.asset(
                      Images.offlinePayment,  height: Dimensions.paddingSizeLarge, fit: BoxFit.contain,
                    ) : CustomImage(
                     height: Dimensions.paddingSizeLarge, fit: BoxFit.contain,
                     image: '${splashProvider.configModel?.baseUrls?.getWayImageUrl}/${paymentList[index].getWayImage}',
                   ),
                   const SizedBox(width: Dimensions.paddingSizeSmall),

                   Text(
                     isOffline ? getTranslated('pay_offline', context)! : paymentList[index].getWayTitle ?? '',
                     style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                   ),
                 ]),

               if(isOffline && isSelected && splashProvider.offlinePaymentModelList != null) SingleChildScrollView(
                 padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                 scrollDirection: Axis.horizontal,
                 child: Row(mainAxisAlignment: MainAxisAlignment.start, children: splashProvider.offlinePaymentModelList!.map((offlineMethod) => InkWell(
                   onTap: () {
                     orderProvider.changePaymentMethod(offlinePaymentModel: offlineMethod);
                     orderProvider.setOfflineSelectedValue(null);
                   },
                   child: Container(
                     margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraLarge),
                     decoration: BoxDecoration(
                       color: Theme.of(context).cardColor,
                       border: Border.all(width: 2, color: Theme.of(context).secondaryHeaderColor.withOpacity(
                         orderProvider.selectedOfflineMethod == offlineMethod ? 0.5 : 0.2,
                       )),
                       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                     ),
                     child: Text(offlineMethod?.methodName ?? ''),
                   ),
                 )).toList()),
               ),

               if(isOffline && orderProvider.selectedOfflineValue != null && isSelected ) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 const SizedBox(height: Dimensions.paddingSizeDefault),

                 Text(getTranslated('payment_info', context)!, style: rubikMedium,),
                 const SizedBox(height: Dimensions.paddingSizeSmall),

                 Column(children: orderProvider.selectedOfflineValue!.map((method) => Row(children: [
                   Flexible(child: Text(method.keys.single, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                   const SizedBox(width: Dimensions.paddingSizeSmall),

                   Flexible(child: Text(' :  ${method.values.single}', style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                 ])).toList()),

               ]),


             ]),
           ),
         );
       },));
  }
}
