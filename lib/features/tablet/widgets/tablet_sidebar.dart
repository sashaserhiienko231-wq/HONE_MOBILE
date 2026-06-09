import 'package:flutter/material.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';

class TabletSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const TabletSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<TabletSidebar> createState() => _TabletSidebarState();
}

class _TabletSidebarState extends State<TabletSidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: _isCollapsed ? 8 : 16),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: widget.selectedIndex == 0,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(0),
                ),
                _SidebarItem(
                  icon: Icons.speed_outlined,
                  selectedIcon: Icons.speed,
                  label: 'Boost',
                  isSelected: widget.selectedIndex == 1,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(1),
                ),
                _SidebarItem(
                  icon: Icons.vpn_lock_outlined,
                  selectedIcon: Icons.vpn_lock,
                  label: 'VPN Boost',
                  isSelected: widget.selectedIndex == 2,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(2),
                ),
                _SidebarItem(
                  icon: Icons.sports_esports_outlined,
                  selectedIcon: Icons.sports_esports,
                  label: 'Gaming Hub',
                  isSelected: widget.selectedIndex == 3,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(3),
                ),
                _SidebarItem(
                  icon: Icons.tune_outlined,
                  selectedIcon: Icons.tune,
                  label: 'Optimization',
                  isSelected: widget.selectedIndex == 4,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(4),
                ),
                _SidebarItem(
                  icon: Icons.diamond_outlined,
                  selectedIcon: Icons.diamond,
                  label: 'Premium',
                  isSelected: widget.selectedIndex == 5,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(5),
                ),
                _SidebarItem(
                  icon: Icons.widgets_outlined,
                  selectedIcon: Icons.widgets,
                  label: 'Widgets',
                  isSelected: widget.selectedIndex == 6,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(6),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: widget.selectedIndex == 7,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onDestinationSelected(7),
                ),
              ],
            ),
          ),
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.all(_isCollapsed ? 12.0 : 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: _isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!_isCollapsed)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: AppTheme.neonGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HONE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'MOBILE PRO',
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(
                  _isCollapsed ? Icons.menu : Icons.menu_open,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
              ),
            ],
          ),
          if (_isCollapsed)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: AppTheme.neonGreen,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    if (_isCollapsed) {
      return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const CircleAvatar(
          backgroundColor: AppTheme.neonGreen,
          child: Icon(Icons.person, color: AppTheme.primaryDark),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.neonGreen,
            child: Icon(Icons.person, color: AppTheme.primaryDark),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Premium User',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Enterprise Edition',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: isCollapsed ? label : '',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.neonGreen.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.neonGreen.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
            ),
            child: isCollapsed
                ? Center(
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      color: isSelected ? AppTheme.neonGreen : Colors.white54,
                      size: 24,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        isSelected ? selectedIcon : icon,
                        color: isSelected ? AppTheme.neonGreen : Colors.white54,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppTheme.neonGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
