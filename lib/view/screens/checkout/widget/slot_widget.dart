import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class SlotWidget extends StatelessWidget {
  final String? title;
  final bool isSelected;
  final Function onTap;
  const SlotWidget({Key? key, required this.title, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).secondaryHeaderColor : Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(children: [
            Image.asset(
              Images.schedule, width: Dimensions.paddingSizeDefault,
              color: isSelected ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Text(title!, style: rubikRegular.copyWith(
              color: isSelected ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
            )),
          ]),
        ),
      ),
    );
  }
}
