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
      ..name = fields[8] as String
      ..officialFullName = fields[9] as String
      ..phone = fields[10] as String
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
      ..lessons = (fields[22] as Map)?.map((dynamic k, dynamic v) => MapEntry(k as String, (v as List)?.map((dynamic e) => (e as List)?.cast<Les>())?.toList()))
      ..bronnen = (fields[23] as List)?.cast<Bron>()
      ..studiewijzers = (fields[24] as List)?.cast<Wijzer>()
      ..recenteCijfers = (fields[25] as List)?.cast<Cijfer>()
      ..leermiddelen = (fields[26] as List)?.cast<Leermiddel>()
      ..privileges = (fields[27] as List)?.cast<Privilege>();
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(26)
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
      ..writeByte(8)
      ..write(obj.name)
      ..writeByte(9)
      ..write(obj.officialFullName)
      ..writeByte(10)
      ..write(obj.phone)
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
      ..write(obj.lessons)
      ..writeByte(23)
      ..write(obj.bronnen)
      ..writeByte(24)
      ..write(obj.studiewijzers)
      ..writeByte(25)
      ..write(obj.recenteCijfers)
      ..writeByte(26)
      ..write(obj.leermiddelen)
      ..writeByte(27)
      ..write(obj.privileges);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccountAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
      ..vak = fields[9] as Vak
      ..docenten = (fields[10] as List)?.cast<Contact>()
      ..huiswerk = fields[11] as String
      ..information = fields[12] as String
      ..hour = fields[13] as String
      ..huiswerkAf = fields[14] as bool
      ..uitval = fields[15] as bool
      ..editable = fields[16] as bool
      ..lastMonday = fields[17] as DateTime
      ..infoType = fields[18] as String
      ..heleDag = fields[19] as bool
      ..startDateTime = fields[20] as DateTime
      ..onlineLes = fields[21] as bool
      ..heeftBijlagen = fields[22] as bool
      ..bijlagen = (fields[23] as List)?.cast<Bron>()
      ..status5 = fields[24] as bool
      ..aantekening = fields[25] as String;
  }

  @override
  void write(BinaryWriter writer, Les obj) {
    writer
      ..writeByte(26)
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
      ..write(obj.docenten)
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
      ..write(obj.editable)
      ..writeByte(17)
      ..write(obj.lastMonday)
      ..writeByte(18)
      ..write(obj.infoType)
      ..writeByte(19)
      ..write(obj.heleDag)
      ..writeByte(20)
      ..write(obj.startDateTime)
      ..writeByte(21)
      ..write(obj.onlineLes)
      ..writeByte(22)
      ..write(obj.heeftBijlagen)
      ..writeByte(23)
      ..write(obj.bijlagen)
      ..writeByte(24)
      ..write(obj.status5)
      ..writeByte(25)
      ..write(obj.aantekening);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LesAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
  bool operator ==(Object other) => identical(this, other) || other is CijferJaarAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
  bool operator ==(Object other) => identical(this, other) || other is PeriodeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
  bool operator ==(Object other) => identical(this, other) || other is CijferAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
      ..id = fields[1] as int
      ..code = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, Vak obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.naam)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.code);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VakAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
      ..heeftBijlagen = fields[3] as bool
      ..onderwerp = fields[4] as String
      ..afzender = fields[5] as Contact
      ..date = fields[6] as DateTime
      ..read = fields[7] as bool
      ..bijlagen = (fields[8] as List)?.cast<Bron>()
      ..inhoud = fields[9] as String
      ..ontvangers = (fields[10] as List)?.cast<Contact>()
      ..cc = (fields[11] as List)?.cast<Contact>();
  }

  @override
  void write(BinaryWriter writer, Bericht obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.dag)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.prioriteit)
      ..writeByte(3)
      ..write(obj.heeftBijlagen)
      ..writeByte(4)
      ..write(obj.onderwerp)
      ..writeByte(5)
      ..write(obj.afzender)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.read)
      ..writeByte(8)
      ..write(obj.bijlagen)
      ..writeByte(9)
      ..write(obj.inhoud)
      ..writeByte(10)
      ..write(obj.ontvangers)
      ..writeByte(11)
      ..write(obj.cc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BerichtAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
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
      ..date = fields[1] as DateTime
      ..type = fields[2] as String
      ..les = fields[3] as Les
      ..geoorloofd = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, Absentie obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dag)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.les)
      ..writeByte(4)
      ..write(obj.geoorloofd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AbsentieAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class BronAdapter extends TypeAdapter<Bron> {
  @override
  final int typeId = 9;

  @override
  Bron read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bron()
      ..naam = fields[0] as String
      ..id = fields[1] as int
      ..contentType = fields[2] as String
      ..isFolder = fields[3] as bool
      ..children = (fields[4] as List)?.cast<Bron>()
      ..size = fields[5] as int
      ..downloadUrl = fields[6] as String
      ..uri = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, Bron obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.naam)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.contentType)
      ..writeByte(3)
      ..write(obj.isFolder)
      ..writeByte(4)
      ..write(obj.children)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.downloadUrl)
      ..writeByte(7)
      ..write(obj.uri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BronAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class WijzerAdapter extends TypeAdapter<Wijzer> {
  @override
  final int typeId = 10;

  @override
  Wijzer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wijzer()
      ..naam = fields[0] as String
      ..id = fields[1] as int
      ..omschrijving = fields[2] as String
      ..bronnen = (fields[3] as List)?.cast<Bron>()
      ..children = (fields[4] as List)?.cast<Wijzer>()
      ..tabUrl = fields[5] as String
      ..pinned = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, Wijzer obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.naam)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.omschrijving)
      ..writeByte(3)
      ..write(obj.bronnen)
      ..writeByte(4)
      ..write(obj.children)
      ..writeByte(5)
      ..write(obj.tabUrl)
      ..writeByte(6)
      ..write(obj.pinned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WijzerAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class LeermiddelAdapter extends TypeAdapter<Leermiddel> {
  @override
  final int typeId = 11;

  @override
  Leermiddel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leermiddel()
      ..title = fields[0] as String
      ..ean = fields[1] as String
      ..uitgeverij = fields[2] as String
      ..vak = fields[3] as Vak;
  }

  @override
  void write(BinaryWriter writer, Leermiddel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.ean)
      ..writeByte(2)
      ..write(obj.uitgeverij)
      ..writeByte(3)
      ..write(obj.vak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LeermiddelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 15;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact()
      ..naam = fields[0] as String
      ..id = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
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
  bool operator ==(Object other) => identical(this, other) || other is ContactAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class PrivilegeAdapter extends TypeAdapter<Privilege> {
  @override
  final int typeId = 13;

  @override
  Privilege read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Privilege()
      ..naam = fields[0] as String
      ..permissions = (fields[1] as List)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, Privilege obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.naam)
      ..writeByte(1)
      ..write(obj.permissions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PrivilegeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class OpdrachtAdapter extends TypeAdapter<Opdracht> {
  @override
  final int typeId = 14;

  @override
  Opdracht read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Opdracht()
      ..titel = fields[0] as String
      ..vak = fields[1] as String
      ..inleverDatum = fields[2] as DateTime
      ..ingeleverdOp = fields[3] as DateTime
      ..status = fields[4] as String
      ..omschrijving = fields[5] as String
      ..beoordeling = fields[6] as String
      ..beoordeeldOp = fields[7] as String
      ..leerlingBijlage = (fields[8] as List)?.cast<Bron>()
      ..leerlingOpmerking = fields[9] as String
      ..magInleveren = fields[10] as bool
      ..teLaat = fields[11] as bool
      ..docentOpmerking = fields[12] as String
      ..docentBijlage = (fields[13] as List)?.cast<Bron>()
      ..versie = fields[14] as int
      ..id = fields[15] as int;
  }

  @override
  void write(BinaryWriter writer, Opdracht obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.titel)
      ..writeByte(1)
      ..write(obj.vak)
      ..writeByte(2)
      ..write(obj.inleverDatum)
      ..writeByte(3)
      ..write(obj.ingeleverdOp)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.omschrijving)
      ..writeByte(6)
      ..write(obj.beoordeling)
      ..writeByte(7)
      ..write(obj.beoordeeldOp)
      ..writeByte(8)
      ..write(obj.leerlingBijlage)
      ..writeByte(9)
      ..write(obj.leerlingOpmerking)
      ..writeByte(10)
      ..write(obj.magInleveren)
      ..writeByte(11)
      ..write(obj.teLaat)
      ..writeByte(12)
      ..write(obj.docentOpmerking)
      ..writeByte(13)
      ..write(obj.docentBijlage)
      ..writeByte(14)
      ..write(obj.versie)
      ..writeByte(15)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OpdrachtAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
