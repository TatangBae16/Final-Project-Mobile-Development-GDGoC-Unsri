abstract class AiMechanicState {}

class AiMechanicInitial extends AiMechanicState {}

class AiMechanicLoaded extends AiMechanicState {
  final List<Map<String, dynamic>> chatHistory;
  final bool isWaitingForAi;
  final DateTime? filterDate; // Penanda jika user sedang mem-filter tanggal

  AiMechanicLoaded(this.chatHistory, {this.isWaitingForAi = false, this.filterDate});
}

class AiMechanicError extends AiMechanicState {
  final String errorMessage;
  AiMechanicError(this.errorMessage);
}