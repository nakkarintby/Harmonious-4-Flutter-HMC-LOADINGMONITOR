class PostImageResult {
  int? woImageDetailId;
  int? woImageHeaderId;
  int? sequence;
  String? name;
  int? min;
  int? max;
  bool? alert;
  int? numberUpload;
  bool? isCompleted;
  String? createdBy;
  String? createdOn;
  bool? isDeleted;
  String? modifiedBy;
  String? modifiedOn;

  PostImageResult(
      {this.woImageDetailId,
      this.woImageHeaderId,
      this.sequence,
      this.name,
      this.min,
      this.max,
      this.alert,
      this.numberUpload,
      this.isCompleted,
      this.createdBy,
      this.createdOn,
      this.isDeleted,
      this.modifiedBy,
      this.modifiedOn});

  PostImageResult.fromJson(Map<String, dynamic> json) {
    woImageDetailId = json['woImageDetailId'];
    woImageHeaderId = json['woImageHeaderId'];
    sequence = json['sequence'];
    name = json['name'];
    min = json['min'];
    max = json['max'];
    alert = json['alert'];
    numberUpload = json['numberUpload'];
    isCompleted = json['isCompleted'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    isDeleted = json['isDeleted'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['woImageDetailId'] = this.woImageDetailId;
    data['woImageHeaderId'] = this.woImageHeaderId;
    data['sequence'] = this.sequence;
    data['name'] = this.name;
    data['min'] = this.min;
    data['max'] = this.max;
    data['alert'] = this.alert;
    data['numberUpload'] = this.numberUpload;
    data['isCompleted'] = this.isCompleted;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['isDeleted'] = this.isDeleted;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}
