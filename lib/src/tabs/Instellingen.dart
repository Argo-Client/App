part of main;

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class _Instellingen extends State<Instellingen> {
  Widget build(BuildContext context) {
    var darkThemeOpt = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Uiterlijk",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        ListTile(
          title: Text('Donker thema'),
          // The Material switch has a platform adaptive constructor.
          trailing: Switch.adaptive(
            value: darkThemeOpt,
            onChanged: (value) {
              setState(() => darkThemeOpt = value);
              DynamicTheme.of(context)
                  .setBrightness(value ? Brightness.dark : Brightness.light);
            },
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Account",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Meldingen",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Meldingen",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }
}
