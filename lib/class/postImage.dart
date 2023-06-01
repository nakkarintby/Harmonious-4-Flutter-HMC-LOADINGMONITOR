class PostImage {
  int? woImageDetailId;
  String? type;
  int? imageNo;
  String? imageValue;
  String? deviceInfo;
  String? osInfo;

  PostImage(
      {this.woImageDetailId,
      this.type,
      this.imageNo,
      this.imageValue,
      this.deviceInfo,
      this.osInfo});

  PostImage.fromJson(Map<String, dynamic> json) {
    woImageDetailId = json['woImageDetailId'];
    type = json['type'];
    imageNo = json['imageNo'];
    imageValue = json['imageValue'];
    deviceInfo = json['deviceInfo'];
    osInfo = json['osInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['woImageDetailId'] = this.woImageDetailId;
    data['type'] = this.type;
    data['imageNo'] = this.imageNo;
    data['imageValue'] = this.imageValue;
    data['deviceInfo'] = this.deviceInfo;
    data['osInfo'] = this.osInfo;
    return data;
  }
}
