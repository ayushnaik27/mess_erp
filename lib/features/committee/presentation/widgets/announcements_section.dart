import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/features/committee/controllers/committee_dashboard_controller.dart';
import 'package:mess_erp/features/student/services/announcement_service.dart';

class AnnouncementsSection extends StatelessWidget {
  final CommitteeDashboardController controller;

  const AnnouncementsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isAnnouncementsLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Get.theme.colorScheme.primary,
            ),
          );
        }

        if (controller.announcements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12.h),
                Text(
                  'No announcements available',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/addAnnouncement'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Announcement'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Get.theme.colorScheme.primary,
                    side: BorderSide(color: Get.theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scrollbar(
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.announcements.length,
            separatorBuilder: (context, index) => Divider(
              height: 24.h,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final announcement = controller.announcements[index];
              final isMessBill = announcement.title == 'Mess Bill';

              return InkWell(
                onTap: () {
                  announcement.file == null
                      ? null
                      : AnnouncementService().openAnnouncement(
                          announcement.file!.path,
                          openBill: isMessBill,
                        );
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: _getAnnouncementColor(announcement.title)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getAnnouncementIcon(announcement.title),
                          color: _getAnnouncementColor(announcement.title),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              announcement.description,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a').format(
                                announcement.timestamp!.toDate(),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (announcement.file != null)
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.attach_file,
                            size: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  IconData _getAnnouncementIcon(String title) {
    if (title.toLowerCase().contains('mess bill')) {
      return Icons.receipt;
    } else if (title.toLowerCase().contains('menu')) {
      return Icons.restaurant_menu;
    } else if (title.toLowerCase().contains('holiday') ||
        title.toLowerCase().contains('vacation')) {
      return Icons.event;
    } else if (title.toLowerCase().contains('maintenance')) {
      return Icons.build;
    } else if (title.toLowerCase().contains('meeting')) {
      return Icons.people;
    } else {
      return Icons.campaign;
    }
  }

  Color _getAnnouncementColor(String title) {
    if (title.toLowerCase().contains('mess bill')) {
      return Colors.green;
    } else if (title.toLowerCase().contains('menu')) {
      return Colors.orange;
    } else if (title.toLowerCase().contains('holiday') ||
        title.toLowerCase().contains('vacation')) {
      return Colors.blue;
    } else if (title.toLowerCase().contains('maintenance')) {
      return Colors.amber;
    } else if (title.toLowerCase().contains('meeting')) {
      return Colors.purple;
    } else {
      return Colors.teal;
    }
  }
}
