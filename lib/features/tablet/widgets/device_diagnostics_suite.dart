import 'package:flutter/material.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/core/models/device_info.dart';

class DeviceDiagnosticsSuite extends StatelessWidget {
  final DeviceInfo deviceInfo;

  const DeviceDiagnosticsSuite({
    super.key,
    required this.deviceInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildInfoSection('System Identity', [
                  _InfoRow('Manufacturer', deviceInfo.manufacturer),
                  _InfoRow('Model', deviceInfo.model),
                  _InfoRow('Brand', deviceInfo.brand),
                  _InfoRow('Product', deviceInfo.product),
                ]),
                const Divider(height: 32),
                _buildInfoSection('Hardware Internals', [
                  _InfoRow('Hardware', deviceInfo.hardware),
                  _InfoRow('Board', deviceInfo.device),
                  _InfoRow('Bootloader', deviceInfo.bootloader),
                  _InfoRow('Supported ABIs', deviceInfo.supportedAbis.join(', ')),
                ]),
                const Divider(height: 32),
                _buildInfoSection('Software Stack', [
                  _InfoRow('Android Version', deviceInfo.version),
                  _InfoRow('SDK Level', deviceInfo.sdkInt.toString()),
                  _InfoRow('Device Type', deviceInfo.deviceType),
                ]),
                const Divider(height: 32),
                _buildSystemFeatures(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.neonBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.dvr, color: AppTheme.neonBlue),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Diagnostics',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Comprehensive hardware & software report',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 14),
          SizedBox(width: 6),
          Text(
            'SYSTEM HEALTHY',
            style: TextStyle(color: AppTheme.neonGreen, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.neonBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSystemFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Features',
          style: TextStyle(
            color: AppTheme.neonBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: deviceInfo.systemFeatures
              .split(',')
              .take(15)
              .map((feature) => _FeatureChip(feature.trim()))
              .toList(),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        label.split('.').last,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }
}
