class ListDo {
  int? documentId;
  String? doNumber;
  String? woNumber;
  String? toNumber;
  String? shipmentNo;
  String? shipmentDate;
  int? imageSubWorkTypeId;
  int? workTypeId;
  String? workTypeName;
  String? sapWorkTypeCode;
  String? status;
  String? sealNo;
  String? ticketNo;
  String? deliveryNo;
  String? containerNo;
  int? weightId;
  double? weight;
  String? loadingDate;
  String? idCard;
  String? licensePlate;
  String? driver;
  String? transporterId;
  String? wareHouse;
  double? tareWeight;
  double? netWeight;
  double? grossWeight;
  String? inboundWeightDate;
  String? inboundWeightTime;
  String? inboundWeightBy;
  String? outboundWeightDate;
  String? outboundWeightTime;
  String? outboundWeightBy;
  String? advanceSales;
  String? slocFrom;
  String? slocTo;
  bool? isCompleted;
  String? timeIn;
  String? timeOut;
  String? sapId;
  String? createdBy;
  String? createdOn;
  bool? isDeleted;
  String? modifiedBy;
  String? modifiedOn;

  ListDo(
      {this.documentId,
      this.doNumber,
      this.woNumber,
      this.toNumber,
      this.shipmentNo,
      this.shipmentDate,
      this.imageSubWorkTypeId,
      this.workTypeId,
      this.workTypeName,
      this.sapWorkTypeCode,
      this.status,
      this.sealNo,
      this.ticketNo,
      this.deliveryNo,
      this.containerNo,
      this.weightId,
      this.weight,
      this.loadingDate,
      this.idCard,
      this.licensePlate,
      this.driver,
      this.transporterId,
      this.wareHouse,
      this.tareWeight,
      this.netWeight,
      this.grossWeight,
      this.inboundWeightDate,
      this.inboundWeightTime,
      this.inboundWeightBy,
      this.outboundWeightDate,
      this.outboundWeightTime,
      this.outboundWeightBy,
      this.advanceSales,
      this.slocFrom,
      this.slocTo,
      this.isCompleted,
      this.timeIn,
      this.timeOut,
      this.sapId,
      this.createdBy,
      this.createdOn,
      this.isDeleted,
      this.modifiedBy,
      this.modifiedOn});

  ListDo.fromJson(Map<String, dynamic> json) {
    documentId = json['documentId'];
    doNumber = json['doNumber'];
    woNumber = json['woNumber'];
    toNumber = json['toNumber'];
    shipmentNo = json['shipmentNo'];
    shipmentDate = json['shipmentDate'];
    imageSubWorkTypeId = json['imageSubWorkTypeId'];
    workTypeId = json['workTypeId'];
    workTypeName = json['workTypeName'];
    sapWorkTypeCode = json['sapWorkTypeCode'];
    status = json['status'];
    sealNo = json['sealNo'];
    ticketNo = json['ticketNo'];
    deliveryNo = json['deliveryNo'];
    containerNo = json['containerNo'];
    weightId = json['weightId'];
    weight = json['weight'];
    loadingDate = json['loadingDate'];
    idCard = json['idCard'];
    licensePlate = json['licensePlate'];
    driver = json['driver'];
    transporterId = json['transporterId'];
    wareHouse = json['wareHouse'];
    tareWeight = json['tareWeight'];
    netWeight = json['netWeight'];
    grossWeight = json['grossWeight'];
    inboundWeightDate = json['inboundWeightDate'];
    inboundWeightTime = json['inboundWeightTime'];
    inboundWeightBy = json['inboundWeightBy'];
    outboundWeightDate = json['outboundWeightDate'];
    outboundWeightTime = json['outboundWeightTime'];
    outboundWeightBy = json['outboundWeightBy'];
    advanceSales = json['advanceSales'];
    slocFrom = json['slocFrom'];
    slocTo = json['slocTo'];
    isCompleted = json['isCompleted'];
    timeIn = json['timeIn'];
    timeOut = json['timeOut'];
    sapId = json['sapId'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    isDeleted = json['isDeleted'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['documentId'] = this.documentId;
    data['doNumber'] = this.doNumber;
    data['woNumber'] = this.woNumber;
    data['toNumber'] = this.toNumber;
    data['shipmentNo'] = this.shipmentNo;
    data['shipmentDate'] = this.shipmentDate;
    data['imageSubWorkTypeId'] = this.imageSubWorkTypeId;
    data['workTypeId'] = this.workTypeId;
    data['workTypeName'] = this.workTypeName;
    data['sapWorkTypeCode'] = this.sapWorkTypeCode;
    data['status'] = this.status;
    data['sealNo'] = this.sealNo;
    data['ticketNo'] = this.ticketNo;
    data['deliveryNo'] = this.deliveryNo;
    data['containerNo'] = this.containerNo;
    data['weightId'] = this.weightId;
    data['weight'] = this.weight;
    data['loadingDate'] = this.loadingDate;
    data['idCard'] = this.idCard;
    data['licensePlate'] = this.licensePlate;
    data['driver'] = this.driver;
    data['transporterId'] = this.transporterId;
    data['wareHouse'] = this.wareHouse;
    data['tareWeight'] = this.tareWeight;
    data['netWeight'] = this.netWeight;
    data['grossWeight'] = this.grossWeight;
    data['inboundWeightDate'] = this.inboundWeightDate;
    data['inboundWeightTime'] = this.inboundWeightTime;
    data['inboundWeightBy'] = this.inboundWeightBy;
    data['outboundWeightDate'] = this.outboundWeightDate;
    data['outboundWeightTime'] = this.outboundWeightTime;
    data['outboundWeightBy'] = this.outboundWeightBy;
    data['advanceSales'] = this.advanceSales;
    data['slocFrom'] = this.slocFrom;
    data['slocTo'] = this.slocTo;
    data['isCompleted'] = this.isCompleted;
    data['timeIn'] = this.timeIn;
    data['timeOut'] = this.timeOut;
    data['sapId'] = this.sapId;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['isDeleted'] = this.isDeleted;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}
