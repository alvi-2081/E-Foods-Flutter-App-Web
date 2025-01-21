import 'dart:convert';

// class WalletBonusModelList {
//     List<WalletBonusModelList>? walletBonusModel;
//
//     WalletBonusModelList({this.walletBonusModel});
//
//     factory WalletBonusModelList.fromJson(Map<String, dynamic> json) => WalletBonusModelList(
//         walletBonusModel: List<WalletBonusModelList>.from(json["content"].map((x) => WalletBonusModelList.fromJson(x))),
//     );
//
// }



class WalletBonusModel {
    String? title;
    String? description;
    String? bonusType;
    double? bonusAmount;
    double? minimumAddAmount;
    double? maximumBonusAmount;
    DateTime? startDate;
    DateTime? endDate;
    DateTime? createdAt;
    DateTime? updatedAt;

    WalletBonusModel({
        this.title,
        this.description,
        this.bonusType,
        this.bonusAmount,
        this.minimumAddAmount,
        this.maximumBonusAmount,
        this.startDate,
        this.endDate,
        this.createdAt,
        this.updatedAt,
    });

    factory WalletBonusModel.fromRawJson(String str) => WalletBonusModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());



    factory WalletBonusModel.fromJson(Map<String, dynamic> json) => WalletBonusModel(
        title: json["title"],
        description: json["description"],
        bonusType: json["bonus_type"],
        bonusAmount: double.parse('${json["bonus_amount"]}'),
        minimumAddAmount: double.parse('${json["minimum_add_amount"]}'),
        maximumBonusAmount: double.parse('${json["maximum_bonus_amount"]}'),
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "bonus_type": bonusType,
        "bonus_amount": bonusAmount,
        "minimum_add_amount": minimumAddAmount,
        "maximum_bonus_amount": maximumBonusAmount,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
