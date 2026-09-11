class MobileBannerListModel {
  final bool? success;
  final int? count;
  final List<MobileBanner>? banners;

  MobileBannerListModel({this.success, this.count, this.banners});

  factory MobileBannerListModel.fromJson(Map<String, dynamic> json) {
    return MobileBannerListModel(
      success: json['success'],
      count: json['count'],
      banners: json['banners'] != null
          ? List<MobileBanner>.from(
              json['banners'].map((x) => MobileBanner.fromJson(x)))
          : null,
    );
  }
}

class MobileBanner {
  final int? id;
  final int? attachmentId;
  final String? image;
  final String? thumbnail;
  final String? alt;

  MobileBanner({
    this.id,
    this.attachmentId,
    this.image,
    this.thumbnail,
    this.alt,
  });

  factory MobileBanner.fromJson(Map<String, dynamic> json) {
    return MobileBanner(
      id: json['id'],
      attachmentId: json['attachment_id'],
      image: json['image'],
      thumbnail: json['thumbnail'],
      alt: json['alt'],
    );
  }
}


