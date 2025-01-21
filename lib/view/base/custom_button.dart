import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';

class CustomButton extends StatelessWidget {
  final Function? onTap;
  final String? btnTxt;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool transparent;
  final EdgeInsets? margin;


  const CustomButton({
    Key? key, this.onTap, required this.btnTxt,
    this.backgroundColor, this.textStyle,
    this.borderRadius = 10, this.width, this.transparent = false, this.height, this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onTap == null ? Theme.of(context).disabledColor : transparent
          ? Colors.transparent : backgroundColor ?? Theme.of(context).primaryColor,
      // minimumSize: Size(MediaQuery.of(context).size.width, 50),
      minimumSize: Size(width != null ? width! : Dimensions.webScreenWidth, height != null ? height! : 50),

      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    return Center(child: SizedBox(width: width ?? Dimensions.webScreenWidth, child: Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: TextButton(
        onPressed: onTap as void Function()?,
        style: flatButtonStyle,
        child: Text(btnTxt ?? '',
            style: textStyle ?? Theme.of(context).textTheme.displaySmall!.copyWith(color:Colors.white, fontSize: Dimensions.fontSizeLarge)),
      ),
    )));
  }
}
