import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/menu_type.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/view/base/mars_menu_bar.dart';

class MenuBarView extends StatelessWidget {
  final bool isLeft;
  const MenuBarView(this.isLeft, {Key? key}) : super(key: key);
  List<MenuItemView> getCartMenu(BuildContext context) {
    return [
      MenuItemView(
        menuType: MenuType.menu,
        onTap: () =>  RouterHelper.getDashboardRoute('menu'),
      ),
      MenuItemView(
        menuType: MenuType.cart,
        icon: Icons.shopping_cart,
        onTap: () =>  RouterHelper.getDashboardRoute('cart'),
      ),
    ];
  }
  List<MenuItemView> getMenus(BuildContext context) {
    return [
      MenuItemView(
        menuType: MenuType.text,
        title: getTranslated('home', context),
        onTap: () =>  RouterHelper.getDashboardRoute('home'),
      ),
      
      MenuItemView(
        menuType: MenuType.text,
        title: 'Favourite',
        onTap: () =>  RouterHelper.getDashboardRoute('favourite'),
      ),
      

    ];
  }

  @override
  Widget build(BuildContext context) {

    return PlutoMenuBarView(
      backgroundColor: Theme.of(context).cardColor,
      gradient: false,
      goBackButtonText: 'Back',
      textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
      moreIconColor: Theme.of(context).textTheme.bodyLarge!.color,
      menuIconColor: Theme.of(context).textTheme.bodyLarge!.color,
      menus: isLeft ?  getMenus(context) : getCartMenu(context),

    );
  }
}