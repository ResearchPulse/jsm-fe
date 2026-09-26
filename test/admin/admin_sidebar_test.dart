import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/features/admin/presentation/widgets/admin_sidebar.dart';

Widget _buildSidebarTestHarness({
  required bool isCollapsed,
  required VoidCallback onToggle,
}) {
  return MaterialApp(
    home: Scaffold(
      body: AdminSidebar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        isCollapsed: isCollapsed,
        onToggleCollapse: onToggle,
      ),
    ),
  );
}

void main() {
  testWidgets('expanded sidebar: shows collapse button near logo, shows user profile at bottom', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool toggled = false;

    await tester.pumpWidget(_buildSidebarTestHarness(
      isCollapsed: false,
      onToggle: () => toggled = true,
    ));
    await tester.pumpAndSettle();

    // 1. Brand header has Logo and HyperData Lab
    expect(find.text('HyperData Lab'), findsOneWidget);
    expect(find.text('H'), findsOneWidget);

    // 2. Collapse button is located at top next to logo
    final collapseBtn = find.byTooltip('Thu gọn thanh menu');
    expect(collapseBtn, findsOneWidget);
    await tester.tap(collapseBtn);
    expect(toggled, isTrue);

    // 3. Old 'Quay về trang chủ' button is removed
    expect(find.text('Quay về trang chủ'), findsNothing);

    // 4. Bottom area shows account profile fallback
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('ADMIN'), findsOneWidget);
  });

  testWidgets('collapsed sidebar: shows clickable logo to expand, shows avatar tooltip at bottom', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool toggled = false;

    await tester.pumpWidget(_buildSidebarTestHarness(
      isCollapsed: true,
      onToggle: () => toggled = true,
    ));
    await tester.pumpAndSettle();

    // 1. Text 'HyperData Lab' is hidden
    expect(find.text('HyperData Lab'), findsNothing);

    // 2. Logo has expand tooltip and tapping toggles
    final expandTooltip = find.byTooltip('Mở rộng thanh menu');
    expect(expandTooltip, findsOneWidget);
    await tester.tap(expandTooltip);
    expect(toggled, isTrue);

    // 3. Old 'Quay về trang chủ' is not present
    expect(find.text('Quay về trang chủ'), findsNothing);

    // 4. Avatar with tooltip at bottom
    expect(find.byTooltip('Admin (ADMIN)'), findsOneWidget);
  });
}
