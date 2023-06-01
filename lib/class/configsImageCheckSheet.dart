class ConfigsImageCheckSheet {
  String? min;
  String? max;

  ConfigsImageCheckSheet({this.min, this.max});

  ConfigsImageCheckSheet.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['min'] = this.min;
    data['max'] = this.max;
    return data;
  }
}
