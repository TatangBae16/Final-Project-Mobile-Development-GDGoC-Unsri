// Lokasi: test/ai_mechanic/ai_mechanic_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_midtermproject/features/ai_mechanic/presentation/bloc/ai_mechanic_bloc.dart';
import 'package:md_midtermproject/features/ai_mechanic/presentation/bloc/ai_mechanic_event.dart';
import 'package:md_midtermproject/features/ai_mechanic/presentation/bloc/ai_mechanic_state.dart';
import 'package:md_midtermproject/features/ai_mechanic/data/repositories/ai_mechanic_repository.dart';

class FakeAiMechanicRepository extends Fake implements AiMechanicRepository {
  bool isSuccess = true;

  @override
  Future<String> getDiagnosis(String symptom) async {
    if (isSuccess) {
      return 'Periksa bagian busi dan sistem pengapian motor Anda.';
    } else {
      throw Exception('Gagal memproses diagnosa AI');
    }
  }
}

void main() {
  group('AiMechanicBloc Unit Test', () {
    late FakeAiMechanicRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAiMechanicRepository();
    });

    blocTest<AiMechanicBloc, AiMechanicState>(
      'Memancarkan state Loaded lalu Error saat mengirim pesan',
      build: () => AiMechanicBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(SendMessageEvent('Mesin motor sering mati mendadak')),
      expect: () => [
        isA<AiMechanicLoaded>(),
        isA<AiMechanicError>(),
      ],
    );

    blocTest<AiMechanicBloc, AiMechanicState>(
      'Memancarkan state Loaded lalu Error saat repositori gagal',
      build: () {
        fakeRepo.isSuccess = false;
        return AiMechanicBloc(repository: fakeRepo);
      },
      act: (bloc) => bloc.add(SendMessageEvent('Gejala rusak')),
      expect: () => [
        isA<AiMechanicLoaded>(),
        isA<AiMechanicError>(),
      ],
    );
  });
}