import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/localization/app_localizations.dart';
import 'package:jsm_fe/core/localization/locale_cubit.dart';
import 'package:jsm_fe/core/localization/locale_storage.dart';

class MockLocaleStorage implements LocaleStorage {
  String? saved;

  @override
  Future<String?> loadLocale() async => saved;

  @override
  Future<void> saveLocale(String languageCode) async {
    saved = languageCode;
  }
}

void main() {
  group('AppLocalizations Tests', () {
    test('English is default and translations match', () {
      final l10nEn = AppLocalizations(const Locale('en'));
      expect(l10nEn.isVietnamese, false);
      expect(l10nEn.signIn, 'Sign in');
      expect(l10nEn.adminDashboard, 'Admin dashboard');
      expect(l10nEn.signOut, 'Sign out');
      expect(l10nEn.titleJournalsMining, 'Journals & Mining Hub');
      expect(l10nEn.navJournalsCenter, 'Journals Center');
      expect(l10nEn.triggerMiningTitle, 'Trigger Journal Mining');
      expect(l10nEn.ssoNote, 'Accounts are authenticated via HyperDataLab Central SSO portal.');
      expect(l10nEn.securityStandard, 'Secured with OpenID Connect & OAuth 2.0 standards');
      expect(l10nEn.journalsCatalogTitle, 'Journal Catalog & Mining Center');
      expect(l10nEn.miningCenterTitle, 'Mining & Style Profile Center');
      expect(l10nEn.tabNlpProfilesTitle, 'NLP Style Profiles & CARS Moves');
      expect(l10nEn.tabJobMonitorTitle, 'Job Monitor & Debug Logs');
    });

    test('Vietnamese translations match', () {
      final l10nVi = AppLocalizations(const Locale('vi'));
      expect(l10nVi.isVietnamese, true);
      expect(l10nVi.signIn, 'Đăng nhập');
      expect(l10nVi.adminDashboard, 'Bảng điều khiển quản trị');
      expect(l10nVi.signOut, 'Đăng xuất');
      expect(l10nVi.titleJournalsMining, 'Trung Tâm Tạp Chí & Khai Phá');
      expect(l10nVi.navJournalsCenter, 'Trung tâm Tạp chí');
      expect(l10nVi.triggerMiningTitle, 'Kích hoạt Khai phá Tạp chí');
      expect(l10nVi.ssoNote, 'Tài khoản được xác thực qua cổng Central SSO chung của HyperDataLab.');
      expect(l10nVi.securityStandard, 'Bảo mật tiêu chuẩn OpenID Connect & OAuth 2.0');
      expect(l10nVi.journalsCatalogTitle, 'Danh Mục & Trung Tâm Khai Phá Tạp Chí');
      expect(l10nVi.miningCenterTitle, 'Trung Tâm Khai Phá & Hồ Sơ Phong Cách');
      expect(l10nVi.tabNlpProfilesTitle, 'Hồ Sơ Phong Cách NLP & CARS Moves');
      expect(l10nVi.tabJobMonitorTitle, 'Nhật Ký Tác Vụ & Debug');
    });
  });

  group('LocaleCubit Tests', () {
    test('Default locale is en', () {
      final storage = MockLocaleStorage();
      final cubit = LocaleCubit(storage: storage);
      expect(cubit.state, const Locale('en'));
    });

    test('Toggle switches between en and vi', () async {
      final storage = MockLocaleStorage();
      final cubit = LocaleCubit(storage: storage);
      expect(cubit.state, const Locale('en'));

      await cubit.toggleLocale();
      expect(cubit.state, const Locale('vi'));
      expect(storage.saved, 'vi');

      await cubit.toggleLocale();
      expect(cubit.state, const Locale('en'));
      expect(storage.saved, 'en');
    });

    test('setLocale sets specific locale', () async {
      final storage = MockLocaleStorage();
      final cubit = LocaleCubit(storage: storage);

      await cubit.setLocale(const Locale('vi'));
      expect(cubit.state, const Locale('vi'));

      await cubit.setLocale(const Locale('en'));
      expect(cubit.state, const Locale('en'));
    });
  });
}
