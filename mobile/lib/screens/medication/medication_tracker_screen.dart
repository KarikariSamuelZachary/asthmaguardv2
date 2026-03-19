import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication.dart';
import 'add_medication_screen.dart';

class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterFrequency = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication Tracker',
          style: TextStyle(
            color: Color(0xFF4285F4), // Blue color
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, medicationProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildStatsHeader(medicationProvider, isDark),
                _buildSearchAndFilters(isDark),
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight -
                      320,
                  child: _buildMedicationsList(medicationProvider, isDark),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
      ),
    );
  }

  Widget _buildStatsHeader(MedicationProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Today's Overview",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4285F4), // Blue color
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                  'Active Medications',
                  provider.medications.where((m) => m.active).length.toString(),
                  Colors.blue,
                  isDark),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Today\'s Doses',
                  _getTodaysDoses(provider.medications).toString(),
                  Colors.orange,
                  isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search medications...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all', _filterStatus, (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active', _filterStatus, (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Inactive', 'inactive', _filterStatus,
                    (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                }),
                const SizedBox(width: 16),
                _buildFilterChip('Daily', 'daily', _filterFrequency, (value) {
                  setState(() {
                    _filterFrequency = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Weekly', 'weekly', _filterFrequency, (value) {
                  setState(() {
                    _filterFrequency = value;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter,
      Function(String) onTap) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(value),
      selectedColor: const Color(0xFF4285F4).withOpacity(0.2),
      checkmarkColor: const Color(0xFF4285F4),
    );
  }

  Widget _buildMedicationsList(MedicationProvider provider, bool isDark) {
    final filteredMedications = _filterMedications(provider.medications);
    if (filteredMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.medications.isEmpty
                  ? 'No medications found'
                  : 'No medications match your filters',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.medications.isEmpty
                  ? 'Add your first medication to get started'
                  : 'Try adjusting your search or filter criteria',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (provider.medications.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMedicationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Medication'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredMedications.length,
      itemBuilder: (context, index) {
        final medication = filteredMedications[index];
        return _buildMedicationCard(medication, provider, isDark);
      },
    );
  }

  Widget _buildMedicationCard(
      Medication medication, MedicationProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '${medication.dosage} • ${medication.frequency}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMedicationScreen(medication: medication),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(medication, provider);
                  }
                },
              ),
            ],
          ),
          if (medication.times.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Times: ${medication.times.join(', ')}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
          if (medication.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${medication.notes}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Medication> _filterMedications(List<Medication> medications) {
    return medications.where((medication) {
      if (_searchQuery.isNotEmpty) {
        if (!medication.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_filterStatus != 'all') {
        if (_filterStatus == 'active' && !medication.active) return false;
        if (_filterStatus == 'inactive' && medication.active) return false;
      }
      if (_filterFrequency != 'all') {
        if (medication.frequency != _filterFrequency) return false;
      }
      return true;
    }).toList();
  }

  int _getTodaysDoses(List<Medication> medications) {
    int totalDoses = 0;
    for (final medication in medications) {
      if (medication.active && medication.frequency == 'daily') {
        totalDoses += medication.times.length;
      }
    }
    return totalDoses;
  }

  void _showDeleteDialog(Medication medication, MedicationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content:
            Text('Are you sure you want to delete \'${medication.name}\'?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement delete logic in provider if needed
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
