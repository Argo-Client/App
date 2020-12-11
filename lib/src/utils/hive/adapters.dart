library adapters;

import 'package:Argo/src/utils/magister/magister.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Argo/main.dart';
part 'adapters.g.dart';

extension StringExtension on String {
  String get cap => "${this[0].toUpperCase()}${this.substring(1)}";
}

DateFormat formatDatum = DateFormat("EEEE dd MMMM");
DateFormat formatDate = DateFormat("yyyy-MM-dd");

@HiveType(typeId: 1)
class Account extends HiveObject {
  @HiveField(0)
  String address;
  @HiveField(1)
  String birthdate;
  @HiveField(2)
  String email;
  @HiveField(3)
  String fullName;
  @HiveField(4)
  String initials;
  @HiveField(5)
  String klas;
  @HiveField(6)
  String klasCode;
  // 7 Was mentor
  @HiveField(8)
  String name;
  @HiveField(9)
  String officialFullName;
  @HiveField(10)
  String phone;
  @HiveField(11)
  String profiel;
  @HiveField(12)
  String username;
  @HiveField(13)
  String tenant;

  @HiveField(14)
  String accessToken;
  @HiveField(15)
  String refreshToken;

  @HiveField(16)
  int expiry;
  @HiveField(17)
  int id;

  @HiveField(18)
  String profilePicture;

  @HiveField(19)
  List<Absentie> afwezigheid;
  @HiveField(20)
  List<Bericht> berichten;
  @HiveField(21)
  List<CijferJaar> cijfers;
  @HiveField(22)
  Map<String, List<List<Les>>> lessons;
  @HiveField(23)
  List<Bron> bronnen;
  @HiveField(24)
  List<Wijzer> studiewijzers;
  @HiveField(25)
  List<Cijfer> recenteCijfers;
  @HiveField(26)
  List<Leermiddel> leermiddelen;
  Magister magister;
  Account([Map tokenSet]) {
    this.magister = Magister(this);
    if (tokenSet != null) {
      this.accessToken = tokenSet["access_token"];
      this.refreshToken = tokenSet["refresh_token"];
    }

    // this.address = "";
    // this.birthdate = "";
    // this.email = "";
    // this.fullName = "";
    this.id = 0;
    // this.initials = "";
    // this.klas = "";
    // this.klasCode = "";
    // this.name = "";
    // this.officialFullName = "";
    // this.phone = "-";
    // this.profiel = "";
    this.username = "Unset";
    this.accessToken = tokenSet != null ? tokenSet["access_token"] : "";
    this.refreshToken = tokenSet != null ? tokenSet["refresh_token"] : "";
    // this.tenant = "";
    // this.expiry = 8640000000000000;
    // this.afwezigheid = <Absentie>[];
    // this.berichten = <Bericht>[];
    // this.cijfers = <CijferJaar>[];
    // this.recenteCijfers = <Cijfer>[];
    // this.studiewijzers = <Wijzer>[];
    // this.leermiddelen = <Leermiddel>[];
    this.lessons = {}.cast<String, List<List<Les>>>();
  }
  void saveTokens(tokenSet) {
    this.accessToken = tokenSet["access_token"];
    this.refreshToken = tokenSet["refresh_token"];
    if (this.isInBox) this.save();
  }

  String toString() => this.fullName;
}

@HiveType(typeId: 2)
class Les {
  @HiveField(0)
  int start;
  @HiveField(1)
  int duration;
  @HiveField(2)
  int id;
  @HiveField(3)
  String startTime;
  @HiveField(4)
  String endTime;
  @HiveField(5)
  String description;
  @HiveField(6)
  String title;
  @HiveField(7)
  String location;
  @HiveField(8)
  String date;
  @HiveField(9)
  Vak vak;
  @HiveField(10)
  List<Docent> docenten;
  @HiveField(11)
  String huiswerk;
  @HiveField(12)
  String information;
  @HiveField(13)
  String hour;
  @HiveField(14)
  bool huiswerkAf;
  @HiveField(15)
  bool uitval;
  @HiveField(16)
  bool editable;
  @HiveField(17)
  DateTime lastMonday;
  @HiveField(18)
  String infoType;
  @HiveField(19)
  bool heleDag;
  @HiveField(20)
  DateTime startDateTime;
  @HiveField(21)
  bool onlineLes;
  @HiveField(22)
  bool heeftBijlagen;
  @HiveField(23)
  List<Bron> bijlagen;

