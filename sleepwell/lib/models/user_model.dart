class UserModel {
  final String?id;
  final String name ;
  final String Lname ;
  final String email ;
  final String password;
  const UserModel({
    this.id,
    required this.name,
    required this.Lname,
    required this.email,
    required this.password,
  });
  toJson(){
    return{
      "First Name":name ,
      "Last Name":Lname ,
      "Email":email,
      "Password":password ,
    };
  }
}