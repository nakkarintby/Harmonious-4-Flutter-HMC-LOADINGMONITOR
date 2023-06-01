class ListLoadTypeMenu {
  List<LoadTypeMenu>? data;

  ListLoadTypeMenu({this.data});

  ListLoadTypeMenu.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <LoadTypeMenu>[];
      json['data'].forEach((v) {
        data!.add(new LoadTypeMenu.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LoadTypeMenu {
  int? loadTypeId;
  String? loadTypeName;

  LoadTypeMenu({this.loadTypeId, this.loadTypeName});

  LoadTypeMenu.fromJson(Map<String, dynamic> json) {
    loadTypeId = json['loadTypeId'];
    loadTypeName = json['loadTypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loadTypeId'] = this.loadTypeId;
    data['loadTypeName'] = this.loadTypeName;
    return data;
  }
}
