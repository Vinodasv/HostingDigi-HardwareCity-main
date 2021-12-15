class OfferCategoryDataType {
  final String categoryName;
  final int categoryId;
  final String urlKey;
  final String imgPath;
  final String metaTitle;
  final String metaKeywords;
  final String metaDescription;
  final dynamic discount;

  final Object Obj;

  OfferCategoryDataType(
      this.categoryName,
      this.categoryId,
      this.urlKey,
      this.imgPath,
      this.metaTitle,
      this.metaKeywords,
      this.metaDescription,
      this.discount,
      this.Obj);
}

class PopularBrandsDataType {
  final int brandId;
  final String brandName;
  final String urlKey;
  final String imgPath;
  final String metaTitle;
  final String metaKeywords;
  final String metaDescription;
  final dynamic discount;

  final Object Obj;

  PopularBrandsDataType(
      this.brandId,
      this.brandName,
      this.urlKey,
      this.imgPath,
      this.metaTitle,
      this.metaKeywords,
      this.metaDescription,
      this.discount,
      this.Obj);
}

class PromoContent {
  final String bannerName;
  final String bannerLink;
  final String imgPath;
  final String caption;
  final Object Obj;

  PromoContent(
      this.bannerName, this.bannerLink, this.imgPath, this.caption, this.Obj);
}

class SubCategoryDataType {
  final String response;
  final String message;
  final List<OfferCategoryDataType> categoryData;
  final List<ProductDataType> productData;
  final Object Obj;
  SubCategoryDataType(this.response, this.message, this.categoryData,
      this.productData, this.Obj);
}

class AlphaCategories {
  final bool isSelected;
  final String startchar;
  final List<PopularBrandsDataType> data;
  final Object Obj;
  AlphaCategories(this.startchar, this.isSelected, this.data, this.Obj);
}

class ProductDataType {
  final String itemId;
  bool inCart;
  final String itemName;
  final int qty;
  final int custQty;
  int count;
  bool fav;
  bool? isLoading;
  final String optionscount;
  // final double size;
  // final String shortDesc;
  // final String color;
  // final String specification;
  // final String urlKey;
  final String standardprice;
  final String price;

  final String shippingBox;
  final String weight;
  // final double qty;
  // final double custqty;
  // final double dimension;
  // final double catId;
  // final double brand;
  final String imgPath;
  final String gstprice;
  final String gststandardprice;
  // final String largeImgPath;
  // final String description;
  // final String videoPath;

  final Object Obj;

  ProductDataType(
      this.itemId,
      this.inCart,
      this.itemName,
      // this.size,
      // this.shortDesc,
      // this.color,
      // this.specification,
      // this.urlKey,
      this.standardprice,
      this.gststandardprice,
      this.gstprice,
      this.optionscount,
      this.price,
      this.weight,
      this.qty,
      this.custQty,
      // this.shippingBox,
      // this.weight,
      // this.qty,
      // this.custqty,
      // this.dimension,
      // this.catId,
      // this.brand,
      this.imgPath,
      this.shippingBox,
      // this.largeImgPath,
      // this.description,
      // this.videoPath,
      this.count,
      this.fav,
      this.Obj);
}

class CartDataType {
  String option;
  String itemId;
  String itemName;
  int count;
  int custQty;
  // final double size;
  // final String shortDesc;
  // final String color;
  // final String specification;
  // final String urlKey;
  double price;
  double total;

  // final String shippingBox;
  // final Float weight;
  // final double qty;
  // final double custqty;
  // final double dimension;
  // final double catId;
  // final double brand;
  String imgPath;
  // final String largeImgPath;
  // final String description;
  // final String videoPath;
  final Object Obj;

  CartDataType(
      this.option,
      this.itemId,
      this.itemName,
      this.count,
      this.custQty,
      // this.size,
      // this.shortDesc,
      // this.color,
      // this.specification,
      // this.urlKey,
      this.price,
      this.total,

      // this.shippingBox,
      // this.weight,
      // this.qty,
      // this.custqty,
      // this.dimension,
      // this.catId,
      // this.brand,
      this.imgPath,
      // this.largeImgPath,
      // this.description,
      // this.videoPath,
      this.Obj);
}
