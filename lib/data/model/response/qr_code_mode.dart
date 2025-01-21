

import 'dart:convert';

class QrCodeModel {
  int? branchId;
  String? website;

  QrCodeModel({
    this.branchId,
    this.website,
  });

  factory QrCodeModel.fromJson(String str) => QrCodeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory QrCodeModel.fromMap(Map<String, dynamic> json) => QrCodeModel(
    branchId: 1,
    website: json["website"],
  );

  Map<String, dynamic> toMap() => {
    "branch_id": branchId,
    "website": website,
  };
}
