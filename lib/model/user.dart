import 'package:connect/services/database_service.dart';

class UserModel {
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final service = DatabaseService();

    final Map<String, dynamic> userData = await service.getUserData(userId);

    if (userData.isNotEmpty) {
      final Map<String, dynamic> partnerData = await service.getUserData(
        userData['partnerId'],
      );
      final Map<String, dynamic> relationshipData = await service
          .getRelationshipData(userData['relationshipId']);

      return <String, dynamic>{
        ...userData,
        "partnerData": partnerData,
        "relationshipData": relationshipData,
      };
    } else {
      return <String, dynamic>{};
    }
  }
}
