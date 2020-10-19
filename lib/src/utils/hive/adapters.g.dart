// GENERATED CODE - DO NOT MODIFY BY HAND

part of adapters;

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 1;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account()
      ..address = fields[0] as String
      ..birthdate = fields[1] as String
      ..email = fields[2] as String
      ..fullName = fields[3] as String
      ..initials = fields[4] as String
      ..klas = fields[5] as String
      ..klasCode = fields[6] as String
      ..mentor = fields[7] as String
      ..name = fields[8] as String
      ..officialFullName = fields[9] as String
      ..phone = fields[10] as String
      ..profiel = fields[11] as String
      ..username = fields[12] as String
      ..tenant = fields[13] as String
      ..accessToken = fields[14] as String
      ..refreshToken = fields[15] as String
      ..expiry = fields[16] as int
      ..id = fields[17] as int
      ..profilePicture = fields[18] as String
      ..afwezigheid = (fields[19] as List)?.cast<Absentie>()
      ..berichten = (fields[20] as List)?.cast<Bericht>()
      ..cijfers = (fields[21] as List)?.cast<CijferJaar>()
      ..lessons = (fields[22] as Map)?.map((dynamic k, dynamic v) => MapEntry(
          k as String,
          (v as List)?.map((dynamic e) => (e as List)?.cast<Les>())?.toList()));
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.birthdate)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.initials)
      ..writeByte(5)
      ..write(obj.klas)
      ..writeByte(6)
      ..write(obj.klasCode)
      ..writeByte(7)
      ..write(obj.mentor)
      ..writeByte(8)
      ..write(obj.name)
      ..writeByte(9)
      ..write(obj.officialFullName)
      ..writeByte(10)
      ..write(obj.phone)
      ..writeByte(11)
      ..write(obj.profiel)
      ..writeByte(12)
      ..write(obj.username)
      ..writeByte(13)
      ..write(obj.tenant)
      ..writeByte(14)
      ..write(obj.accessToken)
      ..writeByte(15)
      ..write(obj.refreshToken)
      ..writeByte(16)
      ..write(obj.expiry)
      ..writeByte(17)
      ..write(obj.id)
      ..writeByte(18)
      ..write(obj.profilePicture)
      ..writeByte(19)
      ..write(obj.afwezigheid)
      ..writeByte(20)
      ..write(obj.berichten)
      ..writeByte(21)
      ..write(obj.cijfers)
      ..writeByte(22)
      ..write(obj.lessons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LesAdapter extends TypeAdapter<Les> {
  @override
  final int typeId = 2;

  @override
  Les read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Les()
      ..start = fields[0] as int
      ..duration = fields[1] as int
      ..id = fields[2] as int
      ..startTime = fields[3] as String
      ..endTime = fields[4] as String
      ..description = fields[5] as String
      ..title = fields[6] as String
      ..location = fields[7] as String
      ..date = fields[8] as String
      ..vak = fields[9] as String
      ..docent = fields[10] as String
      ..huiswerk = fields[11] as String
      ..information = fields[12] as String
      ..hour = fields[13] as String
      ..huiswerkAf = fields[14] as bool
      ..uitval = fields[15] as bool
      ..editable = fields[16] as bool;
  }

  @override
  void write(BinaryWriter writer, Les obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.vak)
      ..writeByte(10)
      ..write(obj.docent)
      ..writeByte(11)
      ..write(obj.huiswerk)
      ..writeByte(12)
      ..write(obj.information)
      ..writeByte(13)
      ..write(obj.hour)
      ..writeByte(14)
      ..write(obj.huiswerkAf)
      ..writeByte(15)
      ..write(obj.uitval)
      ..writeByte(16)
      ..write(obj.editable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CijferJaarAdapter extends TypeAdapter<CijferJaar> {
  @override
  final int typeId = 3;

  @override
  CijferJaar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CijferJaar()
      ..id = fields[0] as int
      ..eind = fields[1] as String
      ..leerjaar = fields[2] as String
      ..cijfers = (fields[3] as List)?.cast<Cijfer>()
      ..perioden = (fields[4] as List)?.cast<Periode>();
  }

  @override
  void write(BinaryWriter writer, CijferJaar obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eind)
      ..writeByte(2)
      ..write(obj.leerjaar)
      ..writeByte(3)
      ..write(obj.cijfers)
      ..writeByte(4)
      ..write(obj.perioden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CijferJaarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PeriodeAdapter extends TypeAdapter<Periode> {
  @override
  final int typeId = 4;

  @override
  Periode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Periode()
      ..abbr = fields[0] as String
      ..naam = fields[1] as String
      ..id = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, Periode obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.abbr)
      ..writeByte(1)
      ..write(obj.naam)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CijferAdapter extends TypeAdapter<Cijfer> {
  @override
  final int typeId = 5;

  @override
  Cijfer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cijfer()
      ..ingevoerd = fields[0] as DateTime
      ..cijfer = fields[1] as String
      ..vak = fields[2] as Vak
      ..periode = fields[3] as Periode
      ..kolomId = fields[4] as int
      ..title = fields[5] as String
      ..id = fields[6] as int
      ..voldoende = fields[7] as bool
      ..weging = fields[8] as double;
  }

  @override
  void write(BinaryWriter writer, Cijfer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.ingevoerd)
      ..writeByte(1)
      ..write(obj.cijfer)
      ..writeByte(2)
      ..write(obj.vak)
      ..writeByte(3)
      ..write(obj.periode)
      ..writeByte(4)
      ..write(obj.kolomId)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.voldoende)
      ..writeByte(8)
      ..write(obj.weging);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CijferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VakAdapter extends TypeAdapter<Vak> {
  @override
  final int typeId = 6;

  @override
  Vak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vak()
      ..naam = fields[0] as String
      ..id = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, Vak obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.naam)
      ..writeByte(1)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BerichtAdapter extends TypeAdapter<Bericht> {
  @override
  final int typeId = 7;

  @override
  Bericht read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bericht()
      ..dag = fields[0] as String
      ..id = fields[1] as int
      ..prioriteit = fields[2] as bool
      ..bijlagen = fields[3] as bool
      ..onderwerp = fields[4] as String
      ..afzender = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, Bericht obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dag)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.prioriteit)
      ..writeByte(3)
      ..write(obj.bijlagen)
      ..writeByte(4)
      ..write(obj.onderwerp)
      ..writeByte(5)
      ..write(obj.afzender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BerichtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AbsentieAdapter extends TypeAdapter<Absentie> {
  @override
  final int typeId = 8;

  @override
  Absentie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Absentie()
      ..dag = fields[0] as String
      ..type = fields[1] as String
      ..les = fields[2] as Les
      ..geoorloofd = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, Absentie obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dag)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.les)
      ..writeByte(3)
      ..write(obj.geoorloofd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbsentieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