  Les([Map les]) {
    if (les == null) return;
    DateTime start = DateTime.parse(les["Start"]).toLocal();
    DateTime end = DateTime.parse(les["Einde"]).toLocal();
    int startHour = les['LesuurVan'];
    int endHour = les["LesuurTotMet"];

    DateFormat formatHour = DateFormat("HH:mm");
    DateFormat formatDatum = DateFormat("EEEE dd MMMM");
    int minFromMidnight = start.difference(DateTime(start.year, start.month, start.day)).inMinutes;
    var hour = (startHour == endHour ? startHour.toString() : '$startHour - $endHour');
    this.start = minFromMidnight ?? "";
    this.duration = end.difference(start).inMinutes ?? "";
    this.hour = hour == "null" ? "" : hour;
    this.startTime = formatHour.format(start);
    this.endTime = formatHour.format(end);
    this.description = les["Inhoud"] ?? "";
    this.title = les["Omschrijving"] ?? "";
    this.location = les["Lokatie"];
    this.date = formatDatum.format(start);
    this.vak = les["Vakken"].isEmpty ? Vak({"Omschrijving": les["Omschrijving"]}) : Vak(les["Vakken"][0]);
    this.docenten = les["Docenten"] != null && les["Docenten"].isNotEmpty ? les["Docenten"].map((doc) => Docent(doc)).toList().cast<Docent>() : null;
    this.huiswerk = les["Inhoud"];
    this.huiswerkAf = les["Afgerond"];
    this.startDateTime = start;
    this.heleDag = les["DuurtHeleDag"];
    this.uitval = [4, 5].contains(les["Status"]);
    this.information = (!["", null].contains(les["Lokatie"]) ? les["Lokatie"] + " • " : "") + formatHour.format(start) + " - " + formatHour.format(end) + (les["Inhoud"] != null ? " • " + les["Inhoud"].replaceAll(RegExp("<[^>]*>"), "") : "");
    this.editable = les["Type"] == 1;
    this.id = les["Id"];
    this.infoType = [
      "", // Geen Informatie
      "", // Huiswerk
      "PW", // Toets
      "TT", // Tentamen
      "SO", // Schriftelijke Overhoring
      "", // Informatie
      "", // Aantekening
    ][les["InfoType"]];
    this.onlineLes = les["IsOnlineDeelname"];
    this.lastMonday = start.subtract(
      Duration(
        days: start.weekday - 1,
      ),
    );
    this.heeftBijlagen = les["HeeftBijlagen"];
    if (les["Bijlagen"] != null) {
      this.bijlagen = les["Bijlagen"].map((bij) => Bron(bij)).toList().cast<Bron>();
    }
    if (custom.containsKey("vak${this.vak.id}")) {
      if (custom.get("vak${this.vak.id}").toLowerCase() == "uitval") {
        this.uitval = true;
      } else {
        this.title = custom.get("vak${this.vak.id}");
      }
    }
  }
}

@HiveType(typeId: 3)
class CijferJaar {
  @HiveField(0)
  int id;
  @HiveField(1)
  String eind;
  @HiveField(2)
  String leerjaar;
  @HiveField(3)
  List<Cijfer> cijfers;
  @HiveField(4)
  List<Periode> perioden;
  CijferJaar([jaar]) {
    if (jaar != null) {
      this.id = jaar["id"];
      this.eind = jaar["einde"];
      this.leerjaar = jaar["studie"]["code"];
    }
    this.cijfers = [];
    this.perioden = [];
  }
}

