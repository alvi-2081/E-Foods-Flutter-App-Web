import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/menu_bar_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final BuildContext? context;
  final Widget? actionView;
  final bool centerTitle;
  const CustomAppBar({Key? key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.context, this.actionView, this.centerTitle = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? Center(
      child: Container(
          color: Theme.of(context).cardColor,
          width: 1170,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => RouterHelper.getMainRoute(),
                  child: Provider.of<SplashProvider>(context).baseUrls != null?  Consumer<SplashProvider>(
                      builder:(context, splash, child) => FadeInImage.assetNetwork(
                        placeholder: Images.placeholderRectangle, image:  '${splash.baseUrls!.restaurantImageUrl}/${splash.configModel!.restaurantLogo}',
                        width: 120, height: 80,
                        imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderRectangle, width: 120, height: 80),
                      )): const SizedBox(),
                ),
              ),
              const MenuBarView(true),
            ],
          )
      ),
    ) : AppBar(
      title: Text(title!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: centerTitle,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: () => onBackPressed != null ? onBackPressed!() : context.pop(),
      ) : const SizedBox(),
      actions: actionView != null ? [actionView!] : [],
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size(double.maxFinite, ResponsiveHelper.isDesktop(Get.context) ? 80 : 50);
}
