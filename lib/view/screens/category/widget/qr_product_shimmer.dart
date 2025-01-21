import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/view/base/custom_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class QrProductShimmer extends StatelessWidget {
  const QrProductShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Dimensions.paddingSizeDefault,
          mainAxisSpacing: Dimensions.paddingSizeDefault,
        ),

        itemBuilder: (context, index) {
          return Shimmer(
            color: Theme.of(context).shadowColor,
            child: Stack(
              children: [
                Column(children: [

                  const SizedBox(height: 5),

                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(width: 100,height: 20, color: Colors.red),
                    ),
                  ),

                  const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Stack(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                child: CustomImage(
                                  height: double.infinity, width: double.infinity,
                                  image: '',
                                  fit: BoxFit.cover,
                                ),
                              ),

                            ],
                          ),


                        ],
                      ),
                    ),
                  ),



                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
