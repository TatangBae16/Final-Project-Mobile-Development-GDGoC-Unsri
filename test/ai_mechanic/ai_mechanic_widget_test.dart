import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/ai_mechanic/presentation/pages/ai_mechanic_page.dart';
import 'package:md_midtermproject/features/ai_mechanic/presentation/bloc/ai_mechanic_bloc.dart';
import 'package:md_midtermproject/features/ai_mechanic/presentation/bloc/ai_mechanic_event.dart';
import 'package:md_midtermproject/features/ai_mechanic/presentation/bloc/ai_mechanic_state.dart';

class MockAiMechanicBloc extends MockBloc<AiMechanicEvent, AiMechanicState> implements AiMechanicBloc {}

void main() {
  late MockAiMechanicBloc mockAiMechanicBloc;

  setUp(() {
    mockAiMechanicBloc = MockAiMechanicBloc();
  });

  tearDown(() {
    mockAiMechanicBloc.close();
  });

  testWidgets('AiMechanicPage merender AppBar, Quick Replies, dan Input Chat', (WidgetTester tester) async {
    whenListen(
      mockAiMechanicBloc,
      Stream.fromIterable([AiMechanicLoaded([])]),
      initialState: AiMechanicLoaded([]),
    );

    await tester.pumpWidget(
      BlocProvider<AiMechanicBloc>.value(
        value: mockAiMechanicBloc,
        child: const MaterialApp(home: AiMechanicPage()),
      ),
    );

    await tester.pump();

    expect(find.text('Smart Mechanic AI'), findsOneWidget);
    expect(find.text('Mesin sering brebet'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);

    // MENGATASI PENDING TIMER DARI FLUTTER_ANIMATE:
    // Membuang sisa animasi loop agar tidak error saat widget dihancurkan
    await tester.pump(const Duration(milliseconds: 100));
  });
}