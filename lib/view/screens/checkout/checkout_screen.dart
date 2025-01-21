import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_restaurant/data/model/response/address_model.dart';
import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/branch_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/branch_button_view.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/not_logged_in_screen.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/address/widget/permission_dialog.dart';
import 'package:flutter_restaurant/view/screens/cart/cart_screen.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/confirm_button_view.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/delivery_fee_dialog.dart';
import 'package:flutter_restaurant/view/screens/checkout/widget/slot_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'widget/cost_summery_view.dart';
import 'widget/partial_pay_view.dart';
import 'widget/payment_section.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  final double? amount;
  final String? orderType;
  final List<CartModel>? cartList;
  final bool fromCart;
  final String? couponCode;
  const CheckoutScreen({Key? key,  required this.amount, required this.orderType, required this.fromCart,
    required this.cartList, required this.couponCode}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _noteController = TextEditingController();
  late GoogleMapController _mapController;
  bool _loading = true;
  Set<Marker> _markers = HashSet<Marker>();
  late bool _isLoggedIn;
  late List<CartModel?> _cartList;
  final List<PaymentMethod> _paymentList = [];
  final List<Color> _paymentColor = [];
  Branches? currentBranch;

  @override
  void initState() {
    super.initState();
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    if(cartProvider.cartList.isEmpty) {
      RouterHelper.getDashboardRoute('cart');
    }

    currentBranch = Provider.of<BranchProvider>(context, listen: false).getBranch();
    splashProvider.getOfflinePaymentMethod(true);

    orderProvider.clearPrevData();


    if(splashProvider.configModel!.cashOnDelivery!) {
      _paymentList.add(PaymentMethod(getWay: 'cash_on_delivery', getWayImage: Images.cashOnDelivery));
      _paymentColor.add( Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.02));
    }

    if(splashProvider.configModel!.walletStatus!) {
      _paymentList.add(PaymentMethod(getWay: 'wallet_payment', getWayImage: Images.walletPayment));
      _paymentColor.add( Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.1));
    }

    for (var method in splashProvider.configModel!.activePaymentMethodList!) {
      _paymentList.add(method);
      _paymentColor.add( Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.1));
    }

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if(_isLoggedIn || splashProvider.configModel!.isGuestCheckout!) {

      if(_isLoggedIn){
        profileProvider.getUserInfo(false, isUpdate: false);
      }

      orderProvider.initializeTimeSlot(context).then((value) {
        orderProvider.sortTime();
      });
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Provider.of<CartProvider>(context, listen: false).cartList) : _cartList.addAll(widget.cartList!);
    }

  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final configModel = splashProvider.configModel!;
    bool kmWiseCharge = configModel.deliveryManagement!.status == 1;
    bool takeAway = widget.orderType == 'take_away';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar()) : CustomAppBar(context: context, title: getTranslated('checkout', context))) as PreferredSizeWidget?,

      body: _isLoggedIn || splashProvider.configModel!.isGuestCheckout! ?  Column(
        children: [
          Expanded(child: CustomScrollView(slivers: [

              SliverToBoxAdapter(child: Consumer<LocationProvider>(builder: (context, locationProvider, _) {
                return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
                  double? deliveryCharge = 0;

                  if(!takeAway && kmWiseCharge) {
                    deliveryCharge = orderProvider.distance * configModel.deliveryManagement!.shippingPerKm!;
                    if(deliveryCharge < configModel.deliveryManagement!.minShippingCharge!) {
                      deliveryCharge = configModel.deliveryManagement!.minShippingCharge;
                    }
                  }else if(!takeAway && !kmWiseCharge) {
                    deliveryCharge = configModel.deliveryCharge;
                  }
                  return Center(child: Container(
                    margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
                    alignment: Alignment.topCenter,
                    width: Dimensions.webScreenWidth,
                    decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.5),
                            blurRadius: 10,
                          )
                        ]
                    ) : const BoxDecoration(),
                    child: Column(children: [
                      if(ResponsiveHelper.isDesktop(context)) Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                        child: Text(getTranslated('checkout', context)!, style: rubikBold.copyWith(
                          fontSize: Dimensions.fontSizeOverLarge,
                        )),
                      ),


                      if(splashProvider.isBranchSelectDisable()) Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(getTranslated('branch', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),

                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const BranchButtonView(isRow: true),
                                  ),
                                ],
                              ),
                            ),
                          ),

                         if(ResponsiveHelper.isDesktop(context)) const Expanded(flex: 4,child: SizedBox())
                        ],
                      ),

                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Container(
                              height: ResponsiveHelper.isMobile() ? 200 : 300,
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).cardColor,
                              ),
                              child: Stack(children: [
                                ClipRRect(borderRadius : BorderRadius.circular(10), child: GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        double.parse(currentBranch!.latitude!),
                                        double.parse(currentBranch!.longitude!),
                                      ), zoom: 5,
                                    ),
                                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                                    zoomControlsEnabled: true,
                                    markers: _markers,
                                    onMapCreated: (GoogleMapController controller) async {
                                      await Geolocator.requestPermission();
                                      _mapController = controller;
                                      _loading = false;
                                      _setMarkers(configModel.branches!.indexOf(currentBranch));
                                    },
                                  )),

                                _loading ? Center(child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                )) : const SizedBox(),
                              ]),
                            ),
                          ]),

                          // Address
                          !takeAway ? Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Row(children: [
                                Text(getTranslated('delivery', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                const Expanded(child: SizedBox()),

                                SizedBox(height: 30, child: FloatingActionButton.extended(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                  ),
                                  // extendedPadding: EdgeInsets.s,
                                  elevation: 0,

                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  onPressed: () => _checkPermission(()=> RouterHelper.getAddAddressRoute('checkout', 'add', AddressModel())),
                                  icon: Icon(Icons.add_circle_outline, size: Dimensions.paddingSizeDefault, color: Theme.of(context).primaryColor),
                                  label: Text(getTranslated('add_delivery_info', context)!, style: rubikMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                                  )),
                                )),
                              ]),
                            ),

                            SizedBox(
                              height: 60,
                              child: locationProvider.addressList != null ? locationProvider.addressList!.isNotEmpty ? ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                itemCount: locationProvider.addressList!.length,
                                itemBuilder: (context, index) {
                                  bool isAvailable = currentBranch == null || (currentBranch!.latitude == null || currentBranch!.latitude!.isEmpty);
                                  if(!isAvailable) {
                                    double distance = Geolocator.distanceBetween(
                                      double.parse(currentBranch!.latitude!), double.parse(currentBranch!.longitude!),
                                      double.parse(locationProvider.addressList![index].latitude!), double.parse(locationProvider.addressList![index].longitude!),
                                    ) / 1000;

                                    isAvailable = distance < currentBranch!.coverage!;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge, top: Dimensions.paddingSizeSmall),
                                    child: InkWell(
                                      onTap: () async {
                                        if(isAvailable) {
                                          orderProvider.setAddressIndex(index);

                                          if(kmWiseCharge) {
                                            if(orderProvider.selectedPaymentMethod != null){
                                              showCustomSnackBar(getTranslated('your_payment_method_has_been', context), isError: false);
                                            }
                                            orderProvider.savePaymentMethod(index: null, method: null);
                                            orderProvider.changePartialPayment();

                                            showDialog(context: context, builder: (context) => Center(child: Container(
                                              height: 100, width: 100, decoration: BoxDecoration(
                                              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                                            ),
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                                            )), barrierDismissible: false);
                                            orderProvider.getDistanceInMeter(
                                              LatLng(
                                                double.parse(currentBranch!.latitude!),
                                                double.parse(currentBranch!.longitude!),
                                              ),
                                              LatLng(
                                                double.parse(locationProvider.addressList![index].latitude!),
                                                double.parse(locationProvider.addressList![index].longitude!),
                                              ),
                                            ).then((isSuccess) {
                                              context.pop();
                                              if(isSuccess) {
                                                showDialog(context: context, builder: (context) => DeliveryFeeDialog(
                                                  amount: widget.amount, distance: orderProvider.distance,
                                                ));
                                              }else {
                                                showCustomSnackBar(getTranslated('failed_to_fetch_distance', context));
                                              }
                                              return isSuccess;
                                            });

                                          }
                                        }
                                      },
                                      child: Stack(children: [
                                        Container(
                                          height: 60,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: index == orderProvider.addressIndex ? Theme.of(context).cardColor : Theme.of(context).colorScheme.background.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                            border: index == orderProvider.addressIndex ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
                                          ),
                                          child: Row(children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                              child: Icon(
                                                locationProvider.addressList![index].addressType == 'Home' ? Icons.home_outlined
                                                    : locationProvider.addressList![index].addressType == 'Workplace' ? Icons.work_outline : Icons.list_alt_outlined,
                                                color: index == orderProvider.addressIndex ? Theme.of(context).primaryColor
                                                    : Theme.of(context).textTheme.bodyLarge!.color,
                                                size: 30,
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                Text(locationProvider.addressList![index].addressType!, style: rubikRegular.copyWith(
                                                  fontSize: Dimensions.fontSizeSmall, color: ColorResources.getGreyBunkerColor(context),
                                                )),
                                                Text(locationProvider.addressList![index].address!, style: rubikRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ]),
                                            ),
                                            index == orderProvider.addressIndex ? Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                                            ) : const SizedBox(),
                                          ]),
                                        ),
                                        !isAvailable ? Positioned(
                                          top: 0, left: 0, bottom: 0, right: 0,
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.6)),
                                            child: Text(
                                              getTranslated('out_of_coverage_for_this_branch', context)!,
                                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                              style: rubikRegular.copyWith(color: Colors.white, fontSize: 10),
                                            ),
                                          ),
                                        ) : const SizedBox(),
                                      ]),
                                    ),
                                  );
                                },
                              ) : Center(child: Text(getTranslated('no_address_available', context)!))
                                  : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                            ),
                            const SizedBox(height: 20),
                          ]) : const SizedBox(),

                          // Time Slot
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: Text(getTranslated('preference_time', context)!, style: rubikMedium),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                  Radio(
                                    activeColor: Theme.of(context).primaryColor,
                                    value: index,
                                    groupValue: orderProvider.selectDateSlot,
                                    onChanged: (value)=> orderProvider.updateDateSlot(index),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Text(index == 0 ? getTranslated('today', context)! : getTranslated('tomorrow', context)!, style: rubikRegular.copyWith(
                                    color: index == orderProvider.selectDateSlot ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                ]);
                              },
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          SizedBox(
                            height: 40,
                            child: orderProvider.timeSlots != null ? orderProvider.timeSlots!.isNotEmpty ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                              itemCount: orderProvider.timeSlots!.length,
                              itemBuilder: (context, index) {
                                return SlotWidget(
                                  title: (
                                      index == 0 && orderProvider.selectDateSlot == 0  && Provider.of<SplashProvider>(context, listen: false).isRestaurantOpenNow(context))
                                      ? getTranslated('now', context)
                                      : '${DateConverter.dateToTimeOnly(orderProvider.timeSlots![index].startTime!, context)} '
                                      '- ${DateConverter.dateToTimeOnly(orderProvider.timeSlots![index].endTime!, context)}',
                                  isSelected: orderProvider.selectTimeSlot == index,
                                  onTap: () => orderProvider.updateTimeSlot(index),
                                );
                              },
                            ) : Center(child: Text(getTranslated('no_slot_available', context)!)) : const Center(child: CircularProgressIndicator()),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          PaymentSection(total: (widget.amount ?? 0) + (deliveryCharge ?? 0)),
                          if(ResponsiveHelper.isDesktop(context)) const SizedBox(height: Dimensions.paddingSizeDefault),

                          PartialPayView(totalPrice: (widget.amount ?? 0) + (deliveryCharge ?? 0)),


                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                            ).copyWith(left: Dimensions.paddingSizeDefault),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(getTranslated('add_delivery_note', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(height: Dimensions.fontSizeSmall),

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2), width: 1),
                                ),
                                child: CustomTextField(
                                    controller: _noteController,
                                    hintText: getTranslated('additional_note', context),
                                    maxLines: 5,
                                    inputType: TextInputType.multiline,
                                    inputAction: TextInputAction.newline,
                                    capitalization: TextCapitalization.sentences,
                                  ),
                              ),

                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if (!ResponsiveHelper.isDesktop(context))
                            CostSummeryView(
                              kmWiseCharge: kmWiseCharge,
                              takeAway: takeAway,
                              deliveryCharge: deliveryCharge,
                              subtotal: widget.amount,
                            ),






                        ])),

                        if(ResponsiveHelper.isDesktop(context)) Expanded(
                          flex: 4,
                          child: Container(
                            padding: ResponsiveHelper.isDesktop(context) ?   const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.all(0),
                            margin: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall) : const EdgeInsets.all(0),
                            decoration:ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:ColorResources.cardShadowColor.withOpacity(0.2),
                                    blurRadius: 10,
                                  )
                                ]
                            ) : const BoxDecoration(),
                            child: Column(children: [
                              CostSummeryView(
                                kmWiseCharge: kmWiseCharge,
                                takeAway: takeAway,
                                deliveryCharge: deliveryCharge,
                                subtotal: widget.amount,
                              ),

                              if(ResponsiveHelper.isDesktop(context))  ConfirmButtonView(
                                noteController: _noteController,
                                callBack: _callback,
                                cartList: _cartList,
                                kmWiseCharge: kmWiseCharge,
                                orderType: widget.orderType!,
                                orderAmount: widget.amount!,
                                couponCode: widget.couponCode,
                                deliveryCharge: deliveryCharge,
                              ),

                            ]),
                          ),
                        ),

                      ]),

                    ]),
                  ));
                });
              })),

              if(ResponsiveHelper.isDesktop(context)) const SliverFillRemaining(
                hasScrollBody: false,
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(height: Dimensions.paddingSizeLarge),

                  FooterView(),
                ]),
              ),

            ])),

          if(!ResponsiveHelper.isDesktop(context))   Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                double? deliveryCharge = 0;

                if(!takeAway && kmWiseCharge) {
                  deliveryCharge = orderProvider.distance * configModel.deliveryManagement!.shippingPerKm!;
                  if(deliveryCharge < configModel.deliveryManagement!.minShippingCharge!) {
                    deliveryCharge = configModel.deliveryManagement!.minShippingCharge;
                  }
                }else if(!takeAway && !kmWiseCharge) {
                  deliveryCharge = configModel.deliveryCharge;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: ItemView(
                        title: getTranslated('total_amount', context)!,
                        subTitle: PriceConverter.convertPrice(widget.amount! + deliveryCharge!),
                        style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                      ),
                    ),

                    ConfirmButtonView(
                        noteController: _noteController,
                        callBack: _callback,
                        cartList: _cartList,
                        kmWiseCharge: kmWiseCharge,
                        orderType: widget.orderType!,
                        orderAmount: widget.amount!,
                        couponCode: widget.couponCode,
                        deliveryCharge: deliveryCharge,
                      ),
                  ]),
                );
              }
          ),
        ],
      ) : const NotLoggedInScreen(),
    );
  }



  void _callback(bool isSuccess, String message, String orderID, int addressID) async {
    if(isSuccess) {
      if(widget.fromCart) {
        Provider.of<CartProvider>(context, listen: false).clearCartList();
      }
      Provider.of<OrderProvider>(context, listen: false).stopLoader();
      RouterHelper.getOrderSuccessScreen(orderID, 'success');

    }else {
      showCustomSnackBar(message);
    }
  }

  void _setMarkers(int selectedIndex) async {
    late BitmapDescriptor bitmapDescriptor;
    late BitmapDescriptor bitmapDescriptorUnSelect;

    List<Branches?> branches = Provider.of<SplashProvider>(context, listen: false).configModel!.branches!;

    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(30, 50)), Images.restaurantMarker).then((marker) {
      bitmapDescriptor = marker;
    });

    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(25, 40)), Images.unselectedRestaurantMarker).then((marker) {
      bitmapDescriptorUnSelect = marker;
    });


    // Marker
    _markers = HashSet<Marker>();
    for(int index=0; index < branches.length; index++) {

      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.parse(branches[index]!.latitude!), double.parse(branches[index]!.longitude!)),
        infoWindow: InfoWindow(title: branches[index]!.name, snippet: branches[index]!.address),
        icon: selectedIndex == index ? bitmapDescriptor : bitmapDescriptorUnSelect,
      ));
    }


    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
        double.parse(currentBranch!.latitude!),
        double.parse(currentBranch!.longitude!),
      ),
      zoom: ResponsiveHelper.isMobile() ? 12 : 16,
    )));

    setState(() {});
  }


  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 30}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  void _checkPermission(Function navigateTo) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar(getTranslated('you_have_to_allow', Get.context!));
    }else if(permission == LocationPermission.deniedForever) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => const PermissionDialog());
    }else {
      navigateTo();
    }
  }
}







