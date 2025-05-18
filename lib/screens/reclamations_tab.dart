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
    await ReclamationService.deleteReclamation(id, context);
    _fetchReclamations();
  }

  void _showReclamationForm({Reclamation? reclamation}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ReclamationFormDialog(reclamation: reclamation),
    );
    if (result == true) _fetchReclamations();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<Reclamation>>(
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
                          onPressed: () => _showReclamationForm(reclamation: r),
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
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showReclamationForm(),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class ReclamationFormDialog extends StatefulWidget {
  final Reclamation? reclamation;
  ReclamationFormDialog({this.reclamation});

  @override
  _ReclamationFormDialogState createState() => _ReclamationFormDialogState();
}

class _ReclamationFormDialogState extends State<ReclamationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _objetController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  List<String> _departments = [];
  int _priority = 1;
  String _status = 'New';
  final List<String> _availableDepartments = ['HR', 'IT', 'Maintenance', 'Admin'];
  final List<int> _priorityOptions = [1, 2, 3];
  final List<String> _statusOptions = ['New', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _objetController = TextEditingController(text: widget.reclamation?.objet ?? '');
    _descriptionController = TextEditingController(text: widget.reclamation?.description ?? '');
    _locationController = TextEditingController(text: widget.reclamation?.location ?? '');
    _departments = widget.reclamation?.departments ?? [];
    _priority = widget.reclamation?.priority ?? 1;
    _status = widget.reclamation?.status ?? 'New';
  }

  @override
  void dispose() {
    _objetController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final reclamationData = Reclamation(
      id: widget.reclamation?.id ?? '',
      objet: _objetController.text,
      description: _descriptionController.text,
      departments: _departments,
      priority: _priority,
      status: _status,
      location: _locationController.text,
      createdAt: widget.reclamation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.reclamation?.createdBy ?? '',
      assignedTo: widget.reclamation?.assignedTo ?? '',
    );
    try {
      if (widget.reclamation == null) {
        await ReclamationService.createReclamation(reclamationData, context);
      } else {
        await ReclamationService.updateReclamation(reclamationData, context);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      // L'erreur est déjà affichée par le service
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reclamation == null ? 'Ajouter une réclamation' : 'Modifier réclamation'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _objetController,
                decoration: InputDecoration(labelText: 'Objet'),
                validator: (v) => v == null || v.isEmpty ? 'Objet requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Emplacement'),
                validator: (v) => v == null || v.isEmpty ? 'Emplacement requis' : null,
              ),
              // Départements
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Départements (sélectionner au moins un)'),
                  ..._availableDepartments.map((dept) {
                    return CheckboxListTile(
                      title: Text(dept),
                      value: _departments.contains(dept),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _departments.add(dept);
                          } else {
                            _departments.remove(dept);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Priorité'),
                items: _priorityOptions.map((priority) {
                  return DropdownMenuItem<int>(value: priority, child: Text(priority.toString()));
                }).toList(),
                onChanged: (value) => setState(() => _priority = value!),
                validator: (value) => value == null ? 'La priorité est requise' : null,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Statut'),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<String>(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
                validator: (value) => value == null ? 'Le statut est requis' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.reclamation == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    );
  }
} 