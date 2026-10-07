import 'package:flutter_test/flutter_test.dart';

import 'package:qarz_daftari/main.dart';

void main() {
  testWidgets('Asosiy ekran sarlavhasi ko‘rinadi', (tester) async {
    await tester.pumpWidget(const QarzDaftariApp());
    await tester.pump();
    expect(find.text('Qarz Daftari'), findsOneWidget);
  });
}
