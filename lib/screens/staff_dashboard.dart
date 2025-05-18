import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotel_staff_app/screens/reclamation_form.dart';
import '../services/reclamation_service.dart';
import 'reclamation.dart';
import '../services/api_service.dart';

class StaffDashboard extends StatefulWidget {
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late Future<List<Reclamation>> _reclamations;
  int _selectedPage = 0;
  String? _userEmail;

  // Filtres
  bool _showNew = true;
  bool _showInProgress = false;
  bool _showDone = false;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _fetchReclamations();
  }

  void _fetchUserEmail() async {
    String? email = await ApiService.obtenirEmailUtilisateurConnecte();
    setState(() {
      _userEmail = email;
    });
  }

  void _fetchReclamations() {
    setState(() {
      _reclamations = ReclamationService.getReclamations();
    });
  }

  Future<void> _takeInCharge(Reclamation r) async {
    await ReclamationService.updateReclamationStatus(r.id, 'In Progress', assignedTo: _userEmail);
    _fetchReclamations();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord - Staff'),
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
              child: Text('Menu Staff', style: TextStyle(fontSize: 24, color: Colors.white)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Toutes les réclamations'),
              selected: _selectedPage == 0,
              onTap: () {
                setState(() => _selectedPage = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mes réclamations'),
              selected: _selectedPage == 1,
              onTap: () {
                setState(() => _selectedPage = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_turned_in),
              title: Text('Prises en charge'),
              selected: _selectedPage == 2,
              onTap: () {
                setState(() => _selectedPage = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Reclamation>>(
        future: _reclamations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: [${snapshot.error}]'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune réclamation.'));
          }
          List<Reclamation> data = snapshot.data!;
          // Filtres selon la page
          if (_selectedPage == 1 && _userEmail != null) {
            data = data.where((r) => r.createdBy == _userEmail).toList();
          } else if (_selectedPage == 2 && _userEmail != null) {
            data = data.where((r) => r.assignedTo == _userEmail).toList();
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final r = data[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(r.objet),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Départements : ${r.departments.join(', ')}'),
                      Text('Priorité : ${r.priority}'),
                      Text('Statut : ${r.status}'),
                      Text('Emplacement : ${r.location}'),
                      Text('Créée le : ${dateFormatter.format(r.createdAt)}'),
                      Text('Créée par : ${r.createdBy}'),
                      Text('Assignée à : ${r.assignedTo}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (r.status == 'New' && (r.assignedTo == null || r.assignedTo == '' || r.assignedTo == 'Non défini'))
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          tooltip: 'Prendre en charge',
                          onPressed: () => _takeInCharge(r),
                        ),
                      // Seul le créateur ou l'assigné peut modifier
                      if (_userEmail != null && (r.createdBy == _userEmail || r.assignedTo == _userEmail))
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // TODO: ouvrir le formulaire de modification
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReclamationForm()),
          ).then((_) => _fetchReclamations());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
