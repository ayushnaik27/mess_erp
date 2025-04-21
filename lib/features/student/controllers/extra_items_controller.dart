import 'package:get/get.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/student/models/extra_item_model.dart';
import 'package:mess_erp/features/student/services/extra_items_service.dart';

class ExtraItemsController extends GetxController {
  final ExtraItemsService _service = ExtraItemsService();
  final AppLogger _logger = AppLogger();

  final RxList<ExtraItem> extraItems = <ExtraItem>[].obs;
  final Rx<ExtraItem> selectedItem = ExtraItem(name: '', price: 0).obs;
  final RxInt quantity = 0.obs;
  final RxDouble calculatedAmount = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString rollNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(quantity, (_) => _calculateAmount());
    ever(selectedItem, (_) => _calculateAmount());
  }

  void setRollNumber(String roll) {
    rollNumber.value = roll;
  }

  Future<void> loadExtraItems() async {
    try {
      isLoading.value = true;
      final items = await _service.getExtraItems();
      extraItems.assignAll(items);
    } catch (e) {
      _logger.e('Failed to load extra items', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectItem(String itemName) {
    final item = extraItems.firstWhere(
      (item) => item.name == itemName,
      orElse: () => ExtraItem(name: '', price: 0),
    );
    selectedItem.value = item;
  }

  void setQuantity(int value) {
    quantity.value = value;
  }

  void _calculateAmount() {
    if (selectedItem.value.name.isNotEmpty && quantity.value > 0) {
      calculatedAmount.value = selectedItem.value.price * quantity.value;
    } else {
      calculatedAmount.value = 0;
    }
  }

  Future<bool> submitExtraItemRequest() async {
    if (selectedItem.value.name.isEmpty ||
        quantity.value <= 0 ||
        rollNumber.value.isEmpty) {
      return false;
    }

    try {
      isSubmitting.value = true;

      final result = await _service.addExtraItemRequest(
        rollNumber: rollNumber.value,
        itemName: selectedItem.value.name,
        quantity: quantity.value,
        amount: calculatedAmount.value,
      );

      return result;
    } catch (e) {
      _logger.e('Failed to submit extra item request', error: e);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
