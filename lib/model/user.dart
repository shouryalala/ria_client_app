class User{
  final String mobile;
  final String name;
  final String email;
  final int bhk;
  final String flat_no;
  final String society_id;
  final int sector;
  final String district;
  final String society_name;
  final String client_token;

  const User({this.mobile, this.name, this.email, this.bhk, this.flat_no,
      this.society_id, this.sector, this.district, this.society_name,
      this.client_token,});

  User.fromMap(Map<String, dynamic> data, String id)
      : this(
    mobile: id,
    name: data['mName'],
    email: data['mEmail'],
    bhk: data['mEmail'],
    flat_no: data['mFlatNo'],
    society_id: data['mSocietyID'],
    sector: data['mSector'],
    district: data['mDistrict'],
    society_name: null,   //not available in the object
    client_token: data['mClientToken'],
  );
}