class UserLogin {
  String? username;
  String? password;
  bool? rememberLogin;
  String? returnUrl;

  UserLogin({this.username, this.password, this.rememberLogin, this.returnUrl});

  UserLogin.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    rememberLogin = json['rememberLogin'];
    returnUrl = json['returnUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['password'] = this.password;
    data['rememberLogin'] = this.rememberLogin;
    data['returnUrl'] = this.returnUrl;
    return data;
  }
}
