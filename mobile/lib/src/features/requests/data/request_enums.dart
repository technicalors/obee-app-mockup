enum LeaveTypeEnum {
  unpaid('UNPAID', 'Nghỉ phép không lương'),
  annual('ANNUAL', 'Nghỉ phép tiêu chuẩn'),
  businessTrip('BUSINESS_TRIP', 'Yêu cầu công tác');

  const LeaveTypeEnum(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static LeaveTypeEnum fromWireValue(String value) {
    return LeaveTypeEnum.values.firstWhere(
      (type) => type.wireValue == value,
      orElse: () => LeaveTypeEnum.unpaid,
    );
  }
}

enum AbsenceRequestStatus {
  pending('pending', 'Chờ duyệt'),
  returned('returned', 'Cần điều chỉnh'),
  approved('approved', 'Đã duyệt'),
  rejected('rejected', 'Từ chối');

  const AbsenceRequestStatus(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static AbsenceRequestStatus fromWireValue(String value) {
    return AbsenceRequestStatus.values.firstWhere(
      (status) => status.wireValue == value,
    );
  }
}
