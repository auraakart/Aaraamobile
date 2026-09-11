import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:flutter_test/flutter_test.dart';

UserDetail _testUser() {
  return UserDetail(
    phoneNumber: '9000000000',
    isVerified: true,
    name: 'Test User',
    email: 'test@example.com',
    customerID: '123',
  );
}

void main() {
  group('StorageState.copyWith', () {
    test('preserves nullable auth fields when they are not supplied', () {
      final user = _testUser();
      final state = StorageState(userData: user, isGuestMode: false);

      final updated = state.copyWith(addressData: const []);

      expect(updated.userData, same(user));
      expect(updated.isGuestMode, isFalse);
    });

    test('can explicitly clear user data', () {
      final state = StorageState(
        userData: _testUser(),
        isGuestMode: false,
      );

      final updated = state.copyWith(userData: null);

      expect(updated.userData, isNull);
      expect(updated.isGuestMode, isFalse);
    });

    test('can explicitly clear guest mode', () {
      final state = StorageState(
        userData: _testUser(),
        isGuestMode: true,
      );

      final updated = state.copyWith(isGuestMode: null);

      expect(updated.userData, isNotNull);
      expect(updated.isGuestMode, isNull);
    });
  });
}
