class GetItemWoImageDetailNotFound {
  int? woImageHeaderId;
  List<String>? data;

  GetItemWoImageDetailNotFound({this.woImageHeaderId, this.data});

  GetItemWoImageDetailNotFound.fromJson(Map<String, dynamic> json) {
    woImageHeaderId = json['woImageHeaderId'];
    data = json['data'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['woImageHeaderId'] = this.woImageHeaderId;
    data['data'] = this.data;
    return data;
  }
}
