import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hone_mobile/core/theme/app_theme.dart';
import 'package:hone_mobile/features/games/presentation/services/gaming_hub_storage.dart';

class GamingBookmarksPage extends StatefulWidget {
  const GamingBookmarksPage({super.key});

  @override
  State<GamingBookmarksPage> createState() => _GamingBookmarksPageState();
}

class _GamingBookmarksPageState extends State<GamingBookmarksPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isEditMode = false;
  final List<String> _selectedIds = [];

  // Controllers for Add Bookmarks
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'website';
  String _selectedEmoji = '🌐';

  final List<String> _emojis = ['🌐', '🎮', '💬', '🏆', '📰', '🎥', '🛠️', '📱', '🔗', '⭐'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = GamingHubStorage.getBookmarks();
      _selectedIds.clear();
    });
  }

  Future<void> _addBookmark() async {
    if (_titleController.text.trim().isEmpty || _urlController.text.trim().isEmpty) return;

    await GamingHubStorage.addBookmark(
      _titleController.text.trim(),
      _urlController.text.trim(),
      _selectedType,
      _selectedEmoji,
    );
    if (!mounted) return;

    _titleController.clear();
    _urlController.clear();
    _loadItems();
    Navigator.pop(context);

    // Achievement unlock check
    if (_items.length >= 3) {
      GamingHubStorage.unlockAchievement('collector', context);
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    await GamingHubStorage.deleteBookmarks(_selectedIds);
    if (!mounted) return;
    setState(() {
      _isEditMode = false;
    });
    _loadItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected bookmarks removed')),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _items.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        for (var item in _items) {
          _selectedIds.add(item['id'] as String);
        }
      }
    });
  }

  void _showAddBookmarkDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24.h,
                left: 24.w,
                right: 24.w,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Bookmark / Shortcut',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Bookmark Title',
                        hintText: 'e.g. Steam Community',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'URL / Address',
                        hintText: 'https://...',
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Bookmark Type
                    Text('Bookmark Type', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildTypeChip('website', 'Website', setDialogState),
                        SizedBox(width: 8.w),
                        _buildTypeChip('shortcut', 'Shortcut', setDialogState),
                        SizedBox(width: 8.w),
                        _buildTypeChip('app', 'Game Link', setDialogState),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Choose Emoji Symbol
                    Text('Select Emoji Symbol', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 48.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _emojis.length,
                        separatorBuilder: (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final emoji = _emojis[index];
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                _selectedEmoji = emoji;
                              });
                            },
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.purple.withValues(alpha: 0.3) : Colors.black26,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.neonPurple : Colors.white12,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _addBookmark,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                        child: const Text('Add Bookmark', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(String value, String label, StateSetter setDialogState) {
    final isSelected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.neonPurple.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setDialogState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0C091A),
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

              // Quick Info Banner (Samsung style spacing)
              if (!_isEditMode) _buildInfoBanner(),

              // Bookmarks Grid
              Expanded(
                child: _items.isEmpty ? _buildEmptyState() : _buildGrid(),
              ),

              // Delete confirmation button in edit mode
              if (_isEditMode && _selectedIds.isNotEmpty) _buildDeleteFooter(),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditMode 
          ? null 
          : FloatingActionButton(
              onPressed: _showAddBookmarkDialog,
              backgroundColor: AppTheme.neonPurple,
              child: const Icon(Icons.add, color: Colors.white),
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
            onPressed: () {
              if (_isEditMode) {
                setState(() {
                  _isEditMode = false;
                  _selectedIds.clear();
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              _isEditMode ? Icons.close : Icons.arrow_back,
              color: Colors.white70,
            ),
          ),
          Text(
            _isEditMode 
                ? '${_selectedIds.length} SELECTED' 
                : 'BOOKMARKS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          _items.isEmpty
              ? SizedBox(width: 48.w)
              : TextButton(
                  onPressed: () {
                    setState(() {
                      if (_isEditMode) {
                        _isEditMode = false;
                        _selectedIds.clear();
                      } else {
                        _isEditMode = true;
                      }
                    });
                  },
                  child: Text(
                    _isEditMode ? 'Cancel' : 'Edit',
                    style: TextStyle(
                      color: _isEditMode ? Colors.white60 : Colors.purple[200],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amberAccent, size: 20),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Bookmark your favorite game forums, wikis, guild chats, or cloud feeds for quick direct access.',
                style: TextStyle(color: Colors.white54, fontSize: 10.sp, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.2,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final id = item['id'] as String;
        final isSelected = _selectedIds.contains(id);

        return GestureDetector(
          onTap: () {
            if (_isEditMode) {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(id);
                } else {
                  _selectedIds.add(id);
                }
              });
            } else {
              // Open bookmark in simulation
              _launchUrl(item['title'] as String, item['url'] as String);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.purple.withValues(alpha: 0.15) 
                  : AppTheme.cardDark.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.neonPurple 
                    : Colors.white.withValues(alpha: 0.05),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['icon'] as String? ?? '🌐',
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        item['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['url'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white38, fontSize: 9.sp),
                      ),
                    ],
                  ),
                ),
                if (_isEditMode)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.neonPurple : Colors.black26,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: isSelected 
                          ? Icon(Icons.check, color: Colors.white, size: 12.w)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            TextButton(
              onPressed: _toggleSelectAll,
              child: Text(
                _selectedIds.length == _items.length ? 'DESELECT ALL' : 'SELECT ALL',
                style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('DELETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purple.withValues(alpha: 0.08)),
            ),
            child: Text(
              '🔖',
              style: TextStyle(fontSize: 48.sp),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Bookmarks Created',
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the "+" button below to bookmark external web resources, chats, or guide resources.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 11.sp, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String title, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LAUNCHING LINK...',
              style: TextStyle(color: AppTheme.neonPurple, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            SizedBox(height: 8.h),
            Text(
              'Connecting to secure external viewport: $url',
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            ),
            SizedBox(height: 16.h),
            const LinearProgressIndicator(color: AppTheme.neonPurple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
