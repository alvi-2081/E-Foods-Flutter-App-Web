import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/offline_payment_model.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class OfflinePaymentView extends StatefulWidget {
  final double totalAmount;
  const OfflinePaymentView({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<OfflinePaymentView> createState() => _OfflinePaymentViewState();
}

class _OfflinePaymentViewState extends State<OfflinePaymentView> {
  AutoScrollController? scrollController;
  Map<String, String>? selectedValue;


  @override
  void initState() {

    Provider.of<OrderProvider>(context, listen: false).updatePaymentVisibility(false);
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );

    int index = Provider.of<SplashProvider>(context, listen: false).offlinePaymentModelList!.indexOf(
      Provider.of<OrderProvider>(context, listen: false).selectedOfflineMethod,
    );

    scrollController?.scrollToIndex(index, preferPosition: AutoScrollPosition.middle);
    scrollController?.highlight(index);



    super.initState();
  }
  @override
  void dispose() {
    Provider.of<OrderProvider>(Get.context!, listen: false).updatePaymentVisibility(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Center(child: SizedBox(width: 600, child: Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Consumer<OrderProvider>(builder: (context, orderProvider, _) {

        // return Text('data');
        return Column(children: [
          Expanded(child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(getTranslated('offline_payment', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Image.asset(Images.offlinePayment, height: 100),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text(getTranslated('pay_your_bill_using_the_info', context)!, textAlign: TextAlign.center, style: rubikRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodySmall?.color,
              )),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SingleChildScrollView(
                controller: scrollController, scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(children: splashProvider.offlinePaymentModelList!.map((offline) => AutoScrollTag(
                    controller: scrollController!,
                    key: ValueKey(splashProvider.offlinePaymentModelList!.indexOf(offline)),
                    index: splashProvider.offlinePaymentModelList!.indexOf(offline),
                    child: InkWell(
                      onTap: () async {
                        orderProvider.formKey.currentState?.reset();
                        orderProvider.changePaymentMethod(offlinePaymentModel: offline);

                        await scrollController!.scrollToIndex(splashProvider.offlinePaymentModelList!.indexOf(offline), preferPosition: AutoScrollPosition.middle);
                        await scrollController!.highlight(splashProvider.offlinePaymentModelList!.indexOf(offline));
                      },
                      child: Container(
                        width: ResponsiveHelper.isMobile() ? MediaQuery.sizeOf(context).width * 0.7 : 300,
                        constraints: const BoxConstraints(minHeight: 160),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1), width: 1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          boxShadow: [BoxShadow(
                            color: Theme.of(context).secondaryHeaderColor.withOpacity(0.05),
                            offset: const Offset(0, 4), blurRadius: 8,
                          )],
                        ),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(offline?.methodName ?? '', style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).secondaryHeaderColor)),

                            if(offline?.id == orderProvider.selectedOfflineMethod?.id)
                              Row(mainAxisAlignment: MainAxisAlignment.end,  children: [
                                Text(getTranslated('pay_on_this_account', context)!, style: rubikRegular.copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                )),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Icon(Icons.check_circle_rounded, color: Theme.of(context).secondaryHeaderColor)
                              ]),

                          ]),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if(offline?.methodFields != null) BillInfoWidget(methodList: offline!.methodFields!),

                        ]),
                      ),
                    ),
                  )).toList()),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                '${getTranslated('amount', context)} : ${PriceConverter.convertPrice(widget.totalAmount)}',
                style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),


              if(orderProvider.selectedOfflineMethod?.methodFields != null)
                PaymentInfoWidget(methodInfo: orderProvider.selectedOfflineMethod!.methodInformations!),








            ]),
          )),

          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            CustomButton(
              borderRadius: Dimensions.radiusExtraLarge,
              btnTxt: getTranslated('close', context), width: 100,
              backgroundColor: Theme.of(context).disabledColor,
              onTap: ()=> context.pop(),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            CustomButton(
              btnTxt: getTranslated('submit', context),
              borderRadius: Dimensions.radiusExtraLarge,
              width: 130, onTap: (){
              if(orderProvider.formKey.currentState!.validate()){
                orderProvider.setOfflineSelectedValue(null);
                List<Map<String, String>>? data = [];
                orderProvider.field.forEach((key, value) {
                  data.add({key : value.text});
                });
                orderProvider.setOfflineSelectedValue(data);
                context.pop();
              }

            },),
          ]),
        ]);
      }),
    )));
  }
}


class BillInfoWidget extends StatelessWidget {
  final List<MethodField> methodList;
  const BillInfoWidget({Key? key, required this.methodList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: methodList.map((method) => Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Flexible(
          child: Text('${method.fieldName ?? ''} :    ${method.fieldData}',
            style: rubikRegular, overflow: TextOverflow.ellipsis, maxLines: 1,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Flexible(child: Text(' :  ${method.fieldData}',
          style: rubikRegular,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
      ]),
    )).toList());
  }
}

class PaymentInfoWidget extends StatefulWidget {
  final List<MethodInformation> methodInfo;

  const PaymentInfoWidget({Key? key, required this.methodInfo}) : super(key: key);

  @override
  State<PaymentInfoWidget> createState() => _PaymentInfoWidgetState();
}

class _PaymentInfoWidgetState extends State<PaymentInfoWidget> {

  final TextEditingController noteTextController = TextEditingController();

  @override
  void dispose() {
    noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getTranslated('payment_info', context)!, style: rubikMedium,),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          orderProvider.field = {};
          for(int i = 0; i < widget.methodInfo.length; i++){
            orderProvider.field.addAll({'${widget.methodInfo[i].informationName}' : TextEditingController()});
          }
          return Column(children: [
            Form(
                key: orderProvider.formKey,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderProvider.field.length,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall, horizontal: 10,
                  ),

                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: CustomTextField(
                      onValidate: widget.methodInfo[index].informationRequired! ? (String? value){
                       return value != null && value.isEmpty ? '${widget.methodInfo[index].informationName?.replaceAll("_", " ").toCapitalized()
                       } ${getTranslated('is_required', context)}' : null;
                      }: null,
                      isShowBorder: true,
                      controller: orderProvider.field['${widget.methodInfo[index].informationName}'],
                      hintText:  widget.methodInfo[index].informationPlaceholder,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: CustomTextField(
                fillColor: Theme.of(context).cardColor,
                isShowBorder: true,
                controller: noteTextController,
                hintText: getTranslated('enter_your_payment_note', context),
                maxLines: 5,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.newline,
                capitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  orderProvider.selectedOfflineMethod?.copyWith(note: noteTextController.text);
                },
              ),
            ),

          ]);
        }
      ),
    ]);
  }
}