@HiveType(typeId: 4)
class Periode {
  @HiveField(0)
  String abbr;
  @HiveField(1)
  String naam;
  @HiveField(2)
  int id;
  Periode([Map per]) {
    if (per != null) {
      this.abbr = per["Naam"];
      this.naam = per["Omschrijving"];
      this.id = per["Id"];
    }
  }
}

@HiveType(typeId: 5)
class Cijfer {
  @HiveField(0)
  DateTime ingevoerd;
  @HiveField(1)
  String cijfer;
  @HiveField(2)
  Vak vak;
  @HiveField(3)
  Periode periode;
  @HiveField(4)
  int kolomId;
  @HiveField(5)
  String title;
  @HiveField(6)
  int id;
  @HiveField(7)
  bool voldoende;
  @HiveField(8)
  double weging;
  Cijfer([Map cijfer]) {
    if (cijfer != null) {
      if (cijfer["waarde"] == null) {
        // Als je recente cijfers opvraagt krijg je deze zooi net even wat anders dan je zou hopen
        this.ingevoerd = DateTime.parse(cijfer["DatumIngevoerd"] ?? "1970-01-01T00:00:00.0000000Z");
        this.cijfer = cijfer["CijferStr"];
        this.periode = Periode(cijfer["CijferPeriode"]);
        this.vak = Vak(cijfer["Vak"]);
        this.id = cijfer["Id"];
        this.voldoende = cijfer["IsVoldoende"];
        this.kolomId = cijfer["CijferKolom"]["Id"];
      } else {
        this.ingevoerd = DateTime.parse(cijfer["ingevoerdOp"] ?? "1970-01-01T00:00:00.0000000Z");
        this.cijfer = cijfer["waarde"];
        this.title = cijfer["omschrijving"];
        this.vak = Vak(cijfer["vak"]);
        this.voldoende = cijfer["isVoldoende"];
        this.weging = cijfer["weegfactor"];
      }
    }
  }
}

@HiveType(typeId: 6)
class Vak {
  String toString() => this.naam;
  @HiveField(0)
  String naam;
  @HiveField(1)
  int id;
  @HiveField(2)
  String code;
  Vak([vak]) {
    if (vak != null) {
      this.code = vak["Afkorting"];
      this.id = vak["Id"];
      this.naam = ((vak["Omschrijving"] ?? vak["omschrijving"] ?? vak["Naam"] ?? "leeg") as String).cap;
    }
  }
}

@HiveType(typeId: 7)
class Bericht {
  @HiveField(0)
  String dag;
  @HiveField(1)
  int id;
  @HiveField(2)
  bool prioriteit;
  @HiveField(3)
  bool heeftBijlagen;
  @HiveField(4)
  String onderwerp;
  @HiveField(5)
  String afzender;
  @HiveField(6)
  DateTime date;
  @HiveField(7)
  bool read;

  // Specifiek ophalen:
  @HiveField(8)
  List<Bron> bijlagen;
  @HiveField(9)
  String inhoud;
  @HiveField(10)
  List<String> ontvangers;
  @HiveField(11)
  List<String> cc;

  Bericht([Map ber]) {
    if (ber != null) {
      this.date = DateTime.parse(ber["verzondenOp"]);
      this.dag = formatDatum.format(this.date);
      this.id = ber["id"];
      this.prioriteit = ber["heeftPrioriteit"];
      this.heeftBijlagen = ber["heeftBijlagen"];
      this.onderwerp = ber["onderwerp"];
      this.afzender = ber["afzender"]["naam"];
      this.read = ber["isGelezen"];

      if (ber["inhoud"] != null) {
        this.inhoud = ber["inhoud"];
        this.ontvangers = ber["ontvangers"].map((ont) => ont["weergavenaam"]).toList().cast<String>();
        this.cc = ber["kopieOntvangers"].isEmpty ? null : ber["kopieOntvangers"].map((ont) => ont["weergavenaam"]).toList().cast<String>();
      }
    }
  }
}

