class PTDocumentIDCheckResult {
  String? message;
  List<ImageSubWorkTypeMenu>? data;
  int? documentId;
  String? workTypeName;
  int? workTypeId;
  int? imageSubWorkTypeId;
  List<WoImageHeaderListModel>? woImageHeaderListModel;
  String? ticketNo;

  PTDocumentIDCheckResult(
      {this.message,
      this.data,
      this.documentId,
      this.workTypeName,
      this.workTypeId,
      this.imageSubWorkTypeId,
      this.woImageHeaderListModel,
      this.ticketNo});

  PTDocumentIDCheckResult.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <ImageSubWorkTypeMenu>[];
      json['data'].forEach((v) {
        data!.add(new ImageSubWorkTypeMenu.fromJson(v));
      });
    }
    documentId = json['documentId'];
    workTypeName = json['workTypeName'];
    workTypeId = json['workTypeId'];
    imageSubWorkTypeId = json['imageSubWorkTypeId'];
    if (json['woImageHeaderListModel'] != null) {
      woImageHeaderListModel = <WoImageHeaderListModel>[];
      json['woImageHeaderListModel'].forEach((v) {
        woImageHeaderListModel!.add(new WoImageHeaderListModel.fromJson(v));
      });
    }
    ticketNo = json['ticketNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['documentId'] = this.documentId;
    data['workTypeName'] = this.workTypeName;
    data['workTypeId'] = this.workTypeId;
    data['imageSubWorkTypeId'] = this.imageSubWorkTypeId;
    if (this.woImageHeaderListModel != null) {
      data['woImageHeaderListModel'] =
          this.woImageHeaderListModel!.map((v) => v.toJson()).toList();
    }
    data['ticketNo'] = this.ticketNo;
    return data;
  }
}

class ImageSubWorkTypeMenu {
  int? imageSubWorkTypeId;
  int? workTypeId;
  String? menuWorkTypeNameWeb;
  String? menuWorkTypeNameMobile;
  String? createdBy;
  String? createdOn;
  bool? isDeleted;
  String? modifiedBy;
  String? modifiedOn;

  ImageSubWorkTypeMenu(
      {this.imageSubWorkTypeId,
      this.workTypeId,
      this.menuWorkTypeNameWeb,
      this.menuWorkTypeNameMobile,
      this.createdBy,
      this.createdOn,
      this.isDeleted,
      this.modifiedBy,
      this.modifiedOn});

  ImageSubWorkTypeMenu.fromJson(Map<String, dynamic> json) {
    imageSubWorkTypeId = json['imageSubWorkTypeId'];
    workTypeId = json['workTypeId'];
    menuWorkTypeNameWeb = json['menuWorkTypeNameWeb'];
    menuWorkTypeNameMobile = json['menuWorkTypeNameMobile'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    isDeleted = json['isDeleted'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageSubWorkTypeId'] = this.imageSubWorkTypeId;
    data['workTypeId'] = this.workTypeId;
    data['menuWorkTypeNameWeb'] = this.menuWorkTypeNameWeb;
    data['menuWorkTypeNameMobile'] = this.menuWorkTypeNameMobile;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['isDeleted'] = this.isDeleted;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}

class WoImageHeaderListModel {
  int? woImageHeaderId;
  int? documentId;
  int? workTypeId;
  String? workTypeName;
  int? loadTypeId;
  String? loadTypeName;
  int? imageSubWorkTypeId;
  Null? menuWorkTypeNameWeb;
  String? menuWorkTypeNameMobile;
  bool? isCompleted;
  String? sloc;
  Null? createdBy;
  String? createdOn;
  bool? isDeleted;
  Null? modifiedBy;
  Null? modifiedOn;

  WoImageHeaderListModel(
      {this.woImageHeaderId,
      this.documentId,
      this.workTypeId,
      this.workTypeName,
      this.loadTypeId,
      this.loadTypeName,
      this.imageSubWorkTypeId,
      this.menuWorkTypeNameWeb,
      this.menuWorkTypeNameMobile,
      this.isCompleted,
      this.sloc,
      this.createdBy,
      this.createdOn,
      this.isDeleted,
      this.modifiedBy,
      this.modifiedOn});

  WoImageHeaderListModel.fromJson(Map<String, dynamic> json) {
    woImageHeaderId = json['woImageHeaderId'];
    documentId = json['documentId'];
    workTypeId = json['workTypeId'];
    workTypeName = json['workTypeName'];
    loadTypeId = json['loadTypeId'];
    loadTypeName = json['loadTypeName'];
    imageSubWorkTypeId = json['imageSubWorkTypeId'];
    menuWorkTypeNameWeb = json['menuWorkTypeNameWeb'];
    menuWorkTypeNameMobile = json['menuWorkTypeNameMobile'];
    isCompleted = json['isCompleted'];
    sloc = json['sloc'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    isDeleted = json['isDeleted'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['woImageHeaderId'] = this.woImageHeaderId;
    data['documentId'] = this.documentId;
    data['workTypeId'] = this.workTypeId;
    data['workTypeName'] = this.workTypeName;
    data['loadTypeId'] = this.loadTypeId;
    data['loadTypeName'] = this.loadTypeName;
    data['imageSubWorkTypeId'] = this.imageSubWorkTypeId;
    data['menuWorkTypeNameWeb'] = this.menuWorkTypeNameWeb;
    data['menuWorkTypeNameMobile'] = this.menuWorkTypeNameMobile;
    data['isCompleted'] = this.isCompleted;
    data['sloc'] = this.sloc;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['isDeleted'] = this.isDeleted;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}
