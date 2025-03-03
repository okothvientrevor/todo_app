import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> error = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await _apiService.getRecentUsers();
      final List<User> loadedUsers =
          response.map((userData) => User.fromJson(userData)).toList();

      users.value = loadedUsers;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
