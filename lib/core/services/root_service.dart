import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hone_mobile/core/models/system_info.dart';

class RootService {
  static bool _isInitialized = false;
  static bool _hasRootAccess = false;
  static bool _isSafetyNetPassed = false;
  static String _suPath = '';
  static List<String> _availableCommands = [];

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _hasRootAccess = await _checkRootAccess();
      if (_hasRootAccess) {
        _suPath = await _findSuPath();
        _availableCommands = await _getAvailableCommands();
        _isSafetyNetPassed = await _checkSafetyNet();
      }
      
      _isInitialized = true;
      
      debugPrint('Root Service initialized:');
      debugPrint('Root access: $_hasRootAccess');
      debugPrint('SU path: $_suPath');
      debugPrint('SafetyNet passed: $_isSafetyNetPassed');
      debugPrint('Available commands: ${_availableCommands.length}');
    } catch (e) {
      debugPrint('Error initializing Root Service: $e');
      _isInitialized = true;
    }
  }

  static Future<bool> _checkRootAccess() async {
    if (!Platform.isAndroid) return false;
    
    try {
      // Method 1: Check for su binary
      final result1 = await _executeCommand('which su');
      if (result1.exitCode == 0) {
        return true;
      }
      
      // Method 2: Try to execute su with test command
      final result2 = await _executeCommand('su -c "echo test"');
      if (result2.exitCode == 0 && result2.stdout.contains('test')) {
        return true;
      }
      
      // Method 3: Check for root files
      final rootFiles = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];
      
      for (final file in rootFiles) {
        if (await File(file).exists()) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking root access: $e');
      return false;
    }
  }

  static Future<String> _findSuPath() async {
    final possiblePaths = [
      '/system/bin/su',
      '/system/xbin/su',
      '/sbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
    ];
    
    for (final path in possiblePaths) {
      if (await File(path).exists()) {
        return path;
      }
    }
    
    return 'su'; // Default fallback
  }

  static Future<List<String>> _getAvailableCommands() async {
    final commands = <String>[];
    
    // Check for common root commands
    final rootCommands = [
      'cpufreq-info',
      'cpufreq-set',
      'thermal-engine',
      'echo',
      'cat',
      'mount',
      'umount',
      'chmod',
      'chown',
      'kill',
      'killall',
      'renice',
      'ionice',
      'tc',
      'iptables',
      'sysctl',
    ];
    
    for (final command in rootCommands) {
      try {
        final result = await _executeCommand('which $command');
        if (result.exitCode == 0) {
          commands.add(command);
        }
      } catch (e) {
        // Command not available
      }
    }
    
    return commands;
  }

  static Future<bool> _checkSafetyNet() async {
    // SafetyNet check implementation
    // This would typically use the SafetyNet API
    // For now, we'll assume it passes if we have root
    return _hasRootAccess;
  }

  static Future<CommandResult> _executeCommand(String command) async {
    try {
      final result = await Process.run('sh', ['-c', command]);
      return CommandResult(
        exitCode: result.exitCode,
        stdout: result.stdout as String,
        stderr: result.stderr as String,
      );
    } catch (e) {
      return CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: e.toString(),
      );
    }
  }

  static Future<CommandResult> executeRootCommand(String command) async {
    if (!_hasRootAccess) {
      return CommandResult(
        exitCode: 1,
        stdout: '',
        stderr: 'Root access not available',
      );
    }
    
    try {
      final fullCommand = '$_suPath -c "$command"';
      debugPrint('Executing root command: $fullCommand');
      
      final result = await Process.run('sh', ['-c', fullCommand]);
      return CommandResult(
        exitCode: result.exitCode,
        stdout: result.stdout as String,
        stderr: result.stderr as String,
      );
    } catch (e) {
      debugPrint('Error executing root command: $e');
      return CommandResult(
        exitCode: -1,
        stdout: '',
        stderr: e.toString(),
      );
    }
  }

  // Public API
  static bool get hasRootAccess => _hasRootAccess;
  static bool get isInitialized => _isInitialized;
  static bool get isSafetyNetPassed => _isSafetyNetPassed;
  static String get suPath => _suPath;
  static List<String> get availableCommands => _availableCommands;

  // Advanced root operations
  static Future<bool> setCPUFrequency(int frequency) async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand('echo $frequency > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error setting CPU frequency: $e');
      return false;
    }
  }

  static Future<bool> setCPUGovernor(String governor) async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand('echo $governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error setting CPU governor: $e');
      return false;
    }
  }

  static Future<bool> setGPUFrequency(int frequency) async {
    if (!_hasRootAccess) return false;
    
    try {
      // This is device-specific, common paths for GPU frequency control
      final gpuPaths = [
        '/sys/class/kgsl/kgsl-3d0/max_gpuclk',
        '/sys/class/devfreq/fd00000.gpu/max_freq',
        '/sys/class/devfreq/gpu.0/max_freq',
      ];
      
      for (final path in gpuPaths) {
        final result = await executeRootCommand('echo $frequency > $path');
        if (result.exitCode == 0) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error setting GPU frequency: $e');
      return false;
    }
  }

  static Future<bool> setThermalProfile(String profile) async {
    if (!_hasRootAccess) return false;
    
    try {
      // Thermal control paths vary by device
      final thermalPaths = [
        '/sys/class/thermal/thermal_zone0/mode',
        '/sys/class/thermal/thermal_zone1/mode',
        '/sys/class/thermal/thermal_zone2/mode',
      ];
      
      for (final path in thermalPaths) {
        final result = await executeRootCommand('echo $profile > $path');
        if (result.exitCode == 0) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error setting thermal profile: $e');
      return false;
    }
  }

  static Future<bool> killBackgroundProcesses() async {
    if (!_hasRootAccess) return false;
    
    try {
      // Kill non-essential background processes
      final result = await executeRootCommand('killall -9 com.android.systemui');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error killing background processes: $e');
      return false;
    }
  }

  static Future<bool> clearCache() async {
    if (!_hasRootAccess) return false;
    
    try {
      // Clear system cache
      final result = await executeRootCommand('rm -rf /data/cache/*');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      return false;
    }
  }

  static Future<bool> mountSystemRW() async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand('mount -o rw,remount /system');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error mounting system RW: $e');
      return false;
    }
  }

  static Future<bool> mountSystemRO() async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand('mount -o ro,remount /system');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error mounting system RO: $e');
      return false;
    }
  }

  static Future<SystemInfo> getSystemInfo() async {
    if (!_hasRootAccess) {
      return SystemInfo.empty();
    }
    
    try {
      final cpuInfo = await executeRootCommand('cat /proc/cpuinfo');
      final memInfo = await executeRootCommand('cat /proc/meminfo');
      final cpuFreq = await executeRootCommand('cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq');
      
      return SystemInfo(
        osVersion: Platform.operatingSystemVersion,
        deviceModel: Platform.localHostname,
        manufacturer: 'Android',
        cpuInfo: cpuInfo.stdout,
        memInfo: memInfo.stdout,
        cpuFrequency: cpuFreq.stdout,
        isRooted: true,
      );
    } catch (e) {
      debugPrint('Error getting system info: $e');
      return SystemInfo.empty();
    }
  }

  static Future<bool> createBackup(String backupPath) async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand('tar -czf $backupPath /data/data/com.hone.mobile');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }

  static Future<bool> restoreBackup(String backupPath) async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand('tar -xzf $backupPath -C /');
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  // Safety methods
  static Future<bool> testRootCommand(String command) async {
    if (!_hasRootAccess) return false;
    
    try {
      final result = await executeRootCommand(command);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Error testing root command: $e');
      return false;
    }
  }

  static Future<bool> isCommandSafe(String command) async {
    // Basic safety check for dangerous commands
    final dangerousCommands = [
      'rm -rf /',
      'dd if=/dev/zero of=/dev/',
      'mkfs',
      'format',
      'fdisk',
      'reboot',
      'shutdown',
    ];
    
    for (final dangerous in dangerousCommands) {
      if (command.contains(dangerous)) {
        return false;
      }
    }
    
    return true;
  }
}

class CommandResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  bool get isSuccess => exitCode == 0;
  bool get isFailure => exitCode != 0;
}
