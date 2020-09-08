part of main;

var dayOfWeek = 1;
DateTime date = DateTime.now();
var lastMondayUnformat = date.subtract(Duration(days: date.weekday - dayOfWeek));
DateFormat formatter = DateFormat('dd');
String formatted = formatter.format(lastMondayUnformat);
int lastMonday = int.parse(formatted);

class Agenda extends StatefulWidget {
  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

class _Agenda extends State<Agenda> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nextPage(widget.initialPage);
    super.dispose();
  }

  //method to set the page. This method is very important.
  void _nextPage(int tab) {
    final int newTab = _tabController.index + tab;
    if (newTab < 0 || newTab >= _tabController.length) return;
    _tabController.animateTo(newTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        title: Text("Agenda"),
        // bottom: TabBar(
        //   controller: null,
        //   tabs: [
        //     for (int i = lastMonday; i < 7; i++)
        //       Tab(
        //         text: (lastMonday + i).toString(),
        //       )
        //   ],
        // ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text("Yeet"),
      ),
    );
  }
}

// TabBarView(
//       controller: _tabController,
//       children: [
//         Center(child: Text("First Page")),
//         Center(child: Text("Second Page")),
//       ],
//     );
// final AppBar appBar =
