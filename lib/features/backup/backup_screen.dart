import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/backup_service.dart';

/// Backup Screen mit Export/Import
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  List<BackupMetadata> _backups = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isImporting = false;
  double _progress = 0;
  String _progressStep = '';

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final service = ref.read(backupServiceProvider);
    final backups = await service.listAvailableBackups();
    setState(() {
      _backups = backups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Wiederherstellung'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warnung
                      _buildWarningCard(),
                      const SizedBox(height: 20),
                      
                      // Backup erstellen
                      _buildCreateBackupCard(),
                      const SizedBox(height: 20),
                      
                      // Import
                      _buildImportCard(),
                      const SizedBox(height: 20),
                      
                      // Verfügbare Backups
                      _buildBackupsList(),
                    ],
                  ),
                ),
                
                // Progress Overlay
                if (_isCreating || _isImporting)
                  _buildProgressOverlay(),
              ],
            ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Erstelle regelmäßig Backups, um deine Daten sicher aufzubewahren. '
                'Backups sind AES-verschlüsselt und können nur mit deinem Passwort geöffnet werden.',
                style: TextStyle(color: Colors.orange[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateBackupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.backup,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Neues Backup erstellen',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Exportiert alle deine Daten verschlüsselt',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Optionen
            SwitchListTile(
              title: const Text('Anhänge einschließen'),
              subtitle: const Text('Fotos, Audio-Dateien etc. (größere Datei)'),
              value: true,
              onChanged: (v) {}, // State würde in echter App verwaltet
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 12),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isCreating ? null : _createLocalBackup,
                    icon: const Icon(Icons.save),
                    label: const Text('Lokal speichern'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isCreating ? null : _createAndShareBackup,
                    icon: const Icon(Icons.share),
                    label: const Text('Teilen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restore,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup wiederherstellen',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Importiert ein vorhandenes Backup',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            FilledButton.tonalIcon(
              onPressed: _isImporting ? null : _importBackup,
              icon: const Icon(Icons.file_open),
              label: const Text('Backup-Datei auswählen'),
            ),
            
            const SizedBox(height: 12),
            
            // Warnung
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Achtung: Beim Import werden bestehende Daten überschrieben!',
                      style: TextStyle(
                        color: Colors.red[900],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gespeicherte Backups',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_backups.length > 5)
              TextButton.icon(
                onPressed: _cleanupOldBackups,
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text('Alte löschen'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_backups.isEmpty)
          _buildEmptyBackupsState()
        else
          ...(_backups.map((backup) => _buildBackupItem(backup))),
      ],
    );
  }

  Widget _buildEmptyBackupsState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Backups vorhanden',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Erstelle dein erstes Backup, um deine Daten zu sichern.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(BackupMetadata backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.archive),
        ),
        title: Text(
          DateFormat('dd.MM.yyyy HH:mm').format(backup.createdAt),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${backup.version} • ${backup.deviceName}'),
            Text(
              '${backup.journalCount} Einträge • ${backup.habitCount} Habits • ${backup.moodCount} Moods',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleBackupAction(action, backup),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text('Wiederherstellen'),
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Teilen'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Löschen', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _isCreating ? 'Backup wird erstellt...' : 'Backup wird importiert...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  _progressStep,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ ACTIONS ============

  Future<void> _createLocalBackup() async {
    setState(() {
      _isCreating = true;
      _progress = 0;
    });

    final service = ref.read(backupServiceProvider);
    final file = await service.createFullBackup(
      includeAttachments: true,
      onProgress: (p) {
        setState(() {
          _progress = p.progress;
          _progressStep = p.currentStep;
        });
      },
    );

    setState(() {
      _isCreating = false;
    });

    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup erstellt: ${file.path.split('/').last}'),
          action: SnackBarAction(
            label: 'Teilen',
            onPressed: () => service.shareBackup(file),
          ),
        ),
      );
      _loadBackups();
    }
  }

  Future<void> _createAndShareBackup() async {
    setState(() {
      _isCreating = true;
      _progress = 0;
    });

    final service = ref.read(backupServiceProvider);
    final file = await service.createFullBackup(
      includeAttachments: true,
      onProgress: (p) {
        setState(() {
          _progress = p.progress;
          _progressStep = p.currentStep;
        });
      },
    );

    setState(() {
      _isCreating = false;
    });

    if (file != null) {
      await service.shareBackup(file);
      _loadBackups();
    }
  }

  Future<void> _importBackup() async {
    final service = ref.read(backupServiceProvider);
    final filePath = await service.pickBackupFile();

    if (filePath == null) return;

    // Bestätigungsdialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup wiederherstellen?'),
        content: const Text(
          'Dies wird alle aktuellen Daten mit dem Backup überschreiben.\n\n'
          'Möchtest du fortfahren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Wiederherstellen'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isImporting = true;
      _progress = 0;
    });

    try {
      final metadata = await service.importBackup(
        filePath,
        onProgress: (p) {
          setState(() {
            _progress = p.progress;
            _progressStep = p.currentStep;
          });
        },
      );

      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup erfolgreich wiederhergestellt!\n'
              '${metadata?.journalCount ?? 0} Einträge importiert.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleBackupAction(String action, BackupMetadata backup) async {
    switch (action) {
      case 'restore':
        // In echter App würde man den Pfad kennen
        break;
        
      case 'share':
        // Teile Backup
        break;
        
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup löschen?'),
            content: const Text('Möchtest du dieses Backup wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Löschen'),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          // Lösche Backup
          _loadBackups();
        }
        break;
    }
  }

  Future<void> _cleanupOldBackups() async {
    final service = ref.read(backupServiceProvider);
    final deleted = await service.cleanupOldBackups(keepLast: 5);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$deleted alte Backups gelöscht')),
      );
      _loadBackups();
    }
  }
}
