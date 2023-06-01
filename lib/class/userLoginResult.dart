class UserLoginResult {
  String? userId;
  String? accesstoken;
  String? refreshtoken;
  String? expiration;

  UserLoginResult(
      {this.userId, this.accesstoken, this.refreshtoken, this.expiration});

  UserLoginResult.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    accesstoken = json['accesstoken'];
    refreshtoken = json['refreshtoken'];
    expiration = json['expiration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['accesstoken'] = this.accesstoken;
    data['refreshtoken'] = this.refreshtoken;
    data['expiration'] = this.expiration;
    return data;
  }
}
