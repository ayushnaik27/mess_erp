import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/student/controllers/extra_items_controller.dart';
import 'package:mess_erp/features/student/models/extra_item_model.dart';
import 'package:mess_erp/core/constants/app_strings.dart';

class RequestExtraItemsScreen extends StatefulWidget {
  final String rollNumber;

  const RequestExtraItemsScreen({super.key, required this.rollNumber});

  @override
  State<RequestExtraItemsScreen> createState() =>
      _RequestExtraItemsScreenState();
}

class _RequestExtraItemsScreenState extends State<RequestExtraItemsScreen> {
  final ExtraItemsController _controller = Get.find<ExtraItemsController>();
  final TextEditingController _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _controller.loadExtraItems();
    _controller.setRollNumber(widget.rollNumber);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 20.h),
                    _buildSectionTitle(AppStrings.selectItem),
                    SizedBox(height: 12.h),
                    _buildItemSelector(),
                    SizedBox(height: 12.h),
                    _buildSelectedItemCard(),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(AppStrings.quantityLabel),
                    SizedBox(height: 12.h),
                    _buildQuantityField(),
                    SizedBox(height: 12.h),
                    _buildTotalAmount(),
                    SizedBox(height: 40.h),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      title: Text(
        AppStrings.requestExtraItemsDrawer,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.extraItemsRequest,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 500.ms),
        SizedBox(height: 8.h),
        Text(
          AppStrings.selectItemsSubtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildItemSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
              value: _controller.selectedItem.value.name.isEmpty
                  ? null
                  : _controller.selectedItem.value.name,
              hint: Text(
                AppStrings.selectAnExtraItem,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.primary),
              isExpanded: true,
              borderRadius: BorderRadius.circular(12.r),
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
              ),
              onChanged: (String? value) {
                if (value != null) {
                  _controller.selectItem(value);
                }
              },
              items: [
                ..._controller.extraItems.map((ExtraItem item) {
                  return DropdownMenuItem<String>(
                    value: item.name,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ],
            )),
      ),
    );
  }

  Widget _buildSelectedItemCard() {
    return Obx(() {
      final selectedItem = _controller.selectedItem.value;
      if (selectedItem.name.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.fastfood,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedItem.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currencyFormat.format(selectedItem.price),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.95, 0.95));
    });
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      style: TextStyle(
        fontSize: 16.sp,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: AppStrings.enterQuantity,
        hintStyle: TextStyle(
          fontSize: 15.sp,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(Icons.numbers, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.pleaseEnterQuantity;
        }
        final quantity = int.tryParse(value);
        if (quantity == null || quantity <= 0) {
          return AppStrings.enterValidQuantity;
        }
        return null;
      },
      onChanged: (value) {
        _controller.setQuantity(int.tryParse(value) ?? 0);
      },
    );
  }

  Widget _buildTotalAmount() {
    return Obx(() {
      final total = _controller.calculatedAmount.value;
      if (total <= 0) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.totalAmount,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              currencyFormat.format(total),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _controller.isSubmitting.value ? null : () => _submitRequest(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: _controller.isSubmitting.value
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppStrings.submitRequest,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    if (_controller.selectedItem.value.name.isEmpty) {
      Get.snackbar(
        AppStrings.errorTitle,
        AppStrings.pleaseSelectItem,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _controller.submitExtraItemRequest().then((success) {
      if (success) {
        Get.back();
        Get.snackbar(
          AppStrings.success,
          AppStrings.requestSubmitted,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    });
  }
}
