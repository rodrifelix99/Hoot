import 'package:get/get.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/invitation_service.dart';
import 'package:hoot/models/user.dart';

class InviteFriendsController extends GetxController {
  final AuthService _authService;
  final InvitationService _invitationService;

  InviteFriendsController(
      {AuthService? authService, InvitationService? invitationService})
      : _authService = authService ?? Get.find<AuthService>(),
        _invitationService = invitationService ?? Get.find<InvitationService>();

  final inviteCode = ''.obs;
  final remainingInvites = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final U? user = await _authService.fetchUser();
    if (user != null) {
      inviteCode.value = user.invitationCode ?? '';
      remainingInvites.value =
          await _invitationService.getRemainingInvites(user.uid);
    }
  }
}
