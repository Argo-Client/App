part of main;

int _currentIndex = 0;

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var child = _children[_currentIndex];
    return child["page"];
  }
}
