import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ai_mechanic_repository.dart';
import 'ai_mechanic_event.dart';
import 'ai_mechanic_state.dart';

class AiMechanicBloc extends Bloc<AiMechanicEvent, AiMechanicState> {
  final AiMechanicRepository repository;

  AiMechanicBloc({required this.repository}) : super(AiMechanicInitial()) {

    on<LoadChatHistoryEvent>((event, emit) async {
      try {
        final history = await repository.getChatHistory();
        emit(AiMechanicLoaded(history)); // Menampilkan semua chat
      } catch (e) {
        emit(AiMechanicError("Gagal memuat riwayat chat: ${e.toString()}"));
      }
    });

    // Event Baru: Menyaring chat berdasarkan kalender
    on<FilterChatByDateEvent>((event, emit) async {
      emit(AiMechanicInitial()); // Tampilkan loading sejenak
      try {
        final filteredHistory = await repository.getChatHistoryByDate(event.selectedDate);
        emit(AiMechanicLoaded(filteredHistory, filterDate: event.selectedDate));
      } catch (e) {
        emit(AiMechanicError("Gagal memfilter chat: ${e.toString()}"));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      List<Map<String, dynamic>> currentHistory = [];

      // Jika user mengirim pesan saat sedang mem-filter tanggal lampau,
      // kita otomatis hapus filternya agar pesan barunya terlihat (kembali ke masa kini)
      if (state is AiMechanicLoaded) {
        if ((state as AiMechanicLoaded).filterDate == null) {
          currentHistory = List.from((state as AiMechanicLoaded).chatHistory);
        } else {
          // Jika sedang difilter, tarik ulang semua history terbaru
          currentHistory = await repository.getChatHistory();
        }
      }

      // Optimistic Update: Menambahkan waktu (created_at) ke layar secara instan
      currentHistory.add({
        'message': event.message,
        'is_user': true,
        'created_at': DateTime.now().toUtc().toIso8601String(), // Waktu saat ini
      });

      emit(AiMechanicLoaded(currentHistory, isWaitingForAi: true));

      try {
        final aiResponse = await repository.getDiagnosticAdvice(event.message);

        currentHistory.add({
          'message': aiResponse,
          'is_user': false,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });

        emit(AiMechanicLoaded(currentHistory, isWaitingForAi: false));
      } catch (e) {
        emit(AiMechanicError("Gagal menghubungi mekanik: ${e.toString()}"));
      }
    });
  }
}