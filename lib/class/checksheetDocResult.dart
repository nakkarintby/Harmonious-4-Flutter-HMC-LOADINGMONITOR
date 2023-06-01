class CheckSheetDocResult {
  DocumentDetail? documentDetail;
  List<WoCheckSheetHeaderList>? woCheckSheetHeaderList;

  CheckSheetDocResult({this.documentDetail, this.woCheckSheetHeaderList});

  CheckSheetDocResult.fromJson(Map<String, dynamic> json) {
    documentDetail = json['documentDetail'] != null
        ? new DocumentDetail.fromJson(json['documentDetail'])
        : null;
    if (json['woCheckSheetHeaderList'] != null) {
      woCheckSheetHeaderList = <WoCheckSheetHeaderList>[];
      json['woCheckSheetHeaderList'].forEach((v) {
        woCheckSheetHeaderList!.add(new WoCheckSheetHeaderList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.documentDetail != null) {
      data['documentDetail'] = this.documentDetail!.toJson();
    }
    if (this.woCheckSheetHeaderList != null) {
      data['woCheckSheetHeaderList'] =
          this.woCheckSheetHeaderList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DocumentDetail {
  int? documentId;
  int? truckId;
  String? containerNo;
  String? sealNo;
  String? inspectionBy;
  String? inspectionResult;

  DocumentDetail(
      {this.documentId,
      this.truckId,
      this.containerNo,
      this.sealNo,
      this.inspectionBy,
      this.inspectionResult});

  DocumentDetail.fromJson(Map<String, dynamic> json) {
    documentId = json['documentId'];
    truckId = json['truckId'];
    containerNo = json['containerNo'];
    sealNo = json['sealNo'];
    inspectionBy = json['inspectionBy'];
    inspectionResult = json['inspectionResult'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['documentId'] = this.documentId;
    data['truckId'] = this.truckId;
    data['containerNo'] = this.containerNo;
    data['sealNo'] = this.sealNo;
    data['inspectionBy'] = this.inspectionBy;
    data['inspectionResult'] = this.inspectionResult;
    return data;
  }
}

class WoCheckSheetHeaderList {
  int? woCheckSheetHeaderId;
  int? documentId;
  int? truckId;
  String? containerNo;
  String? sealNo;
  String? inspectionBy;
  String? inspectionResult;
  String? datetime;

  WoCheckSheetHeaderList(
      {this.woCheckSheetHeaderId,
      this.documentId,
      this.truckId,
      this.containerNo,
      this.sealNo,
      this.inspectionBy,
      this.inspectionResult,
      this.datetime});

  WoCheckSheetHeaderList.fromJson(Map<String, dynamic> json) {
    woCheckSheetHeaderId = json['woCheckSheetHeaderId'];
    documentId = json['documentId'];
    truckId = json['truckId'];
    containerNo = json['containerNo'];
    sealNo = json['sealNo'];
    inspectionBy = json['inspectionBy'];
    inspectionResult = json['inspectionResult'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['woCheckSheetHeaderId'] = this.woCheckSheetHeaderId;
    data['documentId'] = this.documentId;
    data['truckId'] = this.truckId;
    data['containerNo'] = this.containerNo;
    data['sealNo'] = this.sealNo;
    data['inspectionBy'] = this.inspectionBy;
    data['inspectionResult'] = this.inspectionResult;
    data['datetime'] = this.datetime;
    return data;
  }
}
