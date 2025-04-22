import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/clerk/controllers/tender_controller.dart';
import 'package:mess_erp/features/clerk/models/index.dart';

class AllTendersScreen extends StatefulWidget {
  const AllTendersScreen({Key? key}) : super(key: key);

  @override
  State<AllTendersScreen> createState() => _AllTendersScreenState();
}

class _AllTendersScreenState extends State<AllTendersScreen> {
  final TenderController _controller = Get.find<TenderController>();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _filterStatus = 'all'.obs;
  final RxString _sortBy = 'deadline'.obs;
  final RxBool _sortAscending = false.obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text;
    });

    // Add more sort options to controller if needed
    if (!_controller.allTenders.isNotEmpty) {
      _controller.fetchAndSetTenders();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tender> get _filteredTenders => _controller.allTenders.where((tender) {
        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          return tender.title
                  .toLowerCase()
                  .contains(_searchQuery.value.toLowerCase()) ||
              tender.tenderId
                  .toLowerCase()
                  .contains(_searchQuery.value.toLowerCase());
        }
        return true;
      }).where((tender) {
        // Filter by status
        if (_filterStatus.value == 'all') return true;
        if (_filterStatus.value == 'active') return tender.status == 'active';
        if (_filterStatus.value == 'closed') return tender.status == 'closed';
        if (_filterStatus.value == 'awarded') return tender.status == 'awarded';
        return true;
      }).toList()
        ..sort((a, b) {
          // Sort by selected criteria
          switch (_sortBy.value) {
            case 'deadline':
              return _sortAscending.value
                  ? a.deadline.compareTo(b.deadline)
                  : b.deadline.compareTo(a.deadline);
            case 'openingDate':
              return _sortAscending.value
                  ? a.openingDate.compareTo(b.openingDate)
                  : b.openingDate.compareTo(a.openingDate);
            case 'title':
              return _sortAscending.value
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title);
            case 'bids':
              return _sortAscending.value
                  ? a.bids.length.compareTo(b.bids.length)
                  : b.bids.length.compareTo(a.bids.length);
            default:
              return _sortAscending.value
                  ? a.deadline.compareTo(b.deadline)
                  : b.deadline.compareTo(a.deadline);
          }
        });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'All Tenders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.sort, color: AppColors.primary),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusFilterChips(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (_controller.allTenders.isEmpty) {
                return _buildEmptyState();
              }

              final filteredTenders = _filteredTenders;

              if (filteredTenders.isEmpty) {
                return _buildNoResultsState();
              }

              return RefreshIndicator(
                onRefresh: _controller.fetchAndSetTenders,
                color: AppColors.primary,
                child: ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: filteredTenders.length,
                  itemBuilder: (context, index) {
                    final tender = filteredTenders[index];
                    return _buildTenderCard(tender, index);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create tender screen
          Get.toNamed('/create-tender');
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Create New Tender',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by title or ID...',
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey.shade600),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : SizedBox()),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChips() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.only(left: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Obx(() => _buildFilterChip('All', 'all')),
          SizedBox(width: 8.w),
          Obx(() => _buildFilterChip('Active', 'active')),
          SizedBox(width: 8.w),
          Obx(() => _buildFilterChip('Closed', 'closed')),
          SizedBox(width: 8.w),
          Obx(() => _buildFilterChip('Awarded', 'awarded')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus.value == value;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _filterStatus.value = value;
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }

  Widget _buildTenderCard(Tender tender, int index) {
    final now = DateTime.now();
    final isOpen = tender.openingDate.isBefore(now);
    final isActive = tender.status == 'active';
    final deadline = tender.deadline;
    final openingDate = tender.openingDate;
    final daysToDeadline = deadline.difference(now).inDays;

    Color statusColor;
    String statusText;

    if (tender.status == 'awarded') {
      statusColor = Colors.green.shade700;
      statusText = 'Awarded';
    } else if (tender.status == 'closed') {
      statusColor = Colors.red.shade700;
      statusText = 'Closed';
    } else if (!isActive) {
      statusColor = Colors.grey.shade700;
      statusText = 'Inactive';
    } else if (deadline.isBefore(now)) {
      statusColor = Colors.orange.shade800;
      statusText = 'Deadline Passed';
    } else {
      statusColor = Colors.blue.shade700;
      statusText = 'Active';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tender.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.access_time,
                        deadline.isBefore(now)
                            ? 'Deadline Passed'
                            : '$daysToDeadline days left',
                        deadline.isBefore(now)
                            ? Colors.red.shade700
                            : daysToDeadline < 3
                                ? Colors.orange.shade800
                                : Colors.blue.shade700,
                      ),
                      SizedBox(width: 16.w),
                      _buildInfoItem(
                        Icons.lock_open,
                        isOpen ? 'Bids Open' : 'Bids Locked',
                        isOpen ? Colors.green.shade700 : Colors.grey.shade700,
                      ),
                      SizedBox(width: 16.w),
                      _buildInfoItem(
                        Icons.people,
                        '${tender.bids.length} Bids',
                        Colors.purple.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deadline',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(deadline),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: deadline.isBefore(now)
                                    ? Colors.red.shade700
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opening Date',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(openingDate),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: openingDate.isBefore(now)
                                    ? Colors.green.shade700
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        'Items: ${tender.tenderItems.length}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Spacer(),
                      isOpen
                          ? OutlinedButton.icon(
                              onPressed: () => () {},
                              icon: Icon(Icons.visibility, size: 18.sp),
                              label: Text('View Details'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            )
                          : TextButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.lock, size: 18.sp),
                              label: Text(
                                  'Opens on ${DateFormat('MMM d').format(openingDate)}'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade600,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: color,
        ),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No tenders available',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first tender to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/create-tender'),
            icon: Icon(Icons.add),
            label: Text('Create Tender'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 70.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No matches found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
                _searchQuery.value.isNotEmpty
                    ? 'No results matching "${_searchQuery.value}"'
                    : 'No tenders match the current filter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              )),
          SizedBox(height: 24.h),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              _filterStatus.value = 'all';
            },
            icon: Icon(Icons.clear),
            label: Text('Clear Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Filter Tenders',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => _buildFilterOption(
                  title: 'All Tenders',
                  isSelected: _filterStatus.value == 'all',
                  onTap: () {
                    _filterStatus.value = 'all';
                    Get.back();
                  },
                  icon: Icons.list_alt,
                  color: AppColors.primary,
                )),
            Obx(() => _buildFilterOption(
                  title: 'Active Tenders',
                  isSelected: _filterStatus.value == 'active',
                  onTap: () {
                    _filterStatus.value = 'active';
                    Get.back();
                  },
                  icon: Icons.timelapse,
                  color: Colors.blue.shade700,
                )),
            Obx(() => _buildFilterOption(
                  title: 'Closed Tenders',
                  isSelected: _filterStatus.value == 'closed',
                  onTap: () {
                    _filterStatus.value = 'closed';
                    Get.back();
                  },
                  icon: Icons.lock_clock,
                  color: Colors.red.shade700,
                )),
            Obx(() => _buildFilterOption(
                  title: 'Awarded Tenders',
                  isSelected: _filterStatus.value == 'awarded',
                  onTap: () {
                    _filterStatus.value = 'awarded';
                    Get.back();
                  },
                  icon: Icons.verified,
                  color: Colors.green.shade700,
                )),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => _buildSortOption(
                  title: 'Deadline (Newest first)',
                  isSelected:
                      _sortBy.value == 'deadline' && !_sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'deadline';
                    _sortAscending.value = false;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Deadline (Oldest first)',
                  isSelected:
                      _sortBy.value == 'deadline' && _sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'deadline';
                    _sortAscending.value = true;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Opening Date (Newest first)',
                  isSelected:
                      _sortBy.value == 'openingDate' && !_sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'openingDate';
                    _sortAscending.value = false;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Opening Date (Oldest first)',
                  isSelected:
                      _sortBy.value == 'openingDate' && _sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'openingDate';
                    _sortAscending.value = true;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Title (A-Z)',
                  isSelected: _sortBy.value == 'title' && _sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'title';
                    _sortAscending.value = true;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Title (Z-A)',
                  isSelected: _sortBy.value == 'title' && !_sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'title';
                    _sortAscending.value = false;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Number of Bids (High to Low)',
                  isSelected: _sortBy.value == 'bids' && !_sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'bids';
                    _sortAscending.value = false;
                    Get.back();
                  },
                )),
            Obx(() => _buildSortOption(
                  title: 'Number of Bids (Low to High)',
                  isSelected: _sortBy.value == 'bids' && _sortAscending.value,
                  onTap: () {
                    _sortBy.value = 'bids';
                    _sortAscending.value = true;
                    Get.back();
                  },
                )),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
