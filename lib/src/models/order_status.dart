enum customOrderStatus{
  Published,
  WaitingForAgree,
  Assigned,
  Preparing,
  Ready,
  OnTheWay,
  Delivered,
  Received,
  Canceled,
}
class OrderStatus {
  String id;
  String status;

  OrderStatus({this.status,this.id});

  OrderStatus.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      status = jsonMap['status'] != null ? jsonMap['status']:'غير معروف';
    } catch (e) {
      id = '';
      status = '';
      print(e);
    }
  }
  Map toMap(){
    var map = Map<String,dynamic>();
    map['id'] = this.id;
    map['status'] = this.status;
    return map;
  }

}
