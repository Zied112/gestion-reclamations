import 'package:flutter/material.dart';
import '../services/reclamation_service.dart';
import 'reclamation.dart';

class ReclamationsTab extends StatefulWidget {
  @override
  _ReclamationsTabState createState() => _ReclamationsTabState();
}

class _ReclamationsTabState extends State<ReclamationsTab> {
  late Future<List<Reclamation>> _reclamations;

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

  void _deleteReclamation(String id) async {
    await ReclamationService.deleteReclamation(id);
    _fetchReclamations();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reclamation>>(
      future: _reclamations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: [${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune réclamation.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final r = snapshot.data![index];
            return Card(
              child: ListTile(
                title: Text(r.objet),
                subtitle: Text(r.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implémenter l'édition
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteReclamation(r.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 