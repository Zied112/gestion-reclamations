import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotel_staff_app/screens/reclamation_form.dart';
import '../services/reclamation_service.dart';
import 'reclamation.dart';

class StaffDashboard extends StatefulWidget {
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late Future<List<Reclamation>> _reclamations;
  bool _sortByDateDesc = true;
  bool _sortByPriorityDesc = true;
  String userDepartment = 'IT'; // Remplace ceci par la logique pour récupérer le département de l'utilisateur

  // États des filtres
  bool _showNew = true;
  bool _showInProgress = false;
  bool _showDone = false;

  @override
  void initState() {
    super.initState();
    _fetchReclamations();
  }

  void _fetchReclamations() {
    setState(() {
      _reclamations = ReclamationService.getReclamations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('Tableau de bord - Staff')),
      body: Column(
        children: [
          // Section de filtres
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text('New'),
                        value: _showNew,
                        onChanged: (val) {
                          setState(() {
                            _showNew = val!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: Text('In Progress'),
                        value: _showInProgress,
                        onChanged: (val) {
                          setState(() {
                            _showInProgress = val!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: Text('Done'),
                        value: _showDone,
                        onChanged: (val) {
                          setState(() {
                            _showDone = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _sortByPriorityDesc = !_sortByPriorityDesc;
                        });
                      },
                      icon: Icon(_sortByPriorityDesc ? Icons.arrow_downward : Icons.arrow_upward),
                      label: Text('Priorité'),
                    ),
                    SizedBox(width: 20),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _sortByDateDesc = !_sortByDateDesc;
                        });
                      },
                      icon: Icon(_sortByDateDesc ? Icons.arrow_downward : Icons.arrow_upward),
                      label: Text('Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Reclamation>>(
              future: _reclamations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune réclamation en cours.'));
                }

                // Filtrer les réclamations en fonction du statut et du département
                List<Reclamation> filtered = snapshot.data!
                    .where((r) =>
                (_showNew && r.status == 'New') ||
                    (_showInProgress && r.status == 'In Progress') ||
                    (_showDone && r.status == 'Done'))
                    .where((r) => r.departments.contains(userDepartment))
                    .toList();

                filtered.sort((a, b) {
                  int dateCompare = _sortByDateDesc
                      ? b.createdAt.compareTo(a.createdAt)
                      : a.createdAt.compareTo(b.createdAt);

                  int priorityCompare = _sortByPriorityDesc
                      ? b.priority.compareTo(a.priority)
                      : a.priority.compareTo(b.priority);

                  // Tri selon la priorité ou la date
                  return priorityCompare; // ou dateCompare selon le critère choisi
                });

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
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
                            Text('Créée par : ${r.createdBy}'), // Affichage de l'email de l'utilisateur
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
