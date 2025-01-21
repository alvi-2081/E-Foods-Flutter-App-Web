
import 'package:flutter_restaurant/data/model/response/order_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/body/review_body_model.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/order_model.dart';
import 'package:flutter_restaurant/data/model/response/response_model.dart';
import 'package:flutter_restaurant/data/repository/product_repo.dart';
import 'package:flutter_restaurant/helper/api_checker.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:provider/provider.dart';


class ReviewProvider extends ChangeNotifier {
  final ProductRepo? productRepo;

  ReviewProvider({required this.productRepo});


  bool _isReviewSubmitted = false;
  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  int _deliveryManRating = 0;
  bool _isLoading = false;


  bool get isReviewSubmitted => _isReviewSubmitted;
  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;
  bool get isLoading => _isLoading;


  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    for (int i = 0; i < orderDetailsList.length; i++) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    notifyListeners();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    notifyListeners();
  }

  Future<ResponseModel> submitReview(int index, ReviewBody reviewBody) async {
    _loadingList[index] = true;
    notifyListeners();

    ApiResponse response = await productRepo!.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      notifyListeners();
    } else {
      responseModel = ResponseModel(false, ApiChecker.getError(response).errors?.first.message);
    }
    _loadingList[index] = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBody reviewBody) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await productRepo!.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      responseModel = ResponseModel(true, getTranslated('review_submitted_successfully', Get.context!));
      updateSubmitted(true);

      notifyListeners();
    } else {
      responseModel = ResponseModel(false, ApiChecker.getError(response).errors?.first.message);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  updateSubmitted(bool value) {
    _isReviewSubmitted = value;
  }

  Future<DeliveryMan?> getDeliveryMan(String? orderId, {String? phoneNumber}) async {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(Get.context!, listen: false);
    DeliveryMan? deliveryMan;

    await orderProvider.trackOrder(orderId.toString(), phoneNumber: phoneNumber).then((value) {
      deliveryMan = orderProvider.trackModel?.deliveryMan;
    });

    return deliveryMan;
  }

  Future<List<OrderDetailsModel>> getOrderList(String? orderId, {String? phoneNumber}) async {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(Get.context!, listen: false);
    await orderProvider.getOrderDetails(orderId.toString(), phoneNumber: phoneNumber);

    List<OrderDetailsModel> orderDetailsList = [];
    List<int?> orderIdList = [];

    for (var orderDetails in orderProvider.orderDetails!) {
      if(!orderIdList.contains(orderDetails.productDetails!.id)) {
        orderDetailsList.add(orderDetails);
        orderIdList.add(orderDetails.productDetails!.id);
      }
    }
    return orderDetailsList;
  }

}
