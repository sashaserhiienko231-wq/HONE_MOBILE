import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/shared/widgets/custom_app_bar.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isBackingUp = false;

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isBackingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud backup successful!'), backgroundColor: AppTheme.neonGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Backup & Restore',
                subtitle: 'Secure your optimization engine presets',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      _buildBackupStatus(),
                      SizedBox(height: 32.h),
                      _buildActionCard(
                        'Cloud Sync',
                        'Sync settings across all your devices',
                        Icons.cloud_upload,
                        AppTheme.neonBlue,
                        _isBackingUp ? null : _performBackup,
                        _isBackingUp,
                      ),
                      SizedBox(height: 16.h),
                      _buildActionCard(
                        'Local Backup',
                        'Export presets to device storage',
                        Icons.storage,
                        AppTheme.neonGreen,
                        () {},
                        false,
                      ),
                      SizedBox(height: 16.h),
                      _buildActionCard(
                        'Restore Factory',
                        'Revert to original engine defaults',
                        Icons.restore,
                        AppTheme.accentRed,
                        () {},
                        false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_done, color: AppTheme.neonGreen, size: 48.w),
          SizedBox(height: 16.h),
          Text(
            'LAST BACKUP',
            style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          Text(
            'Today, 10:42 AM',
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color color, VoidCallback? onTap, bool isLoading) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24.w),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  Text(desc, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(color)))
            else
              Icon(Icons.chevron_right, color: Colors.white24, size: 20.w),
          ],
        ),
      ),
    );
  }
}
