
class StorageAnalysis {
  final DateTime timestamp;
  final double totalStorage;
  final double freeStorage;
  final double usedStorage;
  final CacheAnalysis cacheFiles;
  final TempAnalysis tempFiles;
  final DuplicateAnalysis duplicateFiles;
  final LargeFileAnalysis largeFiles;
  final ObsoleteFileAnalysis obsoleteFiles;
  final APKAnalysis apks;
  final ThumbnailAnalysis thumbnails;
  final DownloadAnalysis downloads;

  StorageAnalysis({
    required this.timestamp,
    required this.totalStorage,
    required this.freeStorage,
    required this.usedStorage,
    required this.cacheFiles,
    required this.tempFiles,
    required this.duplicateFiles,
    required this.largeFiles,
    required this.obsoleteFiles,
    required this.apks,
    required this.thumbnails,
    required this.downloads,
  });

  static StorageAnalysis empty() {
    return StorageAnalysis(
      timestamp: DateTime.now(),
      totalStorage: 0.0,
      freeStorage: 0.0,
      usedStorage: 0.0,
      cacheFiles: CacheAnalysis.empty(),
      tempFiles: TempAnalysis.empty(),
      duplicateFiles: DuplicateAnalysis.empty(),
      largeFiles: LargeFileAnalysis.empty(),
      obsoleteFiles: ObsoleteFileAnalysis.empty(),
      apks: APKAnalysis.empty(),
      thumbnails: ThumbnailAnalysis.empty(),
      downloads: DownloadAnalysis.empty(),
    );
  }

  double get totalCleanableSize {
    return (cacheFiles.totalSize + 
            tempFiles.totalSize + 
            duplicateFiles.totalSize + 
            obsoleteFiles.totalSize + 
            thumbnails.totalSize).toDouble();
  }

  int get totalCleanableFiles {
    return cacheFiles.fileCount + 
           tempFiles.fileCount + 
           duplicateFiles.fileCount + 
           obsoleteFiles.fileCount + 
           thumbnails.fileCount;
  }

  double get storageUsagePercentage {
    if (totalStorage == 0) return 0.0;
    return (usedStorage / totalStorage) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'totalStorage': totalStorage,
      'freeStorage': freeStorage,
      'usedStorage': usedStorage,
      'cacheFiles': cacheFiles.toJson(),
      'tempFiles': tempFiles.toJson(),
      'duplicateFiles': duplicateFiles.toJson(),
      'largeFiles': largeFiles.toJson(),
      'obsoleteFiles': obsoleteFiles.toJson(),
      'apks': apks.toJson(),
      'thumbnails': thumbnails.toJson(),
      'downloads': downloads.toJson(),
    };
  }

  factory StorageAnalysis.fromJson(Map<String, dynamic> json) {
    return StorageAnalysis(
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalStorage: (json['totalStorage'] as num).toDouble(),
      freeStorage: (json['freeStorage'] as num).toDouble(),
      usedStorage: (json['usedStorage'] as num).toDouble(),
      cacheFiles: CacheAnalysis.fromJson(json['cacheFiles']),
      tempFiles: TempAnalysis.fromJson(json['tempFiles']),
      duplicateFiles: DuplicateAnalysis.fromJson(json['duplicateFiles']),
      largeFiles: LargeFileAnalysis.fromJson(json['largeFiles']),
      obsoleteFiles: ObsoleteFileAnalysis.fromJson(json['obsoleteFiles']),
      apks: APKAnalysis.fromJson(json['apks']),
      thumbnails: ThumbnailAnalysis.fromJson(json['thumbnails']),
      downloads: DownloadAnalysis.fromJson(json['downloads']),
    );
  }
}

class CacheAnalysis {
  final int totalSize;
  final int fileCount;
  final List<CacheFile> files;

  CacheAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static CacheAnalysis empty() {
    return CacheAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory CacheAnalysis.fromJson(Map<String, dynamic> json) {
    return CacheAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => CacheFile.fromJson(f)).toList(),
    );
  }
}

class CacheFile {
  final String path;
  final int size;
  final DateTime modified;
  final CacheType type;

  CacheFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'type': type.name,
    };
  }

  factory CacheFile.fromJson(Map<String, dynamic> json) {
    return CacheFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      type: CacheType.values.firstWhere((t) => t.name == json['type']),
    );
  }
}

enum CacheType {
  image,
  video,
  web,
  application,
  system,
}

