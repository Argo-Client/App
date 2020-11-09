part of main;

final List _children = [
  {
    "page": Thuis(),
    "name": Text("Home"),
    "icon": Icons.home_outlined,
    "color": Colors.orange,
  },
  {
    "page": Agenda(),
    "name": Text("Agenda"),
    "icon": Icons.event_outlined,
    "color": Colors.blue,
  },
  {
    "page": Huiswerk(),
    "name": Text("Huiswerk"),
    "icon": Icons.assignment_outlined,
    "color": Colors.green[600],
  },
  {
    "name": Text("Afwezigheid"),
    "page": Afwezigheid(),
    "icon": Icons.check_circle_outlined,
    "color": Colors.redAccent,
  },
  {
    "name": Text("Cijfers"),
    "icon": Icons.looks_6_outlined,
    "page": Cijfers(),
    "color": Colors.cyan[800],
  },
  {
    "name": Text("Berichten"),
    "icon": Icons.email_outlined,
    "page": Berichten(),
    "color": Colors.purple,
  },
  {
    "divider": true,
  },
  {
    "name": Text("Studiewijzers"),
    "icon": Icons.school_outlined,
    "page": Studiewijzers(),
    "overridePop": true,
    "color": Colors.amber,
  },
  {
    "name": Text("Opdrachten"),
    "icon": Icons.assignment_late_outlined,
    "page": Opdrachten(),
    "color": Colors.grey,
  },
  {
    "name": Text("Leermiddelen"),
    "icon": Icons.language_outlined,
    "page": Leermiddelen(),
    "color": Colors.cyan,
  },
  {
    "name": Text("Bronnen"),
    "icon": Icons.folder_outlined,
    "page": Bronnen(),
    "overridePop": true,
    "color": Colors.indigo[200],
  },
  {
    "divider": true,
  },
  {
    "name": Text("Mijn gegevens"),
    "icon": Icons.person_outlined,
    "page": MijnGegevens(),
    "color": Colors.pink[200],
  },
  {
    "name": Text("Instellingen"),
    "icon": Icons.settings_outlined,
    "page": Instellingen(),
    "color": Colors.blue[200],
  },
  {
    "name": Text("Over deze app"),
    "icon": Icons.info_outlined,
    "page": Info(),
    "color": Colors.lime[700],
  }
];
