class ItemWoCheckSheetDetail {
  int? runningNo;
  int? woCheckSheetItemId;
  int? checkSheetHeaderId;
  int? checkSheetHeaderSequence;
  String? checkSheetHeaderName;
  int? woCheckSheetHeaderId;
  int? sequence;
  String? detail;
  bool? ischecked;
  bool? severityLevel;
  String? remark;
  String? createdBy;
  String? createdOn;
  bool? isDeleted;
  String? modifiedBy;
  String? modifiedOn;

  ItemWoCheckSheetDetail(
      {this.runningNo,
      this.woCheckSheetItemId,
      this.checkSheetHeaderId,
      this.checkSheetHeaderSequence,
      this.checkSheetHeaderName,
      this.woCheckSheetHeaderId,
      this.sequence,
      this.detail,
      this.ischecked,
      this.severityLevel,
      this.remark,
      this.createdBy,
      this.createdOn,
      this.isDeleted,
      this.modifiedBy,
      this.modifiedOn});

  ItemWoCheckSheetDetail.fromJson(Map<String, dynamic> json) {
    runningNo = json['runningNo'];
    woCheckSheetItemId = json['woCheckSheetItemId'];
    checkSheetHeaderId = json['checkSheetHeaderId'];
    checkSheetHeaderSequence = json['checkSheetHeaderSequence'];
    checkSheetHeaderName = json['checkSheetHeaderName'];
    woCheckSheetHeaderId = json['woCheckSheetHeaderId'];
    sequence = json['sequence'];
    detail = json['detail'];
    ischecked = json['ischecked'];
    severityLevel = json['severityLevel'];
    remark = json['remark'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    isDeleted = json['isDeleted'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['runningNo'] = this.runningNo;
    data['woCheckSheetItemId'] = this.woCheckSheetItemId;
    data['checkSheetHeaderId'] = this.checkSheetHeaderId;
    data['checkSheetHeaderSequence'] = this.checkSheetHeaderSequence;
    data['checkSheetHeaderName'] = this.checkSheetHeaderName;
    data['woCheckSheetHeaderId'] = this.woCheckSheetHeaderId;
    data['sequence'] = this.sequence;
    data['detail'] = this.detail;
    data['ischecked'] = this.ischecked;
    data['severityLevel'] = this.severityLevel;
    data['remark'] = this.remark;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['isDeleted'] = this.isDeleted;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}