class TempAnalysis {
  final int totalSize;
  final int fileCount;
  final List<TempFile> files;

  TempAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static TempAnalysis empty() {
    return TempAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory TempAnalysis.fromJson(Map<String, dynamic> json) {
    return TempAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => TempFile.fromJson(f)).toList(),
    );
  }
}

class TempFile {
  final String path;
  final int size;
  final DateTime modified;
  final Duration age;

  TempFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'age': age.inSeconds,
    };
  }

  factory TempFile.fromJson(Map<String, dynamic> json) {
    return TempFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      age: Duration(seconds: json['age'] as int),
    );
  }
}

class DuplicateAnalysis {
  final int totalSize;
  final int fileCount;
  final List<DuplicateGroup> groups;

  DuplicateAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.groups,
  });

  static DuplicateAnalysis empty() {
    return DuplicateAnalysis(
      totalSize: 0,
      fileCount: 0,
      groups: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'groups': groups.map((g) => g.toJson()).toList(),
    };
  }

  factory DuplicateAnalysis.fromJson(Map<String, dynamic> json) {
    return DuplicateAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      groups: (json['groups'] as List).map((g) => DuplicateGroup.fromJson(g)).toList(),
    );
  }
}

class DuplicateGroup {
  final String hash;
  final List<DuplicateFile> files;
  final int totalSize;
  final int count;

  DuplicateGroup({
    required this.hash,
    required this.files,
    required this.totalSize,
    required this.count,
  });

  int get potentialSavings => totalSize - (files.isEmpty ? 0 : files.first.size);

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'files': files.map((f) => f.toJson()).toList(),
      'totalSize': totalSize,
      'count': count,
    };
  }

  factory DuplicateGroup.fromJson(Map<String, dynamic> json) {
    return DuplicateGroup(
      hash: json['hash'] as String,
      files: (json['files'] as List).map((f) => DuplicateFile.fromJson(f)).toList(),
      totalSize: json['totalSize'] as int,
      count: json['count'] as int,
    );
  }
}

class DuplicateFile {
  final String path;
  final int size;
  final DateTime modified;

  DuplicateFile({
    required this.path,
    required this.size,
    required this.modified,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
    };
  }

  factory DuplicateFile.fromJson(Map<String, dynamic> json) {
    return DuplicateFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
    );
  }
}

class LargeFileAnalysis {
  final int totalSize;
  final int fileCount;
  final List<LargeFile> files;

  LargeFileAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static LargeFileAnalysis empty() {
    return LargeFileAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory LargeFileAnalysis.fromJson(Map<String, dynamic> json) {
    return LargeFileAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => LargeFile.fromJson(f)).toList(),
    );
  }
}

class LargeFile {
  final String path;
  final int size;
  final DateTime modified;
  final FileType type;

  LargeFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.type,
  });

  String get sizeFormatted => _formatBytes(size);

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'type': type.name,
    };
  }

  factory LargeFile.fromJson(Map<String, dynamic> json) {
    return LargeFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      type: FileType.values.firstWhere((t) => t.name == json['type']),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class ObsoleteFileAnalysis {
  final int totalSize;
  final int fileCount;
  final List<ObsoleteFile> files;

  ObsoleteFileAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static ObsoleteFileAnalysis empty() {
    return ObsoleteFileAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory ObsoleteFileAnalysis.fromJson(Map<String, dynamic> json) {
    return ObsoleteFileAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => ObsoleteFile.fromJson(f)).toList(),
    );
  }
}

class ObsoleteFile {
  final String path;
  final int size;
  final DateTime modified;
  final Duration age;
  final String reason;

  ObsoleteFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.age,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'age': age.inSeconds,
      'reason': reason,
    };
  }

  factory ObsoleteFile.fromJson(Map<String, dynamic> json) {
    return ObsoleteFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      age: Duration(seconds: json['age'] as int),
      reason: json['reason'] as String,
    );
  }
}

class APKAnalysis {
  final int totalSize;
  final int fileCount;
  final List<APKFile> files;

  APKAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static APKAnalysis empty() {
    return APKAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory APKAnalysis.fromJson(Map<String, dynamic> json) {
    return APKAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => APKFile.fromJson(f)).toList(),
    );
  }
}

class APKFile {
  final String path;
  final int size;
  final DateTime modified;
  final String packageName;
  final String versionName;
  final String versionCode;
  final bool isInstalled;

  APKFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.isInstalled,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'packageName': packageName,
      'versionName': versionName,
      'versionCode': versionCode,
      'isInstalled': isInstalled,
    };
  }

  factory APKFile.fromJson(Map<String, dynamic> json) {
    return APKFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      packageName: json['packageName'] as String,
      versionName: json['versionName'] as String,
      versionCode: json['versionCode'] as String,
      isInstalled: json['isInstalled'] as bool,
    );
  }
}

class ThumbnailAnalysis {
  final int totalSize;
  final int fileCount;
  final List<ThumbnailFile> files;

  ThumbnailAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static ThumbnailAnalysis empty() {
    return ThumbnailAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory ThumbnailAnalysis.fromJson(Map<String, dynamic> json) {
    return ThumbnailAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => ThumbnailFile.fromJson(f)).toList(),
    );
  }
}

class ThumbnailFile {
  final String path;
  final int size;
  final DateTime modified;
  final ThumbnailType type;

  ThumbnailFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'type': type.name,
    };
  }

  factory ThumbnailFile.fromJson(Map<String, dynamic> json) {
    return ThumbnailFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      type: ThumbnailType.values.firstWhere((t) => t.name == json['type']),
    );
  }
}

enum ThumbnailType {
  video,
  image,
  general,
}

class DownloadAnalysis {
  final int totalSize;
  final int fileCount;
  final List<DownloadFile> files;

  DownloadAnalysis({
    required this.totalSize,
    required this.fileCount,
    required this.files,
  });

  static DownloadAnalysis empty() {
    return DownloadAnalysis(
      totalSize: 0,
      fileCount: 0,
      files: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'fileCount': fileCount,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }

  factory DownloadAnalysis.fromJson(Map<String, dynamic> json) {
    return DownloadAnalysis(
      totalSize: json['totalSize'] as int,
      fileCount: json['fileCount'] as int,
      files: (json['files'] as List).map((f) => DownloadFile.fromJson(f)).toList(),
    );
  }
}

class DownloadFile {
  final String path;
  final int size;
  final DateTime modified;
  final FileType type;
  final bool isComplete;

  DownloadFile({
    required this.path,
    required this.size,
    required this.modified,
    required this.type,
    required this.isComplete,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'modified': modified.toIso8601String(),
      'type': type.name,
      'isComplete': isComplete,
    };
  }

  factory DownloadFile.fromJson(Map<String, dynamic> json) {
    return DownloadFile(
      path: json['path'] as String,
      size: json['size'] as int,
      modified: DateTime.parse(json['modified'] as String),
      type: FileType.values.firstWhere((t) => t.name == json['type']),
      isComplete: json['isComplete'] as bool,
    );
  }
}

enum FileType {
  video,
  audio,
  image,
  document,
  archive,
  apk,
  other,
}

class CleaningResult {
  final bool success;
  final int cleanedSize;
  final int cleanedFiles;
  final CleaningType type;
  final String? error;
  final List<CleaningResult>? subResults;

  CleaningResult({
    required this.success,
    required this.cleanedSize,
    required this.cleanedFiles,
    required this.type,
    this.error,
    this.subResults,
  });

  String get cleanedSizeFormatted {
    if (cleanedSize < 1024) return '$cleanedSize B';
    if (cleanedSize < 1024 * 1024) return '${(cleanedSize / 1024).toStringAsFixed(1)} KB';
    if (cleanedSize < 1024 * 1024 * 1024) return '${(cleanedSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(cleanedSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'cleanedSize': cleanedSize,
      'cleanedFiles': cleanedFiles,
      'type': type.name,
      'error': error,
      'subResults': subResults?.map((r) => r.toJson()).toList(),
    };
  }

  factory CleaningResult.fromJson(Map<String, dynamic> json) {
    return CleaningResult(
      success: json['success'] as bool,
      cleanedSize: json['cleanedSize'] as int,
      cleanedFiles: json['cleanedFiles'] as int,
      type: CleaningType.values.firstWhere((t) => t.name == json['type']),
      error: json['error'] as String?,
      subResults: json['subResults'] != null
          ? (json['subResults'] as List).map((r) => CleaningResult.fromJson(r)).toList()
          : null,
    );
  }
}

enum CleaningType {
  cache,
  temp,
  duplicates,
  obsolete,
  thumbnails,
  full,
}
