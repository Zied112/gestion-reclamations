import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/reclamation_service.dart';
import 'reclamation.dart';
import 'package:intl/intl.dart';

class ManagerStatsDashboard extends StatefulWidget {
  @override
  _ManagerStatsDashboardState createState() => _ManagerStatsDashboardState();
}

class _ManagerStatsDashboardState extends State<ManagerStatsDashboard> {
  late Future<List<Reclamation>> _reclamations;

  @override
  void initState() {
    super.initState();
    _reclamations = ReclamationService.getReclamations();
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
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucune donnée de réclamation.'));
        }
        final data = snapshot.data!;
        // Statistiques par status
        final total = data.length;
        final statusCounts = {
          'New': data.where((r) => r.status == 'New').length,
          'In Progress': data.where((r) => r.status == 'In Progress').length,
          'Done': data.where((r) => r.status == 'Done').length,
        };
        // Stats du mois courant et précédent
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month);
        final lastMonth = DateTime(now.year, now.month - 1);
        int doneThisMonth = data.where((r) => r.status == 'Done' && r.updatedAt.isAfter(thisMonth)).length;
        int doneLastMonth = data.where((r) => r.status == 'Done' && r.updatedAt.isAfter(lastMonth) && r.updatedAt.isBefore(thisMonth)).length;
        double percentChange = doneLastMonth == 0 ? 100 : ((doneThisMonth - doneLastMonth) / doneLastMonth * 100);
        // Idée supplémentaire : nombre moyen de jours pour accomplir une réclamation
        final durations = data.where((r) => r.status == 'Done').map((r) => r.updatedAt.difference(r.createdAt).inDays).toList();
        double avgDays = durations.isNotEmpty ? durations.reduce((a, b) => a + b) / durations.length : 0;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistiques des réclamations', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: statusCounts['New']!.toDouble(),
                            color: Colors.blue,
                            title: 'New\n${((statusCounts['New']!/total)*100).toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: statusCounts['In Progress']!.toDouble(),
                            color: Colors.orange,
                            title: 'In Progress\n${((statusCounts['In Progress']!/total)*100).toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: statusCounts['Done']!.toDouble(),
                            color: Colors.green,
                            title: 'Done\n${((statusCounts['Done']!/total)*100).toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text('Réclamations accomplies ce mois-ci : $doneThisMonth', style: TextStyle(fontSize: 16)),
                Text('Réclamations accomplies le mois dernier : $doneLastMonth', style: TextStyle(fontSize: 16)),
                Text('Évolution : ${percentChange.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16, color: percentChange >= 0 ? Colors.green : Colors.red)),
                SizedBox(height: 16),
                Text('Durée moyenne pour accomplir une réclamation : ${avgDays.toStringAsFixed(1)} jours', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                // Autres idées : top 3 départements les plus sollicités
                Text('Top 3 départements les plus sollicités :', style: TextStyle(fontSize: 16)),
                ..._topDepartments(data, 3).map((e) => Text('${e.key} : ${e.value} réclamations')),
              ],
            ),
          ),
        );
      },
    );
  }

  List<MapEntry<String, int>> _topDepartments(List<Reclamation> data, int topN) {
    final Map<String, int> deptCount = {};
    for (var r in data) {
      for (var dept in r.departments) {
        deptCount[dept] = (deptCount[dept] ?? 0) + 1;
      }
    }
    final sorted = deptCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(topN).toList();
  }
} 