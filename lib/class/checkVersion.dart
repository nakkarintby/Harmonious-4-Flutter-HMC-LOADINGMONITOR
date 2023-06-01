class checkVersion {
  String? msg;
  String? url;

  checkVersion({this.msg, this.url});

  checkVersion.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['url'] = this.url;
    return data;
  }
}
