import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class StockTagView extends StatelessWidget {
  final Product product;
  const StockTagView({
    Key? key, required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);

    return !productProvider.checkStock(product)  ? Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      width: double.maxFinite,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
      child: Text(getTranslated('out_of_stock', context)!, textAlign: TextAlign.center,
          style: rubikRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)
      ),
    ))) : const SizedBox();
  }
}
