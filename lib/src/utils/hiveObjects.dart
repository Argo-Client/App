import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  String address, birthdate, email, fullName, initials, klas, klasCode, mentor, name, officialFullName, phone, profiel, username, accessToken, refreshToken;
  int expiry, id;
  Account() {
    this.address = "";
    this.birthdate = "";
    this.email = "";
    this.fullName = "";
    this.id = 0;
    this.initials = "";
    this.klas = "";
    this.klasCode = "";
    this.mentor = "";
    this.name = "";
    this.officialFullName = "";
    this.phone = "-";
    this.profiel = "";
    this.username = "";
    this.accessToken = "";
    this.refreshToken = "";
    this.expiry = 8640000000000000;
  }
  String toString() => this.fullName;
  Account.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      address = json["address"];
      birthdate = json["birthdate"];
      email = json["email"];
      fullName = json["fullName"];
      id = json["id"];
      initials = json["initials"];
      klas = json["klas"];
      klasCode = json["klasCode"];
      mentor = json["mentor"];
      name = json["name"];
      officialFullName = json["officialFullName"];
      phone = json["phone"];
      profiel = json["profiel"];
      username = json["username"];
      expiry = json["expiry"];
      accessToken = json["accessToken"];
      refreshToken = json["refreshToken"];
    } else {
      print('in else Account from json');
      // name = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = address;
    data["birthdate"] = birthdate;
    data["email"] = email;
    data["fullName"] = fullName;
    data["id"] = id;
    data["initials"] = initials;
    data["klas"] = klas;
    data["klasCode"] = klasCode;
    data["mentor"] = mentor;
    data["name"] = name;
    data["officialFullName"] = officialFullName;
    data["phone"] = phone;
    data["profiel"] = profiel;
    data["username"] = username;
    data["expiry"] = expiry;
    data["accessToken"] = accessToken;
    data["refreshToken"] = refreshToken;
    return data;
  }
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final typeId = 2;

  @override
  Account read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account()
      ..address = fields[0] as String
      ..birthdate = fields[1] as String
      ..email = fields[2] as String
      ..fullName = fields[3] as String
      ..id = fields[4] as int
      ..initials = fields[5] as String
      ..klas = fields[6] as String
      ..klasCode = fields[7] as String
      ..mentor = fields[8] as String
      ..name = fields[9] as String
      ..officialFullName = fields[10] as String
      ..phone = fields[11] as String
      ..profiel = fields[12] as String
      ..username = fields[13] as String
      ..expiry = fields[14] as int
      ..accessToken = fields[15] as String
      ..refreshToken = fields[16] as String;
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.birthdate)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.initials)
      ..writeByte(6)
      ..write(obj.klas)
      ..writeByte(7)
      ..write(obj.klasCode)
      ..writeByte(8)
      ..write(obj.mentor)
      ..writeByte(9)
      ..write(obj.name)
      ..writeByte(10)
      ..write(obj.officialFullName)
      ..writeByte(11)
      ..write(obj.phone)
      ..writeByte(12)
      ..write(obj.profiel)
      ..writeByte(13)
      ..write(obj.username)
      ..writeByte(14)
      ..write(obj.expiry)
      ..writeByte(15)
      ..write(obj.accessToken)
      ..writeByte(16)
      ..write(obj.refreshToken);
  }
}

class MaterialColorAdapter extends TypeAdapter<MaterialColor> {
  @override
  final typeId = 3;

  @override
  MaterialColor read(BinaryReader reader) => MaterialColor(reader.readInt(), {});

  @override
  void write(BinaryWriter writer, MaterialColor obj) => writer.writeInt(obj.value);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final typeId = 4;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color obj) => writer.writeInt(obj.value);
}

// Icon(IconData(userdata.get("userIcon"), fontFamily: "MaterialIcons");
class IconAdapter extends TypeAdapter<IconData> {
  @override
  final typeId = 5;

  @override
  IconData read(BinaryReader reader) => IconData(reader.readInt(), fontFamily: "MaterialIcons");

  @override
  void write(BinaryWriter writer, IconData obj) => writer.writeInt(obj.codePoint);
}
