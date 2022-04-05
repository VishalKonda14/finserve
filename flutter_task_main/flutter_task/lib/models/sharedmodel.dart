class Details {
  String? email;
  String? phonenumber;
  Details({this.email, this.phonenumber});

  factory Details.fromJson(Map<String, dynamic> parsedJson) {
    return Details(
      email: parsedJson['email'] ?? "",
      phonenumber: parsedJson['phonenumber'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "phonenumber": phonenumber,
    };
  }
}
