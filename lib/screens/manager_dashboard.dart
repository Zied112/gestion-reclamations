import 'package:flutter/material.dart';
import 'reclamations_tab.dart';
import 'users_tab.dart';
import 'manager_stats_dashboard.dart';

class ManagerDashboard extends StatefulWidget {
  @override
  _ManagerDashboardState createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> with SingleTickerProviderStateMixin {
  int _selectedPage = 0;
  final List<String> _pageTitles = [
    'Dashboard',
    'Réclamations',
    'Utilisateurs',
  ];

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_selectedPage) {
      case 0:
        body = ManagerStatsDashboard();
        break;
      case 1:
        body = ReclamationsTab();
        break;
      case 2:
        body = UsersTab();
        break;
      default:
        body = ManagerStatsDashboard();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedPage]),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu Manager', style: TextStyle(fontSize: 24, color: Colors.white)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: _selectedPage == 0,
              onTap: () {
                setState(() => _selectedPage = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Réclamations'),
              selected: _selectedPage == 1,
              onTap: () {
                setState(() => _selectedPage = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Utilisateurs'),
              selected: _selectedPage == 2,
              onTap: () {
                setState(() => _selectedPage = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
