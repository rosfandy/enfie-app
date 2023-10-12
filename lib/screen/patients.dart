class Patient {
  String name = '';
  String birth = '';
  String address = '';
  int gender = 0;
  int id = 0;

  Patient(this.name, this.birth, this.address, this.gender);

  Patient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    birth = json['birth'];
    address = json['address'];
    gender = json['gender'];
  }
}
