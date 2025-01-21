import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wallet_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/no_data_screen.dart';
import 'package:flutter_restaurant/view/base/not_logged_in_screen.dart';
import 'package:flutter_restaurant/view/base/title_widget.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/wallet/widget/bonus_slider_view.dart';
import 'package:flutter_restaurant/view/screens/wallet/widget/wallet_header_view.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:go_router/go_router.dart';
import 'widget/history_item.dart';

class WalletScreen extends StatefulWidget {
  final String? token;
  final String? status;
  const WalletScreen({Key? key, this.token, this.status}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  final bool isLoggedIn = Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn();
  List<PopupMenuEntry> entryList = [];


  @override
  void initState() {
    super.initState();
    final walletProvide = Provider.of<WalletProvider>(context, listen: false);

    if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()){
      walletProvide.getWalletBonusList(false);
    }
    walletProvide.setCurrentTabButton(0, isUpdate: false);
    walletProvide.insertFilterList();
    walletProvide.setWalletFilerType('all', isUpdate: false);

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      if(widget.status!.contains('success')){

        if(!kIsWeb || (kIsWeb && widget.token != null && walletProvide.checkToken(widget.token!))){
          showCustomSnackBar(getTranslated('add_fund_successful', context), isError: false);
        }
        Provider.of<ProfileProvider>(Get.context!, listen: false).getUserInfo(true, isUpdate: true);

      }else if(widget.status!.contains('fail')){
        showCustomSnackBar(getTranslated('add_fund_failed', context));
      }
    });

    if(isLoggedIn){
      walletProvide.getLoyaltyTransactionList('1', false, true, isEarning: walletProvide.selectedTabButtonIndex == 1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && walletProvide.transactionList != null
            && !walletProvide.isLoading) {

          int pageSize = (walletProvide.popularPageSize! / 10).ceil();
          if (walletProvide.offset < pageSize) {
            walletProvide.setOffset = walletProvide.offset + 1;
            walletProvide.updatePagination(true);


            walletProvide.getLoyaltyTransactionList(
              walletProvide.offset.toString(), false, true, isEarning: walletProvide.selectedTabButtonIndex == 1,
            );
          }
        }
      });
    }

  }
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar()) : null,
      body: configModel.walletStatus! ? isLoggedIn ? RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: () async {
          final WalletProvider walletProvider = Provider.of<WalletProvider>(context, listen: false);
          walletProvider.getLoyaltyTransactionList('1', false, true);

        },
        child: CustomScrollView(controller:  scrollController, slivers: [
         if(!ResponsiveHelper.isDesktop(context)) SliverAppBar(
           backgroundColor: Theme.of(context).canvasColor,
           expandedHeight: 120,
           collapsedHeight: 120,
           pinned: true, floating: true,
           leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: PreferredSize(
              preferredSize: const Size(double.maxFinite, 120),
              child: WalletHeaderView(tooltipController: tooltipController),
            ),
          ),

          SliverToBoxAdapter(child: Center(child: Consumer<WalletProvider>(
            builder: (context, walletProvider, _) {
              bool showBanner = walletProvider.walletBonusList != null && walletProvider.walletBonusList!.isNotEmpty;
              return Container(
                  width: Dimensions.webScreenWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                child: ResponsiveHelper.isDesktop(context) ? IntrinsicHeight(
                  child: Row(children: [
                    WalletHeaderView(webHeader: true, tooltipController: tooltipController),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    const Flexible(child: WebBonusView()),

                  ]),
                ) : showBanner ?  const BonusSliderView() : const SizedBox(),
                );
            }
          ))),


          SliverToBoxAdapter(child: Consumer<WalletProvider>(builder: (context, walletProvider, _) {
            entryList = [];
            for(int i=0; i < walletProvider.walletFilterList.length; i++){
              entryList.add(PopupMenuItem<int>(value: i, child: Text(
                getTranslated(walletProvider.walletFilterList[i].title!, context)!,
                style: rubikMedium.copyWith(
                  color: walletProvider.walletFilterList[i].value == walletProvider.type
                      ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor,
                ),
              )));
            }
            return Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Center(child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Consumer<WalletProvider>(builder: (context, walletProvider, _) {
                        return Column(children: [
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            TitleWidget(title: getTranslated('withdraw_history' , context,

                            )),

                            PopupMenuButton<dynamic>(
                              offset: const Offset(-20, 20),
                              itemBuilder: (BuildContext context) => entryList,
                              onSelected: (dynamic value) {
                                walletProvider.setWalletFilerType(walletProvider.walletFilterList[value].value!);
                                walletProvider.getLoyaltyTransactionList('1', false, true);
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 2),
                                  child: Row(children: [
                                    Text(
                                       getTranslated(walletProvider.type == 'all' ?  'filter' : walletProvider.type, context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    ),

                                    const Icon(Icons.arrow_drop_down, size: 18),
                                  ]),
                                ),
                              ),
                            ),
                          ]),
                          walletProvider.transactionList != null ? walletProvider.transactionList!.isNotEmpty ? Column(
                            children: [
                              GridView.builder(
                                key: UniqueKey(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 50,
                                  mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                                  childAspectRatio: ResponsiveHelper.isDesktop(context) ? 6 : 5,
                                  crossAxisCount: ResponsiveHelper.isMobile() ? 1 : 2,
                                ),
                                physics:  const NeverScrollableScrollPhysics(),
                                shrinkWrap:  true,
                                itemCount: walletProvider.transactionList!.length ,
                                padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
                                itemBuilder: (context, index) {
                                  return WalletHistory(transaction: walletProvider.transactionList![index]);
                                },
                              ),

                              if(walletProvider.paginationLoader) CircularProgressIndicator(color: Theme.of(context).primaryColor),
                            ],
                          ) : const NoDataScreen(isFooter: false) : WalletShimmer(walletProvider: walletProvider),

                          walletProvider.isLoading ? Center(child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
                          )) : const SizedBox(),
                        ]);
                      }),
                    )),
                  ),
              ],
            ),));
          }
          )),

          if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
            hasScrollBody: false,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              SizedBox(height: Dimensions.paddingSizeLarge),

              FooterView(),
            ]),
          ),

        ]),
      ) : const NotLoggedInScreen() : const NoDataScreen(),
    );
  }
}


class TabButtonModel{
  final String? buttonText;
  final String buttonIcon;
  final Function onTap;

  TabButtonModel(this.buttonText, this.buttonIcon, this.onTap);


}





class WalletShimmer extends StatelessWidget {
  final WalletProvider walletProvider;
  const WalletShimmer({Key? key, required this.walletProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 90,
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
        // childAspectRatio: ResponsiveHelper.isDesktop(context) ? 4 : 3,
        crossAxisCount: ResponsiveHelper.isMobile() ? 1 : 2,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.08))
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletProvider.transactionList == null,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 10, width: 20, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 10),

                  Container(height: 10, width: 50, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 10),
                  Container(height: 10, width: 70, decoration: BoxDecoration(color: Theme.of(context).shadowColor, borderRadius: BorderRadius.circular(2))),
                ]),

              ],
            ),
          ),
        );
      },
    );
  }
}