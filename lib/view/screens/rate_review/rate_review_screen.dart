
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/order_details_model.dart';
import 'package:flutter_restaurant/data/model/response/order_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/review_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/rate_review/widget/deliver_man_review_widget.dart';
import 'package:flutter_restaurant/view/screens/rate_review/widget/product_review_widget.dart';
import 'package:provider/provider.dart';

class RateReviewScreen extends StatefulWidget {
  final int orderId;
  final String? phoneNumber;
  const RateReviewScreen({Key? key, required this.orderId, this.phoneNumber}) : super(key: key);

  @override
  State<RateReviewScreen>  createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  DeliveryMan? deliveryMan;
  List<OrderDetailsModel> orderDetailsList = [];


  Future<void> _initLoading() async {
    final ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);


    deliveryMan = await reviewProvider.getDeliveryMan('${widget.orderId}', phoneNumber: widget.phoneNumber);
    _tabController = TabController(length: deliveryMan == null ? 1 : 2, initialIndex: 0, vsync: this);

    orderDetailsList = await reviewProvider.getOrderList(widget.orderId.toString(), phoneNumber: widget.phoneNumber);
    reviewProvider.initRatingData(orderDetailsList);
    reviewProvider.updateSubmitted(false);
  }


  @override
  void initState() {
    super.initState();
    _initLoading();

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar()) : CustomAppBar(context: context, title: getTranslated('rate_review', context))) as PreferredSizeWidget?,

      body: Consumer<OrderProvider>(builder: (context, orderProvider, _) {
        return (orderProvider.trackModel == null || orderProvider.isLoading) ? const Center(child: CircularProgressIndicator()) : Column(children: [
          Center(
            child: Container(
              width: Dimensions.webScreenWidth,
              color: Theme.of(context).cardColor,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                unselectedLabelStyle: rubikRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                labelStyle: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                tabs: deliveryMan != null ? [
                  Tab(text: getTranslated(orderDetailsList.length > 1 ? 'items' : 'item', context)),
                  Tab(text: getTranslated('delivery_man', context)),
                ] : [
                  Tab(text: getTranslated(orderDetailsList.length > 1 ? 'items' : 'item', context)),
                ],
              ),
            ),
          ),

          Expanded(child: TabBarView(
            controller: _tabController,
            children: deliveryMan != null ? [
              ProductReviewWidget(orderDetailsList: orderDetailsList),
              DeliveryManReviewWidget(deliveryMan: deliveryMan, orderID: widget.orderId.toString()),
            ] : [
              ProductReviewWidget(orderDetailsList: orderDetailsList),
            ],
          )),

        ]);
      }),
    );
  }
}
