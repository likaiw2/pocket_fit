import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_fit/services/data_collection_service.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';

/// 数据管理页面 - 查看和导出已采集的数据
class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  final DataCollectionService _collectionService = DataCollectionService();
  
  List<FileSystemEntity> _dataFiles = [];
  bool _isLoading = true;
  String _dataPath = '';

  @override
  void initState() {
    super.initState();
    _loadDataFiles();
  }

  Future<void> _loadDataFiles() async {
    setState(() {
      _isLoading = true;
    });

    final files = await _collectionService.getAllDataFiles();
    final path = await _collectionService.getDataDirectoryPath();

    setState(() {
      _dataFiles = files;
      _dataPath = path;
      _isLoading = false;
    });
  }

  Future<void> _copyPathToClipboard(String filePath) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await Clipboard.setData(ClipboardData(text: filePath));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.filePathCopied),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.copyFailed(e.toString()))),
        );
      }
    }
  }



  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _collectionService.clearAllData();
      await _loadDataFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allDataCleared)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metaFiles = _dataFiles.where((f) => f.path.endsWith('_meta.txt')).toList();
    final csvFiles = _dataFiles.where((f) => f.path.endsWith('_data.csv')).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dataManagementTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_dataFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllData,
              tooltip: l10n.clearAllData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dataFiles.isEmpty
              ? _buildEmptyState()
              : _buildDataList(metaFiles, csvFiles),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDataYet,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startCollectingData,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList(List<FileSystemEntity> metaFiles, List<FileSystemEntity> csvFiles) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 统计信息卡片
        Card(
          margin: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.dataset,
                      label: l10n.datasets,
                      value: '${metaFiles.length}',
                      color: Colors.blue,
                    ),
                    _buildStatItem(
                      icon: Icons.insert_drive_file,
                      label: l10n.totalFiles,
                      value: '${_dataFiles.length}',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.folder, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dataPath,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 文件列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: metaFiles.length,
            itemBuilder: (context, index) {
              final metaFile = metaFiles[index];
              final fileName = metaFile.path.split('/').last;
              final baseName = fileName.replaceAll('_meta.txt', '');
              final csvFile = csvFiles.firstWhere(
                (f) => f.path.contains(baseName),
                orElse: () => metaFile,
              );

              return _buildFileCard(metaFile, csvFile, baseName);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(FileSystemEntity metaFile, FileSystemEntity csvFile, String baseName) {
    // 解析文件名获取信息
    final parts = baseName.split('_');
    final activityType = parts.isNotEmpty ? parts[0] : 'unknown';
    final reps = parts.length > 1 ? parts[1] : '';
    final dateTime = parts.length > 2 ? parts[2] : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.dataset, color: Colors.deepPurple),
        ),
        title: Text(
          activityType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$reps • $dateTime'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteDataSet(metaFile, csvFile),
          tooltip: '删除数据集',
        ),
        children: [
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.orange),
            title: Text(AppLocalizations.of(context)!.metadataFile),
            subtitle: Text(metaFile.path.split('/').last),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _viewMetaFile(metaFile),
                  tooltip: AppLocalizations.of(context)!.view,
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyPathToClipboard(metaFile.path),
                  tooltip: AppLocalizations.of(context)!.copyPath,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: Text(AppLocalizations.of(context)!.csvDataFile),
            subtitle: Text(csvFile.path.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyPathToClipboard(csvFile.path),
              tooltip: AppLocalizations.of(context)!.copyPath,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDataSet(FileSystemEntity metaFile, FileSystemEntity csvFile) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteDatasetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 删除两个文件
        await File(metaFile.path).delete();
        await File(csvFile.path).delete();
        await _loadDataFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.datasetDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteFailed(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _viewMetaFile(FileSystemEntity metaFile) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final file = File(metaFile.path);
      final content = await file.readAsString();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.metadata),
            content: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.readFileFailed(e.toString()))),
        );
      }
    }
  }
}

