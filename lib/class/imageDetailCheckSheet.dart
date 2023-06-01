class ImageDetailCheckSheet {
  String? min;
  String? max;
  Detail? detail;

  ImageDetailCheckSheet({this.min, this.max, this.detail});

  ImageDetailCheckSheet.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
    detail =
        json['detail'] != null ? new Detail.fromJson(json['detail']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['min'] = this.min;
    data['max'] = this.max;
    if (this.detail != null) {
      data['detail'] = this.detail!.toJson();
    }
    return data;
  }
}

class Detail {
  int? referenceId;
  String? referenceType;
  int? imageNo;
  String? imageValue;
  String? deviceInfo;
  String? osInfo;

  Detail(
      {this.referenceId,
      this.referenceType,
      this.imageNo,
      this.imageValue,
      this.deviceInfo,
      this.osInfo});

  Detail.fromJson(Map<String, dynamic> json) {
    referenceId = json['referenceId'];
    referenceType = json['referenceType'];
    imageNo = json['imageNo'];
    imageValue = json['imageValue'];
    deviceInfo = json['deviceInfo'];
    osInfo = json['osInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['referenceId'] = this.referenceId;
    data['referenceType'] = this.referenceType;
    data['imageNo'] = this.imageNo;
    data['imageValue'] = this.imageValue;
    data['deviceInfo'] = this.deviceInfo;
    data['osInfo'] = this.osInfo;
    return data;
  }
}
