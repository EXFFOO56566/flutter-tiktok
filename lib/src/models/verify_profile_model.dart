class VerifyProfileModel {
  String name = "";
  String address = "";
  String document1 = "";
  String document2 = "";
  String reason = "";
  String verified = "";
  String addedOn = "";
  VerifyProfileModel();

  VerifyProfileModel.fromJSON(Map<String, dynamic> json) {
    try {
      name = json['name'] != null ? json['name'] : '';
      address = json['address'] != null ? json['address'] : '';
      document1 = json['document1'] != null ? json['document1'] : '';
      document2 = json['document2'] != null ? json['document2'] : '';
      reason = json['rejected_reason'] != null ? json['rejected_reason'] : '';
      verified = json['verified'] != null ? json['verified'] : "NA";
      addedOn = json['added_on'] != null ? json['added_on'] : "";
    } catch (e) {
      name = '';
      address = '';
      document1 = '';
      document2 = '';
      reason = '';
      addedOn = '';
      verified = "NA";
    }
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    data['document1'] = this.document1;
    data['document2'] = this.document2;
    data['verified'] = this.verified;
    data['rejected_reason'] = this.reason;
    data['added_on'] = this.addedOn.toString();

    return data;
  }
}
