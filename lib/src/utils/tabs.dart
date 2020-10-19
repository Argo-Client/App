part of main;

final List _children = [
  {
    "page": Thuis(),
    "name": Text("Home"),
    "icon": Icon(Icons.home_outlined),
  },
  {
    "page": Agenda(),
    "name": Text("Agenda"),
    "icon": Icon(Icons.event_outlined),
  },
  {
    "page": Huiswerk(),
    "name": Text("Huiswerk"),
    "icon": Icon(Icons.assignment_outlined),
  },
  {
    "name": Text("Afwezigheid"),
    "page": Afwezigheid(),
    "icon": Icon(Icons.check_circle_outlined),
  },
  {
    "name": Text("Cijfers"),
    "icon": Icon(Icons.looks_6_outlined),
    "page": Cijfers(),
  },
  {
    "name": Text("Berichten"),
    "icon": Icon(Icons.email_outlined),
    "page": Berichten(),
  },
  {
    "divider": true,
  },
  {
    "name": Text("Studiewijzer"),
    "icon": Icon(Icons.school_outlined),
    "page": Studiewijzer(),
  },
  {
    "name": Text("Opdrachten"),
    "icon": Icon(Icons.assignment_late_outlined),
    "page": Opdrachten(),
  },
  {
    "name": Text("Leermiddelen"),
    "icon": Icon(Icons.language_outlined),
    "page": Leermiddelen(),
  },
  {
    "name": Text("Bronnen"),
    "icon": Icon(Icons.folder_outlined),
    "page": Bronnen(),
  },
  {
    "divider": true,
  },
  {
    "name": Text("Mijn gegevens"),
    "icon": Icon(Icons.person_outlined),
    "page": MijnGegevens(),
  },
  {
    "name": Text("Instellingen"),
    "icon": Icon(Icons.settings_outlined),
    "page": Instellingen(),
  },
  {
    "name": Text("Over deze app"),
    "icon": Icon(Icons.info_outlined),
    "page": Info(),
  }
];
