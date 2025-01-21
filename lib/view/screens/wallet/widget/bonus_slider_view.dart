import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/wallet_bonus_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wallet_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BonusSliderView extends StatefulWidget {
  const BonusSliderView({Key? key}) : super(key: key);

  @override
  State<BonusSliderView> createState() => _BonusSliderViewState();
}

class _BonusSliderViewState extends State<BonusSliderView> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final bool isAddFundActive = Provider.of<SplashProvider>(context, listen: false).configModel!.isAddFundToWallet!;

    return isAddFundActive ? Consumer<WalletProvider>(builder: (context, walletProvider, _) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        CarouselSlider.builder(
          itemCount: walletProvider.walletBonusList?.length,
          options: CarouselOptions(
              aspectRatio: ResponsiveHelper.isMobile() ?  2.9 : 3.5,
              // enlargeCenterPage: true,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayAnimationDuration: const Duration(seconds: 1),
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          itemBuilder: (ctx, index, realIdx) => BonusItemView(
            walletBonusModel: walletProvider.walletBonusList![index],
          ),
        ),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: walletProvider.walletBonusList!.map((b) {
          int index = walletProvider.walletBonusList!.indexOf(b);
          return Container(
            width: 8.0, height: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? Theme.of(context).primaryColor : Colors.black12,
            ),
          );
        }).toList()),
      ]);
    }) : const SizedBox();
  }
}

class WebBonusView extends StatelessWidget{
  const WebBonusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAddFundActive = Provider.of<SplashProvider>(context, listen: false).configModel!.isAddFundToWallet!;
    return  isAddFundActive ?  Consumer<WalletProvider>(builder: (context, walletProvider, _) {
      return  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
        children: walletProvider.walletBonusList == null ? [1,2,3].map((e) => const WebBonusShimmer(
      )).toList() : walletProvider.walletBonusList!.map((e) =>  BonusItemView(
      walletBonusModel: e
      )).toList(),
      ));
    }) : const SizedBox();
  }

}


class BonusItemView extends StatelessWidget {
  final WalletBonusModel walletBonusModel;
  const BonusItemView({Key? key, required this.walletBonusModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4)),
        image: const DecorationImage(
          image: AssetImage(Images.walletBanner), fit: BoxFit.contain,
          alignment: Alignment.centerRight,
        ),
      ),
      width: ResponsiveHelper.isDesktop(context) ? 400 : double.maxFinite,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(walletBonusModel.title ?? '', style: rubikMedium.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: Dimensions.fontSizeLarge,
        ), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        if(walletBonusModel.endDate != null)
          Text('${getTranslated('valid_till', context)} ${DateConverter.estimatedDate(walletBonusModel.endDate!)}', style: rubikRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
        )),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(walletBonusModel.minimumAddAmount != null && walletBonusModel.minimumAddAmount! > 0
            ? '${getTranslated('add_minimum', context)} ${PriceConverter.convertPrice(walletBonusModel.minimumAddAmount)} ${getTranslated('and_enjoy_bonus', context)} '
            '${
            walletBonusModel.bonusType == 'percentage'
                ? '${walletBonusModel.bonusAmount} %'
                : PriceConverter.convertPrice(walletBonusModel.bonusAmount)}'
            :  '${getTranslated('add_fund_to_wallet_add_enjoy', context)} ${
            walletBonusModel.bonusType == 'percentage'
                ? '${walletBonusModel.bonusAmount} %'
                : PriceConverter.convertPrice(walletBonusModel.bonusAmount)} ${getTranslated('more', context)}', style: rubikRegular.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: Dimensions.fontSizeSmall,
        )),
      ]),
    );
  }
}


class WebBonusShimmer extends StatelessWidget {
  const WebBonusShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4)),
          image: const DecorationImage(
            image: AssetImage(Images.walletBanner), fit: BoxFit.contain,
            alignment: Alignment.centerRight,
          ),
        ),
        width: ResponsiveHelper.isMobile() ? double.maxFinite : 400 ,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Container(height: 10, width: 120, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),


          Container(height: 10, width: 50, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Container(height: 10, width: 80, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),

        ]),
      ),
    );
  }
}




