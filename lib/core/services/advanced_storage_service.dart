import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:hone_mobile/core/models/storage_analysis.dart';
import 'package:hone_mobile/core/services/root_service.dart';

class AdvancedStorageService {
  static bool _isInitialized = false;
  static final StreamController<StorageAnalysis> _analysisController = StreamController.broadcast();
  static Timer? _scanTimer;
  static StorageAnalysis _lastAnalysis = StorageAnalysis.empty();
  
  // Configuration
  static Duration _scanInterval = const Duration(hours: 6);
  static bool _autoScanEnabled = true;
  static const bool _deepScanEnabled = false;
  static final List<String> _scanDirectories = [
    '/storage/emulated/0/Android/data',
    '/storage/emulated/0/Android/obb',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Pictures',
    '/storage/emulated/0/Videos',
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Documents',
  ];

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadConfiguration();
      if (_autoScanEnabled) {
        _startAutoScan();
      }
      _isInitialized = true;
      
      debugPrint('Advanced Storage Service initialized');
    } catch (e) {
      debugPrint('Error initializing Advanced Storage Service: $e');
      _isInitialized = true;
    }
  }

  static Future<void> _loadConfiguration() async {
    // Load configuration from preferences
    // For now, use default values
  }

  static void _startAutoScan() {
    _scanTimer = Timer.periodic(_scanInterval, (timer) {
      performStorageAnalysis();
    });
  }

  static Future<StorageAnalysis> performStorageAnalysis({bool? deep}) async {
    try {
      debugPrint('Starting storage analysis...');
      final isDeepScan = deep ?? _deepScanEnabled;
      
      final analysis = StorageAnalysis(
        timestamp: DateTime.now(),
        totalStorage: await _getTotalStorage(),
        freeStorage: await _getFreeStorage(),
        usedStorage: await _getUsedStorage(),
        cacheFiles: await _analyzeCacheFiles(),
        tempFiles: await _analyzeTempFiles(),
        duplicateFiles: await _findDuplicateFiles(deep: isDeepScan),
        largeFiles: await _findLargeFiles(),
        obsoleteFiles: await _findObsoleteFiles(),
        apks: await _analyzeAPKs(),
        thumbnails: await _analyzeThumbnails(),
        downloads: await _analyzeDownloads(),
      );
      
      _lastAnalysis = analysis;
      _analysisController.add(analysis);
      
      debugPrint('Storage analysis completed:');
      debugPrint('Total: ${analysis.totalStorage}GB');
      debugPrint('Free: ${analysis.freeStorage}GB');
      debugPrint('Cache: ${analysis.cacheFiles.totalSize}GB');
      debugPrint('Duplicates: ${analysis.duplicateFiles.totalSize}GB');
      
      return analysis;
    } catch (e) {
      debugPrint('Error performing storage analysis: $e');
      return StorageAnalysis.empty();
    }
  }

  static Future<double> _getTotalStorage() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final stat = await _stat(directory.parent.path);
        return stat.totalSize / (1024 * 1024 * 1024); // Convert to GB
      }
    } catch (e) {
      debugPrint('Error getting total storage: $e');
    }
    return 0.0;
  }

  static Future<double> _getFreeStorage() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final stat = await _stat(directory.parent.path);
        return stat.freeSize / (1024 * 1024 * 1024); // Convert to GB
      }
    } catch (e) {
      debugPrint('Error getting free storage: $e');
    }
    return 0.0;
  }

  static Future<double> _getUsedStorage() async {
    final total = await _getTotalStorage();
    final free = await _getFreeStorage();
    return total - free;
  }

  static Future<StorageInfo> _stat(String path) async {
    try {
      final result = await RootService.executeRootCommand('stat -f "%z %b" "$path"');
      if (result.isSuccess) {
        final parts = result.stdout.trim().split(' ');
        final blockSize = int.parse(parts[0]);
        final totalBlocks = int.parse(parts[1]);
        final freeBlocks = int.parse(parts[2]);
        
        return StorageInfo(
          totalSize: blockSize * totalBlocks,
          freeSize: blockSize * freeBlocks,
          usedSize: blockSize * (totalBlocks - freeBlocks),
        );
      }
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
    }
    
    // Fallback to non-root method
    try {
      final directory = Directory(path);
      final statSync = await directory.stat();
      return StorageInfo(
        totalSize: statSync.size,
        freeSize: 0,
        usedSize: statSync.size,
      );
    } catch (e) {
      debugPrint('Fallback storage stats failed: $e');
    }
    
    return StorageInfo(totalSize: 0, freeSize: 0, usedSize: 0);
  }

  static Future<CacheAnalysis> _analyzeCacheFiles() async {
    final cacheDirs = [
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/obb',
      '/data/data/com.hone.mobile/cache',
      '/data/data/com.hone.mobile/files/cache',
    ];
    
    int totalSize = 0;
    int fileCount = 0;
    final cacheFiles = <CacheFile>[];
    
    for (final dir in cacheDirs) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true, followLinks: false)) {
            if (entity is File && entity.path.contains('cache')) {
              final stat = await entity.stat();
              totalSize += stat.size;
              fileCount++;
              
              cacheFiles.add(CacheFile(
                path: entity.path,
                size: stat.size,
                modified: stat.modified,
                type: _getCacheType(entity.path),
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Error analyzing cache directory $dir: $e');
      }
    }
    
    return CacheAnalysis(
      totalSize: totalSize,
      fileCount: fileCount,
      files: cacheFiles,
    );
  }

  static Future<TempAnalysis> _analyzeTempFiles() async {
    final tempDirs = [
      '/storage/emulated/0/Android/data/*/cache',
      '/storage/emulated/0/Download/tmp',
      '/data/local/tmp',
      '/tmp',
    ];
    
    int totalSize = 0;
    int fileCount = 0;
    final tempFiles = <TempFile>[];
    
    for (final dir in tempDirs) {
      try {
        final result = await RootService.executeRootCommand('find "$dir" -type f -name "*.tmp" -o -name "*.temp" 2>/dev/null');
        if (result.isSuccess) {
          final files = result.stdout.split('\n').where((f) => f.isNotEmpty);
          for (final file in files) {
            final fileEntity = File(file);
            if (await fileEntity.exists()) {
              final stat = await fileEntity.stat();
              totalSize += stat.size;
              fileCount++;
              
              tempFiles.add(TempFile(
                path: file,
                size: stat.size,
                modified: stat.modified,
                age: DateTime.now().difference(stat.modified),
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Error analyzing temp directory $dir: $e');
      }
    }
    
    return TempAnalysis(
      totalSize: totalSize,
      fileCount: fileCount,
      files: tempFiles,
    );
  }

  static Future<DuplicateAnalysis> _findDuplicateFiles({bool deep = false}) async {
    final duplicates = <DuplicateGroup>[];
    final fileHashes = <String, List<String>>{};
    
    // Scan common directories for duplicates
    final scanDirs = deep 
        ? _scanDirectories 
        : ['/storage/emulated/0/Download', '/storage/emulated/0/Pictures'];
    
    for (final dir in scanDirs) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final hash = await _calculateFileHash(entity.path);
              fileHashes.putIfAbsent(hash, () => []).add(entity.path);
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning directory $dir: $e');
      }
    }
    
    // Group duplicates
    for (final entry in fileHashes.entries) {
      if (entry.value.length > 1) {
        final files = <DuplicateFile>[];
        int totalSize = 0;
        
        for (final path in entry.value) {
          final file = File(path);
          if (await file.exists()) {
            final stat = await file.stat();
            totalSize += stat.size;
            files.add(DuplicateFile(
              path: path,
              size: stat.size,
              modified: stat.modified,
            ));
          }
        }
        
        duplicates.add(DuplicateGroup(
          hash: entry.key,
          files: files,
          totalSize: totalSize,
          count: files.length,
        ));
      }
    }
    
    final totalDuplicateSize = duplicates.fold<int>(0, (sum, group) => sum + group.totalSize);
    final totalDuplicateCount = duplicates.fold<int>(0, (sum, group) => sum + group.count);
    
    return DuplicateAnalysis(
      totalSize: totalDuplicateSize,
      fileCount: totalDuplicateCount,
      groups: duplicates,
    );
  }

  static Future<String> _calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('Error calculating hash for $filePath: $e');
      return '';
    }
  }

  static Future<LargeFileAnalysis> _findLargeFiles() async {
    final largeFiles = <LargeFile>[];
    const minSize = 100 * 1024 * 1024; // 100MB
    
    for (final dir in _scanDirectories) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final stat = await entity.stat();
              if (stat.size > minSize) {
                largeFiles.add(LargeFile(
                  path: entity.path,
                  size: stat.size,
                  modified: stat.modified,
                  type: _getFileType(entity.path),
                ));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning for large files in $dir: $e');
      }
    }
    
    largeFiles.sort((a, b) => b.size.compareTo(a.size));
    
    final totalSize = largeFiles.fold<int>(0, (sum, file) => sum + file.size);
    
    return LargeFileAnalysis(
      totalSize: totalSize,
      fileCount: largeFiles.length,
      files: largeFiles,
    );
  }

  static Future<ObsoleteFileAnalysis> _findObsoleteFiles() async {
    final obsoleteFiles = <ObsoleteFile>[];
    final now = DateTime.now();
    const threshold = Duration(days: 90);
    
    for (final dir in _scanDirectories) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final stat = await entity.stat();
              final age = now.difference(stat.modified);
              
              if (age > threshold) {
                obsoleteFiles.add(ObsoleteFile(
                  path: entity.path,
                  size: stat.size,
                  modified: stat.modified,
                  age: age,
                  reason: _getObsoleteReason(entity.path, age),
                ));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning for obsolete files in $dir: $e');
      }
    }
    
    final totalSize = obsoleteFiles.fold<int>(0, (sum, file) => sum + file.size);
    
    return ObsoleteFileAnalysis(
      totalSize: totalSize,
      fileCount: obsoleteFiles.length,
      files: obsoleteFiles,
    );
  }

  static Future<APKAnalysis> _analyzeAPKs() async {
    final apks = <APKFile>[];
    const apkDirs = ['/storage/emulated/0/Download', '/storage/emulated/0/APKs'];
    
    for (final dir in apkDirs) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: false, followLinks: false)) {
            if (entity is File && entity.path.endsWith('.apk')) {
              final stat = await entity.stat();
              final info = await _getAPKInfo(entity.path);
              
              apks.add(APKFile(
                path: entity.path,
                size: stat.size,
                modified: stat.modified,
                packageName: info['packageName'] ?? 'Unknown',
                versionName: info['versionName'] ?? 'Unknown',
                versionCode: info['versionCode'] ?? 'Unknown',
                isInstalled: info['isInstalled'] ?? false,
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Error analyzing APKs in $dir: $e');
      }
    }
    
    final totalSize = apks.fold<int>(0, (sum, apk) => sum + apk.size);
    
    return APKAnalysis(
      totalSize: totalSize,
      fileCount: apks.length,
      files: apks,
    );
  }

  static Future<Map<String, dynamic>> _getAPKInfo(String apkPath) async {
    try {
      final result = await RootService.executeRootCommand("aapt dump badging \"$apkPath\"");
      if (result.isSuccess) {
        final lines = result.stdout.split('\n');
        final info = <String, dynamic>{};
        
        for (final line in lines) {
          if (line.startsWith('package:')) {
            final parts = line.split(' ');
            for (final part in parts) {
              if (part.startsWith('name=')) {
                info['packageName'] = part.split('=')[1].replaceAll("'", "");
              } else if (part.startsWith('versionName=')) {
                info['versionName'] = part.split('=')[1].replaceAll("'", "");
              } else if (part.startsWith('versionCode=')) {
                info['versionCode'] = part.split('=')[1].replaceAll("'", "");
              }
            }
          }
        }
        
        // Check if installed
        if (info['packageName'] != null) {
          final checkResult = await RootService.executeRootCommand("pm list packages | grep ${info['packageName']}");
          info['isInstalled'] = checkResult.isSuccess;
        }
        
        return info;
      }
    } catch (e) {
      debugPrint('Error getting APK info for $apkPath: $e');
    }
    
    return {};
  }

  static Future<ThumbnailAnalysis> _analyzeThumbnails() async {
    final thumbnails = <ThumbnailFile>[];
    const thumbnailDirs = [
      '/storage/emulated/0/DCIM/.thumbnails',
      '/storage/emulated/0/Pictures/.thumbnails',
      '/data/data/com.android.gallery3d/cache',
    ];
    
    for (final dir in thumbnailDirs) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final stat = await entity.stat();
              thumbnails.add(ThumbnailFile(
                path: entity.path,
                size: stat.size,
                modified: stat.modified,
                type: _getThumbnailType(entity.path),
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Error analyzing thumbnails in $dir: $e');
      }
    }
    
    final totalSize = thumbnails.fold<int>(0, (sum, thumb) => sum + thumb.size);
    
    return ThumbnailAnalysis(
      totalSize: totalSize,
      fileCount: thumbnails.length,
      files: thumbnails,
    );
  }

  static Future<DownloadAnalysis> _analyzeDownloads() async {
    final downloads = <DownloadFile>[];
    const downloadDir = '/storage/emulated/0/Download';
    
    try {
      final directory = Directory(downloadDir);
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: false, followLinks: false)) {
          if (entity is File) {
            final stat = await entity.stat();
            downloads.add(DownloadFile(
              path: entity.path,
              size: stat.size,
              modified: stat.modified,
              type: _getFileType(entity.path),
              isComplete: _isDownloadComplete(entity.path),
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error analyzing downloads: $e');
    }
    
    final totalSize = downloads.fold<int>(0, (sum, download) => sum + download.size);
    
    return DownloadAnalysis(
      totalSize: totalSize,
      fileCount: downloads.length,
      files: downloads,
    );
  }

  // Helper methods
  static CacheType _getCacheType(String path) {
    if (path.contains('image_cache')) return CacheType.image;
    if (path.contains('video_cache')) return CacheType.video;
    if (path.contains('web_cache')) return CacheType.web;
    if (path.contains('app_cache')) return CacheType.application;
    return CacheType.system;
  }

  static FileType _getFileType(String path) {
    final extension = path.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return FileType.video;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return FileType.image;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return FileType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return FileType.document;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
        return FileType.archive;
      case 'apk':
        return FileType.apk;
      default:
        return FileType.other;
    }
  }

  static String _getObsoleteReason(String path, Duration age) {
    if (path.endsWith('.tmp') || path.endsWith('.temp')) {
      return 'Temporary file';
    }
    if (age.inDays > 365) {
      return 'Very old file (>1 year)';
    }
    if (path.contains('cache')) {
      return 'Old cache file';
    }
    return 'Unused file';
  }

  static ThumbnailType _getThumbnailType(String path) {
    if (path.contains('video')) return ThumbnailType.video;
    if (path.contains('image')) return ThumbnailType.image;
    return ThumbnailType.general;
  }

  static bool _isDownloadComplete(String path) {
    // Check if download is complete by file extension or presence of temp files
    return !path.endsWith('.tmp') && !path.endsWith('.part') && !path.endsWith('.crdownload');
  }

  // Public API
  static Stream<StorageAnalysis> get analysisStream => _analysisController.stream;
  static StorageAnalysis get lastAnalysis => _lastAnalysis;
  static bool get isInitialized => _isInitialized;
  static bool get autoScanEnabled => _autoScanEnabled;

  static Future<CleaningResult> cleanCacheFiles() async {
    try {
      final analysis = await _analyzeCacheFiles();
      int cleanedSize = 0;
      int cleanedFiles = 0;
      
      for (final cacheFile in analysis.files) {
        try {
          final file = File(cacheFile.path);
          if (await file.exists()) {
            await file.delete();
            cleanedSize += cacheFile.size;
            cleanedFiles++;
          }
        } catch (e) {
          debugPrint('Error deleting cache file ${cacheFile.path}: $e');
        }
      }
      
      return CleaningResult(
        success: true,
        cleanedSize: cleanedSize,
        cleanedFiles: cleanedFiles,
        type: CleaningType.cache,
      );
    } catch (e) {
      debugPrint('Error cleaning cache files: $e');
      return CleaningResult(
        success: false,
        cleanedSize: 0,
        cleanedFiles: 0,
        type: CleaningType.cache,
        error: e.toString(),
      );
    }
  }

  static Future<CleaningResult> cleanTempFiles() async {
    try {
      final analysis = await _analyzeTempFiles();
      int cleanedSize = 0;
      int cleanedFiles = 0;
      
      for (final tempFile in analysis.files) {
        try {
          final file = File(tempFile.path);
          if (await file.exists()) {
            await file.delete();
            cleanedSize += tempFile.size;
            cleanedFiles++;
          }
        } catch (e) {
          debugPrint('Error deleting temp file ${tempFile.path}: $e');
        }
      }
      
      return CleaningResult(
        success: true,
        cleanedSize: cleanedSize,
        cleanedFiles: cleanedFiles,
        type: CleaningType.temp,
      );
    } catch (e) {
      debugPrint('Error cleaning temp files: $e');
      return CleaningResult(
        success: false,
        cleanedSize: 0,
        cleanedFiles: 0,
        type: CleaningType.temp,
        error: e.toString(),
      );
    }
  }

  static Future<CleaningResult> cleanThumbnails() async {
    try {
      final analysis = await _analyzeThumbnails();
      int cleanedSize = 0;
      int cleanedFiles = 0;
      
      for (final thumbnail in analysis.files) {
        try {
          final file = File(thumbnail.path);
          if (await file.exists()) {
            await file.delete();
            cleanedSize += thumbnail.size;
            cleanedFiles++;
          }
        } catch (e) {
          debugPrint('Error deleting thumbnail ${thumbnail.path}: $e');
        }
      }
      
      return CleaningResult(
        success: true,
        cleanedSize: cleanedSize,
        cleanedFiles: cleanedFiles,
        type: CleaningType.thumbnails,
      );
    } catch (e) {
      debugPrint('Error cleaning thumbnails: $e');
      return CleaningResult(
        success: false,
        cleanedSize: 0,
        cleanedFiles: 0,
        type: CleaningType.thumbnails,
        error: e.toString(),
      );
    }
  }

  static Future<CleaningResult> cleanObsoleteFiles() async {
    try {
      final analysis = await _findObsoleteFiles();
      int cleanedSize = 0;
      int cleanedFiles = 0;
      
      for (final obsoleteFile in analysis.files) {
        try {
          final file = File(obsoleteFile.path);
          if (await file.exists()) {
            await file.delete();
            cleanedSize += obsoleteFile.size;
            cleanedFiles++;
          }
        } catch (e) {
          debugPrint('Error deleting obsolete file ${obsoleteFile.path}: $e');
        }
      }
      
      return CleaningResult(
        success: true,
        cleanedSize: cleanedSize,
        cleanedFiles: cleanedFiles,
        type: CleaningType.obsolete,
      );
    } catch (e) {
      debugPrint('Error cleaning obsolete files: $e');
      return CleaningResult(
        success: false,
        cleanedSize: 0,
        cleanedFiles: 0,
        type: CleaningType.obsolete,
        error: e.toString(),
      );
    }
  }

  static Future<CleaningResult> cleanDuplicateFiles(List<String> filesToKeep) async {
    try {
      final analysis = await _findDuplicateFiles();
      int cleanedSize = 0;
      int cleanedFiles = 0;
      
      for (final group in analysis.groups) {
        for (final duplicateFile in group.files) {
          if (!filesToKeep.contains(duplicateFile.path)) {
            try {
              final file = File(duplicateFile.path);
              if (await file.exists()) {
                await file.delete();
                cleanedSize += duplicateFile.size;
                cleanedFiles++;
              }
            } catch (e) {
              debugPrint('Error deleting duplicate file ${duplicateFile.path}: $e');
            }
          }
        }
      }
      
      return CleaningResult(
        success: true,
        cleanedSize: cleanedSize,
        cleanedFiles: cleanedFiles,
        type: CleaningType.duplicates,
      );
    } catch (e) {
      debugPrint('Error cleaning duplicate files: $e');
      return CleaningResult(
        success: false,
        cleanedSize: 0,
        cleanedFiles: 0,
        type: CleaningType.duplicates,
        error: e.toString(),
      );
    }
  }

  static Future<CleaningResult> performFullCleanup() async {
    final results = <CleaningResult>[];
    
    results.add(await cleanCacheFiles());
    results.add(await cleanTempFiles());
    results.add(await cleanThumbnails());
    results.add(await cleanObsoleteFiles());
    
    final totalCleanedSize = results.fold<int>(0, (sum, result) => sum + result.cleanedSize);
    final totalCleanedFiles = results.fold<int>(0, (sum, result) => sum + result.cleanedFiles);
    final success = results.every((result) => result.success);
    
    return CleaningResult(
      success: success,
      cleanedSize: totalCleanedSize,
      cleanedFiles: totalCleanedFiles,
      type: CleaningType.full,
      subResults: results,
    );
  }

  static void setAutoScan(bool enabled) {
    _autoScanEnabled = enabled;
    if (enabled) {
      _startAutoScan();
    } else {
      _scanTimer?.cancel();
      _scanTimer = null;
    }
  }

  static void setScanInterval(Duration interval) {
    _scanInterval = interval;
    if (_autoScanEnabled) {
      _scanTimer?.cancel();
      _startAutoScan();
    }
  }

  static void dispose() {
    _scanTimer?.cancel();
    _analysisController.close();
  }
}

class StorageInfo {
  final int totalSize;
  final int freeSize;
  final int usedSize;

  StorageInfo({
    required this.totalSize,
    required this.freeSize,
    required this.usedSize,
  });
}
