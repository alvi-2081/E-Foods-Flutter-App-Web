import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/wallet_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_directionality.dart';
import 'package:flutter_restaurant/view/base/no_data_screen.dart';
import 'package:flutter_restaurant/view/base/not_logged_in_screen.dart';
import 'package:flutter_restaurant/view/base/title_widget.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/loyalty_screen/widget/tab_button_view.dart';
import 'package:flutter_restaurant/view/screens/wallet/wallet_screen.dart';
import 'package:flutter_restaurant/view/screens/wallet/widget/convert_money_view.dart';
import 'package:flutter_restaurant/view/screens/wallet/widget/history_item.dart';
import 'package:provider/provider.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key,}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _isLoggedIn = Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn();

  @override
  void initState() {
    super.initState();
    final walletProvide = Provider.of<WalletProvider>(context, listen: false);

    walletProvide.setCurrentTabButton(
      0,
      isUpdate: false,
    );

    if(_isLoggedIn){
      Provider.of<ProfileProvider>(Get.context!, listen: false).getUserInfo(false, isUpdate: false);
      walletProvide.getLoyaltyTransactionList('1', false, false, isEarning: walletProvide.selectedTabButtonIndex == 1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && walletProvide.transactionList != null
            && !walletProvide.isLoading) {

          int pageSize = (walletProvide.popularPageSize! / 10).ceil();
          if (walletProvide.offset < pageSize) {
            walletProvide.setOffset = walletProvide.offset + 1;
            walletProvide.updatePagination(true);


            walletProvide.getLoyaltyTransactionList(
              walletProvide.offset.toString(), false, false, isEarning: walletProvide.selectedTabButtonIndex == 1,
            );
          }
        }
      });
    }

  }
  @override
  void dispose() {
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // dark text for status bar
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
    ));


    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar()) : null,

      body: !configModel.loyaltyPointStatus! ? const NoDataScreen() : Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            return _isLoggedIn ? (!profileProvider.isLoading && profileProvider.userInfoModel != null) ? Consumer<WalletProvider>(builder: (context, walletProvider, _) {
              return Stack(children: [
                Column(children: [
                  Center(child: Container(
                    width: Dimensions.webScreenWidth,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: SafeArea(child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.asset(Images.loyal, width: 40, height: 40),
                          const SizedBox(width: Dimensions.paddingSizeDefault,),

                          profileProvider.isLoading ? const SizedBox() : CustomDirectionality(child: Text(
                            '${profileProvider.userInfoModel?.point ?? 0}', style: rubikBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          )),
                        ],),
                        const SizedBox(height: Dimensions.paddingSizeDefault,),

                        Text(getTranslated('loyalty_point', context)!,
                          style: rubikBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault,),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: tabButtonList.map((tabButtonModel) =>
                                TabButtonView(tabButtonModel: tabButtonModel,)).toList(),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge,),
                      ])),
                  )),

                  Expanded(child: RefreshIndicator(
                    onRefresh: () async{
                      walletProvider.getLoyaltyTransactionList('1', true,false, isEarning: walletProvider.selectedTabButtonIndex == 1);
                      profileProvider.getUserInfo(true);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      child: SizedBox(width: Dimensions.webScreenWidth, child: Column(
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              if(walletProvider.selectedTabButtonIndex == 0)
                                const ConvertMoneyView(),

                              if(walletProvider.selectedTabButtonIndex != 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Center(
                                    child: SizedBox(
                                      width: Dimensions.webScreenWidth,
                                      child: Consumer<WalletProvider>(
                                          builder: (context, walletProvider, _) {
                                            return Column(children: [
                                              Column(children: [

                                                Padding(
                                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                                                  child: TitleWidget(title: getTranslated(
                                                    walletProvider.selectedTabButtonIndex == 0
                                                        ? 'enters_point_amount' : walletProvider.selectedTabButtonIndex == 1
                                                        ? 'point_earning_history' : 'point_converted_history', context,

                                                  )),
                                                ),
                                                walletProvider.transactionList != null ? walletProvider.transactionList!.isNotEmpty ? GridView.builder(
                                                  key: UniqueKey(),
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisSpacing: 50,
                                                    mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                                                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
                                                    crossAxisCount: ResponsiveHelper.isMobile() ? 1 : 2,
                                                  ),
                                                  physics:  const NeverScrollableScrollPhysics(),
                                                  shrinkWrap:  true,
                                                  itemCount: walletProvider.transactionList!.length ,
                                                  padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
                                                  itemBuilder: (context, index) {
                                                    return Stack(
                                                      children: [
                                                        HistoryItem(
                                                          index: index,formEarning: walletProvider.selectedTabButtonIndex == 1,
                                                          data: walletProvider.transactionList,
                                                        ),

                                                        if(walletProvider.paginationLoader && walletProvider.transactionList!.length == index + 1)
                                                          const Center(child: CircularProgressIndicator()),
                                                      ],
                                                    );
                                                  },
                                                ) : const NoDataScreen(isFooter: false) : WalletShimmer(walletProvider: walletProvider),

                                                walletProvider.isLoading ? const Center(child: Padding(
                                                  padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                  child: CircularProgressIndicator(),
                                                )) : const SizedBox(),
                                              ])
                                            ]);
                                          }
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),),
                    ),
                  )),
                ]),

                if(!ResponsiveHelper.isDesktop(context)) const SafeArea(child: BackButton()),
              ]);
            }) : const Center(child: CircularProgressIndicator()) : const NotLoggedInScreen();
          }
      ),
    );
  }
}


