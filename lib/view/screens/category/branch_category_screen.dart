import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/qr_code_mode.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/branch_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/no_data_screen.dart';
import 'package:flutter_restaurant/view/screens/category/widget/qr_product_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BranchCategoryScreen extends StatefulWidget {
  final QrCodeModel? qrCodeModel;
  const BranchCategoryScreen({Key? key, this.qrCodeModel}) : super(key: key);

  @override
  State<BranchCategoryScreen> createState() => _BranchCategoryScreenState();
}

class _BranchCategoryScreenState extends State<BranchCategoryScreen> with SingleTickerProviderStateMixin{
  TabController? tabController;
  String type = 'all';
  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    tabController = TabController(vsync: this, length: 3);

    super.initState();

    final branchProvider = Provider.of<BranchProvider>(context, listen: false);
    if(widget.qrCodeModel != null &&  branchProvider.getBranchId() != widget.qrCodeModel?.branchId) {
      branchProvider.setBranch(widget.qrCodeModel!.branchId!);

      Future.delayed(const Duration(milliseconds: 500)).then((value){
        showCustomSnackBar(getTranslated('branch_successfully_selected', context), isError: false);
      });
    }
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    categoryProvider.getCategoryList(true).then((value){
      categoryProvider.getSubCategoryList('${categoryProvider.selectedSubCategoryId}', );
    });

    tabController?.addListener(() {
      if(!tabController!.indexIsChanging){
        if(tabController?.index == 0){
          type = 'all';

        }else if(tabController?.index == 1){
          type = 'veg';
        }else{
          type = 'non_veg';
        }
        categoryProvider.getSubCategoryList('${categoryProvider.selectedSubCategoryId}', type: type);

      }
    });
  }
  @override
  void dispose() {
    searchController.dispose();
    tabController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).cardColor,
          onPressed: () => RouterHelper.getDashboardRoute('cart'),
          label: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_cart, color: Theme.of(context).textTheme.bodyLarge!.color),
              Positioned(
                top: -10, right: -10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  child: Center(
                    child: Text(
                      Provider.of<CartProvider>(context).cartList.length.toString(),
                      style: rubikMedium.copyWith(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBar(title: getTranslated('menu', context), onBackPressed: (){
          if(context.canPop()) {
            context.pop();
          }else{

            RouterHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
          }
        }),
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, _) {
            return NestedScrollView(headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: SearchBar(
                  controller: searchController,
                  onChanged: (String? value){
                    categoryProvider.getCategoryProductList('${categoryProvider.selectedSubCategoryId}', type: type, name: value);
                  },
                  elevation: MaterialStateProperty.all(0),
                  leading: Icon(Icons.search,color: Theme.of(context).hintColor),  hintText: getTranslated('search_by_item_or_category', context),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).canvasColor
                  ),
                  hintStyle: MaterialStateProperty.all(rubikRegular.copyWith(color: Theme.of(context).hintColor)),
                ),
              )),

              SliverToBoxAdapter(child: Center(child: TabBar(
                controller: tabController,
                labelColor: Colors.black,
                tabs: [
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.all_inbox),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(getTranslated('all', context)!),
                  ])),

                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(Images.getImageUrl('veg'), height: IconTheme.of(context).size),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(getTranslated('veg', context)!),
                  ])),

                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(Images.getImageUrl('non_veg'), height: IconTheme.of(context).size),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(getTranslated('non_veg', context)!),
                  ])),
                ],
              ))),
            ], body: Row(children: [
              Expanded(flex: 1, child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                child: categoryProvider.categoryList == null ? const SizedBox() : ListView.builder(
                  itemCount: categoryProvider.categoryList?.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    String? name = '';
                    categoryProvider.categoryList![index].name!.length > 15  ? name = '${categoryProvider.categoryList![index].name!.substring(0, 15)} ...' : name = categoryProvider.categoryList![index].name;
                    return Container(
                      margin: const EdgeInsets.only(right:  10),
                      decoration: categoryProvider.selectedSubCategoryId == categoryProvider.categoryList![index].id.toString() ? BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context).primaryColor.withOpacity(0.3) ,

                      ) : const BoxDecoration(),
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraSmall),
                      child: InkWell(
                        onTap: ()=> categoryProvider.getCategoryProductList('${categoryProvider.categoryList![index].id}', type: type),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                          ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: Images.placeholderImage, width: 40, height: 40, fit: BoxFit.cover,
                              image: Provider.of<SplashProvider>(context, listen: false).baseUrls != null
                                  ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${categoryProvider.categoryList![index].image}':'',
                              imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderImage, width: 40, height: 40, fit: BoxFit.cover),
                              // width: 100, height: 100, fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text(name!, overflow: TextOverflow.ellipsis, maxLines: 2, style: rubikMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                        ]),
                      ),
                    );
                  },
                ),
              )),

              Expanded(flex: 3, child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: TabBarView(controller: tabController, children: const [
                  QProductList(),
                  QProductList(),
                  QProductList(),
                ]),
              )),
            ]));
          }
        ),

      ),
    );
  }
}

class QProductList extends StatelessWidget {
  const QProductList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        return categoryProvider.categoryProductList == null ? const Center(child: CircularProgressIndicator()) : categoryProvider.categoryProductList!.isNotEmpty ?  GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Dimensions.paddingSizeDefault,
            mainAxisSpacing: Dimensions.paddingSizeDefault,
            childAspectRatio: 0.8,
          ),
          itemCount: categoryProvider.categoryProductList?.length,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return QrProductWidget(product: categoryProvider.categoryProductList![index]);
          },
        ) : const NoDataScreen();
      }
    );
  }
}

class AliveKeeper extends StatefulWidget {
 final int index;

  const AliveKeeper({
    required this.index,
    GlobalKey? key,
  }) : super(key: key);

  @override
  AliveKeeperState createState() => AliveKeeperState();
}

class AliveKeeperState extends State<AliveKeeper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Text('Item ${widget.index}');
  }
}