import 'package:flutter/material.dart';
import 'reclamations_tab.dart';
import 'users_tab.dart';

class ManagerDashboard extends StatefulWidget {
  @override
  _ManagerDashboardState createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Réclamations'),
            Tab(text: 'Utilisateurs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReclamationsTab(),
          UsersTab(),
        ],
      ),
    );
  }
}
