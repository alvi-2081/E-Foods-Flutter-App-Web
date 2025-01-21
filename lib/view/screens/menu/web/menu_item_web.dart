
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/menu_model.dart';

import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';

class MenuItemWeb extends StatelessWidget {
  final MenuModel menu;
  const MenuItemWeb({Key? key, required this.menu}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32.0),
      onTap: ()=> menu.route(),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.04), borderRadius: BorderRadius.circular(32.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            menu.iconWidget != null ? menu.iconWidget!
                : Image.asset(menu.icon, width: 50, height: 50, color: Theme.of(context).textTheme.bodyLarge!.color),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(menu.title!, style: robotoRegular),
          ],
        ),
      ),
    );
  }
}
