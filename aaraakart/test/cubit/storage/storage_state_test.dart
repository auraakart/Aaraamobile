import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorageState.copyWith', () {
    test('preserves nullable auth fields when they are not supplied', () {
      final user = UserDetail(customerID: '123', name: 'Test User');
      final state = StorageState(userData: user, isGuestMode: false);

      final updated = state.copyWith(addressData: const []);

      expect(updated.userData, same(user));
      expect(updated.isGuestMode, isFalse);
    });

    test('can explicitly clear user data', () {
      final state = StorageState(
        userData: UserDetail(customerID: '123', name: 'Test User'),
        isGuestMode: false,
      );

      final updated = state.copyWith(userData: null);

      expect(updated.userData, isNull);
      expect(updated.isGuestMode, isFalse);
    });

    test('can explicitly clear guest mode', () {
      final state = StorageState(
        userData: UserDetail(customerID: '123', name: 'Test User'),
        isGuestMode: true,
      );

      final updated = state.copyWith(isGuestMode: null);

      expect(updated.userData, isNotNull);
      expect(updated.isGuestMode, isNull);
    });
  });
}
