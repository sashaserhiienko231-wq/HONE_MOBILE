import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class GamingNotificationsPage extends StatefulWidget {
  const GamingNotificationsPage({super.key});

  @override
  State<GamingNotificationsPage> createState() => _GamingNotificationsPageState();
}

class _GamingNotificationsPageState extends State<GamingNotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = GamingHubStorage.getNotifications();
    });
  }

  Future<void> _deleteItem(String id) async {
    await GamingHubStorage.deleteNotification(id);
    if (!mounted) return;
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification removed'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _markAsRead(String id) async {
    await GamingHubStorage.markNotificationAsRead(id);
    _loadItems();
  }

  Future<void> _clearAll(String type) async {
    final toDelete = _items.where((item) => item['type'] == type).map((item) => item['id'] as String).toList();
    for (var id in toDelete) {
      await GamingHubStorage.deleteNotification(id);
    }
    if (!mounted) return;
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cleared all $type messages')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _items.where((i) => i['type'] == 'notification').toList();
    final promotions = _items.where((i) => i['type'] == 'promotion').toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF070B16),
              AppTheme.primaryDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Samsung Tabs
              _buildTabs(),

              // Tab View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(notifications, 'notification'),
                    _buildList(promotions, 'promotion'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          Text(
            'UPDATES & PROMOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: AppTheme.cardDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            onSelected: (value) {
              if (value == 'clear_notif') {
                _clearAll('notification');
              } else if (value == 'clear_promo') {
                _clearAll('promotion');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_notif',
                child: Text('Clear Notifications', style: TextStyle(color: Colors.white70)),
              ),
              const PopupMenuItem(
                value: 'clear_promo',
                child: Text('Clear Promotions', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white12),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.purple[200],
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        tabs: const [
          Tab(text: 'Notifications'),
          Tab(text: 'Promotions'),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String type) {
    if (items.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item['id'] as String;
        final isRead = item['isRead'] as bool;
        final String badge = item['badge'] as String? ?? 'Hub';

        return Dismissible(
          key: Key(id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => _deleteItem(id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          ),
          child: InkWell(
            onTap: () {
              if (!isRead) {
                _markAsRead(id);
              }
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isRead 
                    ? AppTheme.cardDark.withValues(alpha: 0.2) 
                    : AppTheme.cardDark.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isRead 
                      ? Colors.white.withValues(alpha: 0.02) 
                      : AppTheme.neonPurple.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon indicator
                  Container(
                    margin: EdgeInsets.only(top: 2.h),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: isRead ? Colors.transparent : AppTheme.neonPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                badge.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.purple[200],
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(item['timestamp'] as String),
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: isRead ? Colors.white70 : Colors.white,
                            fontSize: 13.sp,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item['description'] as String,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    final String emoji = type == 'notification' ? '📭' : '🎁';
    final String title = type == 'notification' ? 'All caught up' : 'No promotions active';
    final String subtitle = type == 'notification' 
        ? 'We will notify you when system performance patches or optimization engine reports are ready.' 
        : 'Special weekend events, XP boosters, and game discounts will show up here.';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing Circle
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purple.withValues(alpha: 0.08)),
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: 48.sp),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (_) {
      return '';
    }
  }
}
