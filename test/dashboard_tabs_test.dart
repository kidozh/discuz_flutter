import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/widget/dashboard_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final style in [
    AppVisualStyle.material,
    AppVisualStyle.cupertino,
    AppVisualStyle.liquidGlass,
  ]) {
    testWidgets(
      'visible dashboard categories support switching and catalog changes: $style',
      (tester) async {
        var selected = 'new';
        var ids = ['new', 'hot', 'keylol'];
        late StateSetter update;
        await tester.pumpWidget(
          PlatformProvider(
            style: style,
            builder: (_) => MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return DashboardTabs(
                      ids: ids,
                      labels: ids.map((id) => id.toUpperCase()).toList(),
                      selectedId: ids.contains(selected) ? selected : ids.first,
                      onSelected: (id) => setState(() => selected = id),
                      sectionBuilder: (id) => Center(child: Text('body-$id')),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (style == AppVisualStyle.material) {
          expect(find.byType(TabBar), findsOneWidget);
          await tester.tap(find.byIcon(Icons.whatshot));
          await tester.pumpAndSettle();
          expect(selected, 'hot');
          await tester.drag(find.byType(TabBarView), const Offset(-600, 0));
          await tester.pumpAndSettle();
          expect(selected, 'keylol');
        } else {
          expect(find.byType(PlatformSegmentedControl), findsOneWidget);
          await tester.tap(find.text('KEYLOL'));
          await tester.pumpAndSettle();
          expect(selected, 'keylol');
        }
        update(() => ids = ['hot', 'keylol', 'new']);
        await tester.pumpAndSettle();
        expect(find.text('body-keylol'), findsOneWidget);
        update(() => ids = ['new', 'hot']);
        await tester.pumpAndSettle();
        expect(find.text('body-new'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