@HiveType(typeId: 8)
class Absentie {
  @HiveField(0)
  String dag;
  @HiveField(1)
  DateTime date;
  @HiveField(2)
  String type;
  @HiveField(3)
  Les les;
  @HiveField(4)
  bool geoorloofd;
  Absentie([Map afw]) {
    if (afw != null) {
      this.dag = formatDatum.format(DateTime.parse(afw["Afspraak"]["Einde"]));
      this.date = DateTime.parse(afw["Afspraak"]["Einde"]);
      this.type = afw["Omschrijving"];
      this.les = Les(afw["Afspraak"]);
      this.geoorloofd = afw["Geoorloofd"];
    }
  }
}

@HiveType(typeId: 9)
class Bron {
  @HiveField(0)
  String naam;
  @HiveField(1)
  int id;
  @HiveField(2)
  String contentType;
  @HiveField(3)
  bool isFolder;
  @HiveField(4)
  List<Bron> children;
  @HiveField(5)
  int size;
  @HiveField(6)
  String downloadUrl;
  @HiveField(7)
  String uri;
  int downloadCount;
  Bron([Map bron]) {
    if (bron != null) {
      this.naam = bron["Naam"] ?? bron["naam"];
      this.id = bron["Id"] ?? bron["id"];
      this.contentType = bron["ContentType"];
      this.isFolder = bron["BronSoort"] == 0;
      this.size = bron["Grootte"] ?? bron["grootte"];
      this.uri = bron["Uri"];
      if (bron["Links"] != null) {
        List downloadLink = bron["Links"].where((a) => a["Rel"] == "Contents").toList();
        if (downloadLink.isNotEmpty) {
          this.downloadUrl = downloadLink.first["Href"];
        }
      } else if (bron["links"] != null) {
        // Bijlage in berichten
        this.downloadUrl = bron["links"]["download"]["href"];
      }
    }
  }
}

@HiveType(typeId: 10)
class Wijzer {
  @HiveField(0)
  String naam;
  @HiveField(1)
  int id;
  @HiveField(2)
  String omschrijving;
  @HiveField(3)
  List<Bron> bronnen;
  @HiveField(4)
  List<Wijzer> children;
  @HiveField(5)
  String tabUrl;
  Wijzer([wijzer]) {
    if (wijzer != null) {
      this.naam = wijzer["Titel"];
      this.id = wijzer["Id"];
      this.omschrijving = wijzer["Omschrijving"];
      if (wijzer["Links"] != null) {
        this.tabUrl = wijzer["Links"].where((a) => a["Rel"] == "Self").first["Href"];
      }
      if (wijzer["Bronnen"] != null) {
        this.bronnen = wijzer["Bronnen"].map((bron) => Bron(bron)).toList().cast<Bron>();
      }
    }
  }
}

@HiveType(typeId: 11)
class Leermiddel {
  @HiveField(0)
  String title;
  @HiveField(1)
  String ean;
  @HiveField(2)
  String uitgeverij;
  @HiveField(3)
  Vak vak;
  Leermiddel([leermiddel]) {
    if (leermiddel != null) {
      this.uitgeverij = leermiddel["Uitgeverij"];
      this.vak = Vak(leermiddel["Vak"]);
      this.title = leermiddel["Titel"];
      this.ean = leermiddel["EAN"];
    }
  }
}

@HiveType(typeId: 12)
class Docent {
  @HiveField(0)
  String naam;
  @HiveField(1)
  String code;
  Docent([docent]) {
    if (docent != null) {
      this.naam = docent["Naam"];
      this.code = docent["Docentcode"];
    }
  }

  String toString() => this.naam;
}

class MaterialColorAdapter extends TypeAdapter<MaterialColor> {
  @override
  final typeId = 100;

  @override
  MaterialColor read(BinaryReader reader) => MaterialColor(reader.readInt(), {});

  @override
  void write(BinaryWriter writer, MaterialColor obj) => writer.writeInt(obj.value);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final typeId = 101;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color obj) => writer.writeInt(obj.value);
}
