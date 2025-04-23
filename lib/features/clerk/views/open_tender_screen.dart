// import 'dart:io';
import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/clerk/controllers/tender_controller.dart';

import '../models/index.dart';

class OpenTenderScreen extends StatefulWidget {
  const OpenTenderScreen({super.key});

  @override
  State<OpenTenderScreen> createState() => _OpenTenderScreenState();
}

class _OpenTenderScreenState extends State<OpenTenderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TenderController _controller;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  final RxInt _currentStep = 0.obs;
  final RxBool _isUploading = false.obs;
  final RxDouble _uploadProgress = 0.0.obs;
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TenderController>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _unitsController.dispose();
    _remarksController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Create New Tender',
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
          onPressed: () => _confirmExit(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Obx(() => Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep.value,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Row(
                    children: [
                      if (_currentStep.value > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      SizedBox(width: 16.w),
                      if (_currentStep.value < 3)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 12.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Obx(() => ElevatedButton(
                              onPressed:
                                  _isSubmitting.value ? null : _submitTender,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24.w, vertical: 12.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: _isSubmitting.value
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          'Submitting...',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Submit Tender',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            )),
                    ],
                  ),
                );
              },
              onStepContinue: () {
                if (_currentStep.value == 0) {
                  if (_titleController.text.isEmpty) {
                    Get.snackbar(
                      'Missing Information',
                      'Please enter a title for the tender',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade700,
                      colorText: Colors.white,
                    );
                    return;
                  }
                } else if (_currentStep.value == 1) {
                  if (_controller.tenderItems.isEmpty) {
                    Get.snackbar(
                      'Missing Items',
                      'Please add at least one item to the tender',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade700,
                      colorText: Colors.white,
                    );
                    return;
                  }
                }

                if (_currentStep.value < 3) {
                  _currentStep.value++;
                }
              },
              onStepCancel: () {
                if (_currentStep.value > 0) {
                  _currentStep.value--;
                }
              },
              onStepTapped: (index) {
                // Validation before allowing to jump to a step
                if (index > _currentStep.value) {
                  if (_currentStep.value == 0 &&
                      _titleController.text.isEmpty) {
                    Get.snackbar(
                      'Missing Information',
                      'Please enter a title for the tender',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade700,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  if (_currentStep.value == 1 &&
                      _controller.tenderItems.isEmpty) {
                    Get.snackbar(
                      'Missing Items',
                      'Please add at least one item to the tender',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade700,
                      colorText: Colors.white,
                    );
                    return;
                  }
                }
                _currentStep.value = index;
              },
              steps: [
                Step(
                  title: Text(
                    'Tender Information',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Basic details about the tender',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  content: _buildTenderInfoStep(),
                  isActive: _currentStep.value >= 0,
                  state: _currentStep.value > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'Items Required',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Add items to be included in the tender',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  content: _buildTenderItemsStep(),
                  isActive: _currentStep.value >= 1,
                  state: _currentStep.value > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'Dates & Deadlines',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Set important dates for the tender',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  content: _buildDatesStep(),
                  isActive: _currentStep.value >= 2,
                  state: _currentStep.value > 2
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'Documentation',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Upload tender documentation',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  content: _buildDocumentationStep(),
                  isActive: _currentStep.value >= 3,
                  state: _currentStep.value > 3
                      ? StepState.complete
                      : StepState.indexed,
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildTenderInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter a clear, descriptive title for this tender',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Tender Title',
            hintText: 'e.g., Supply of Groceries for Campus Mess',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Provide a clear title that accurately describes the tender. This will help suppliers understand what you are looking for.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenderItemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items Required',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: Icon(Icons.add, size: 18.sp, color: AppColors.background),
              label: Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (_controller.tenderItems.isEmpty) {
            return Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 50.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No items added yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Click "Add Item" to add items to the tender',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Colors.grey.shade50),
                  dataRowHeight: 70.h,
                  headingRowHeight: 56.h,
                  horizontalMargin: 16.w,
                  columnSpacing: 24.w,
                  columns: [
                    DataColumn(
                      label: Text(
                        'No.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Item Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Brand',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Remarks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(
                    _controller.tenderItems.length,
                    (index) {
                      final item = _controller.tenderItems[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.itemName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.quantity} ${item.units}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.brand,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 150.w,
                              child: Text(
                                item.remarks,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () => _showRemarksDialog(item.remarks),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue.shade700,
                                    size: 20.sp,
                                  ),
                                  onPressed: () => _editItem(index, item),
                                  tooltip: 'Edit',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.all(4.w),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade700,
                                    size: 20.sp,
                                  ),
                                  onPressed: () => _deleteItem(index),
                                  tooltip: 'Delete',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.all(4.w),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Be specific about quantities, units, and any brand preferences. Clear specifications help suppliers provide accurate quotes.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set important dates for your tender',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deadline for Filing Bids',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This is the last date suppliers can submit their bids',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Obx(() => ListTile(
                      leading: Icon(
                        Icons.event,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Selected Date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('EEEE, MMMM d, yyyy')
                            .format(_controller.deadline.value),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_drop_down),
                      onTap: () => _selectDeadline(context),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date of Opening Bids',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This is the date when bids will be opened and evaluated',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Obx(() => ListTile(
                      leading: Icon(
                        Icons.event,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Selected Date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('EEEE, MMMM d, yyyy')
                            .format(_controller.openingDate.value),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_drop_down),
                      onTap: () => _selectOpeningDate(context),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'The opening date must be after the deadline for bid submissions. This gives suppliers enough time to prepare their bids.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload tender documentation (PDF files only)',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),
        Obx(() {
          if (_controller.filePath.value.isEmpty) {
            return Container(
              height: 160.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                onTap: _selectFile,
                borderRadius: BorderRadius.circular(12.r),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(35.r),
                        ),
                        child: Icon(
                          Icons.upload_file,
                          size: 32.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Upload Tender Document',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Click to browse files (PDF only)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Show selected file
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Colors.red.shade700,
                      size: 32.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Document',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _controller.filePath.value.split('/').last,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _viewFile,
                        icon: Icon(Icons.visibility),
                        label: Text('View Document'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectFile,
                        icon: Icon(Icons.swap_horiz),
                        label: Text('Change File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          side: BorderSide(color: Colors.blueGrey),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 16.h),
        Obx(() {
          if (_isUploading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'Uploading file... ${(_uploadProgress.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: _uploadProgress.value,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            );
          }
          return SizedBox();
        }),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade700),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Document should include all tender specifications, terms, conditions, and instructions for suppliers.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addItem() {
    _itemNameController.clear();
    _quantityController.clear();
    _unitsController.clear();
    _remarksController.clear();
    _brandController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _unitsController,
                      decoration: InputDecoration(
                        labelText: 'Units',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand (optional)',
                  prefixIcon: Icon(Icons.branding_watermark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Remarks/Specifications',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60.h),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateItemForm()) {
                _controller.addTenderItem(
                  TenderItem(
                    itemName: _itemNameController.text,
                    quantity: double.parse(_quantityController.text),
                    units: _unitsController.text,
                    remarks: _remarksController.text,
                    brand: _brandController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _editItem(int index, TenderItem item) {
    _itemNameController.text = item.itemName;
    _quantityController.text = item.quantity.toString();
    _unitsController.text = item.units;
    _remarksController.text = item.remarks;
    _brandController.text = item.brand;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _unitsController,
                      decoration: InputDecoration(
                        labelText: 'Units',
                        prefixIcon: Icon(
                          Icons.straighten,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand (optional)',
                  prefixIcon: Icon(Icons.branding_watermark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Remarks/Specifications',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60.h),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateItemForm()) {
                _controller.updateTenderItem(
                  index,
                  TenderItem(
                    itemName: _itemNameController.text,
                    quantity: double.parse(_quantityController.text),
                    units: _unitsController.text,
                    remarks: _remarksController.text,
                    brand: _brandController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Update Item'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _controller.removeTenderItem(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _validateItemForm() {
    if (_itemNameController.text.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please enter an item name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    if (_quantityController.text.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a quantity',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      double.parse(_quantityController.text);
    } catch (e) {
      Get.snackbar(
        'Invalid Input',
        'Quantity must be a number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    if (_unitsController.text.isEmpty) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a unit of measurement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void _showRemarksDialog(String remarks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Item Specifications'),
        content: SingleChildScrollView(
          child: Text(remarks),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.deadline.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _controller.deadline.value) {
      _controller.setDeadline(picked);
      if (_controller.openingDate.value.isBefore(_controller.deadline.value)) {
        _controller.setOpeningDate(_controller.deadline.value);
      }
    }
  }

  void _selectOpeningDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.openingDate.value,
      firstDate: _controller.deadline.value,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _controller.openingDate.value) {
      _controller.setOpeningDate(picked);
    }
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        _controller.setFilePath(result.files.single.path!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  void _viewFile() {
    if (_controller.filePath.value.isNotEmpty) {
      OpenFilex.open(_controller.filePath.value);
    }
  }

  Future<void> _submitTender() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please enter a title for the tender',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      _currentStep.value = 0;
      return;
    }

    if (_controller.tenderItems.isEmpty) {
      Get.snackbar(
        'Missing Items',
        'Please add at least one item to the tender',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      _currentStep.value = 1;
      return;
    }

    if (_controller.filePath.value.isEmpty) {
      Get.snackbar(
        'Missing Document',
        'Please upload a tender document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isSubmitting.value = true;

      // // Upload file to Firebase Storage
      // Reference ref = FirebaseStorage.instance.ref().child('tenders').child(
      //     '${DateTime.now().millisecondsSinceEpoch}_${_titleController.text}');

      // _isUploading.value = true;

      // UploadTask uploadTask = ref.putFile(File(_controller.filePath.value));

      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   _uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes;
      // });

      // await uploadTask;
      // String fileUrl = await ref.getDownloadURL();

      // _isUploading.value = false;

      final tender = Tender(
        tenderId: 'T${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        tenderItems: _controller.tenderItems,
        deadline: _controller.deadline.value,
        openingDate: _controller.openingDate.value,
        fileUrl: "fileUrl",
        hostelId: _controller.hostelId.value,
        bids: [],
      );

      // Save tender to Firestore
      await _controller.addTender(tender);

      Get.snackbar(
        'Success',
        'Tender submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit tender: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      _isSubmitting.value = false;
      _isUploading.value = false;
    }
  }

  void _confirmExit() {
    if (_titleController.text.isNotEmpty ||
        _controller.tenderItems.isNotEmpty ||
        _controller.filePath.value.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Discard Changes?'),
          content:
              Text('You have unsaved changes. Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Get.back(); // Navigate back
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }
}
