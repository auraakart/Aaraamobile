class CreateSubCheckoutRouteModel {
  String? subPrice;
  String? price;
  String? advanceAmount;
  DateTime? startDate;
  int? subVariationID;
  int? productId;
  int? quanity;
  int? subProductId;
  String? imageUrl;
  String? productName;
  String? weight;
  int? deliverySlotId;
  String? deliveryScheduleKey;
  List<int>? deliveryDays;

  CreateSubCheckoutRouteModel(
      {this.subPrice,
      this.price,
      this.advanceAmount,
      this.startDate,
      this.subVariationID,
      this.productId,
      this.quanity,
      this.subProductId,
      this.imageUrl,
      this.productName,
      this.weight,
      this.deliverySlotId,
      this.deliveryScheduleKey,
      this.deliveryDays});

  CreateSubCheckoutRouteModel copyWith(
          {String? subPrice,
          String? price,
          String? advanceAmount,
          DateTime? startDate,
          int? subVariationID,
          int? productId,
          int? quanity,
          int? subProductId,
          String? imageUrl,
          String? productName,
          String? weight,
          int? deliverySlotId,
          String? deliveryScheduleKey,
          List<int>? deliveryDays}) =>
      CreateSubCheckoutRouteModel(
        subPrice: subPrice ?? this.subPrice,
        price: price ?? this.price,
        advanceAmount: advanceAmount ?? this.advanceAmount,
        startDate: startDate ?? this.startDate,
        subVariationID: subVariationID ?? this.subVariationID,
        productId: productId ?? this.productId,
        quanity: quanity ?? this.quanity,
        subProductId: subProductId ?? this.subProductId,
        imageUrl: imageUrl ?? this.imageUrl,
        productName: productName ?? this.productName,
        weight: weight ?? this.weight,
        deliverySlotId: deliverySlotId ?? this.deliverySlotId,
        deliveryScheduleKey: deliveryScheduleKey ?? this.deliveryScheduleKey,
        deliveryDays: deliveryDays ?? this.deliveryDays,
      );
}


