import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/filter_button_widget.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/no_data_screen.dart';
import 'package:flutter_restaurant/view/base/product_shimmer.dart';
import 'package:flutter_restaurant/view/base/product_widget.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/product_web_card_shimmer.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/product_widget_web.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;
  final String? categoryBannerImage;
  const CategoryScreen({Key? key, required this.categoryId, this.categoryName, this.categoryBannerImage}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  int _tabIndex = 0;
  String _type = 'all';

 @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
    Provider.of<CategoryProvider>(context, listen: false).getCategoryList(false);
    Provider.of<CategoryProvider>(context, listen: false).getSubCategoryList(widget.categoryId);
 }

  @override
  Widget build(BuildContext context) {
   final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
   final Size size = MediaQuery.sizeOf(context);
   final double realSpaceNeeded = (size.width - Dimensions.webScreenWidth) / 2;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar()) : null,
      body: Consumer<CategoryProvider>(
        builder: (context, category, child) {
          return category.isLoading || category.categoryList == null ?
          categoryShimmer(context, size.height, category) :
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).cardColor,
                expandedHeight: 200,
                toolbarHeight: 50 + MediaQuery.of(context).padding.top,
                pinned: true,
                floating: false,
                leading: ResponsiveHelper.isDesktop(context)?const SizedBox():SizedBox(width:ResponsiveHelper.isDesktop(context) ? 1170: MediaQuery.of(context).size.width,
                    child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => context.pop())),
                flexibleSpace: Container(color:Theme.of(context).canvasColor,
                  margin: ResponsiveHelper.isDesktop(context)? EdgeInsets.symmetric(horizontal: realSpaceNeeded) : const EdgeInsets.symmetric(horizontal: 0),width: ResponsiveHelper.isDesktop(context) ? 1170: MediaQuery.of(context).size.width,
                  child: FlexibleSpaceBar(
                    title: Text(widget.categoryName ?? '', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    titlePadding: EdgeInsets.only(
                      bottom: 54 + (MediaQuery.of(context).padding.top/2),
                      left: 50,
                      right: 50,
                    ),
                    background: Container(height: 50,width : ResponsiveHelper.isDesktop(context) ? 1170: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(bottom: 50),
                      child: FadeInImage.assetNetwork(
                        placeholder: Images.categoryBanner, fit: BoxFit.cover,
                        image: '${splashProvider.baseUrls?.categoryBannerImageUrl}/${widget.categoryBannerImage}',
                        imageErrorBuilder: (c, o, s) => Image.asset(Images.categoryBanner, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30.0),
                  child: category.subCategoryList != null?Container(
                    width:  ResponsiveHelper.isDesktop(context) ? 1170: MediaQuery.of(context).size.width,
                    color: Theme.of(context).cardColor,
                    child: TabBar(
                      controller: TabController(initialIndex: _tabIndex,
                          length: category.subCategoryList!.length+1, vsync: this),
                      isScrollable: true,
                      unselectedLabelColor: Theme.of(context).hintColor.withOpacity(0.7),
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Theme.of(context).primaryColor,
                      labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                      tabs: _tabs(category),
                      onTap: (int index) {
                        _type = 'all';
                        _tabIndex = index;
                        if(index == 0) {
                          category.getCategoryProductList(widget.categoryId);
                        }else {
                          category.getCategoryProductList(category.subCategoryList![index-1].id.toString());
                        }
                      },
                    ),
                  ):const SizedBox(),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [

                    FilterButtonWidget(
                      type: _type,
                      items: Provider.of<ProductProvider>(context).productTypeList,
                      onSelected: (selected) {
                        _type = selected;
                       category.getCategoryProductList(category.selectedSubCategoryId, type: _type);

                      },
                    ),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: size.height < 600 ?  size.height : size.height - 600,
                      ),
                      child: SizedBox(
                        width: 1170,
                        child: category.categoryProductList != null ? category.categoryProductList!.isNotEmpty ?
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 13,
                              mainAxisSpacing: 13,
                              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.7 : 4,
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1),
                          itemCount: category.categoryProductList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          itemBuilder: (context, index) {
                            return ResponsiveHelper.isDesktop(context) ? ProductWidgetWeb(product: category.categoryProductList![index]): ProductWidget(product: category.categoryProductList![index]);
                          },
                        ) : const NoDataScreen(isFooter: false) :
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.7: 4,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1,
                          ),
                          itemBuilder: (context, index) {
                            return ResponsiveHelper.isDesktop(context)? const ProductWidgetWebShimmer ():ProductShimmer(isEnabled: category.categoryProductList == null);
                          },
                        ),
                      ),
                    ),
                    if(ResponsiveHelper.isDesktop(context)) const FooterView(),
                  ],
                ),
              ),

            ],
          );
        },
      ),
    );
  }

  SingleChildScrollView categoryShimmer(BuildContext context, double height, CategoryProvider category) {
    return SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                child: Center(
                  child: SizedBox(
                    width: 1170,
                    child: Column(
                      children: [
                        Shimmer(
                            duration: const Duration(seconds: 2),
                            enabled: true,
                            child: Container(height: 200,width: double.infinity,color: Theme.of(context).shadowColor)),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.7: 4,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 2 : 1,
                          ),
                          itemBuilder: (context, index) {
                            return ResponsiveHelper.isDesktop(context)? const ProductWidgetWebShimmer ():ProductShimmer(isEnabled: category.categoryProductList == null);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(ResponsiveHelper.isDesktop(context)) const FooterView(),
            ],
          ),
        );
  }

  List<Tab> _tabs(CategoryProvider category) {
    List<Tab> tabList = [];
    tabList.add(const Tab(text: 'All'));
    for (var subCategory in category.subCategoryList!) {
      tabList.add(Tab(text: subCategory.name));
    }
    return tabList;
  }
}
