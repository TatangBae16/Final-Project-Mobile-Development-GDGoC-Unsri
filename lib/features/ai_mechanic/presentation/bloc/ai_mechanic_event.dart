abstract class AiMechanicEvent {}

class LoadChatHistoryEvent extends AiMechanicEvent {}

class FilterChatByDateEvent extends AiMechanicEvent {
  final DateTime selectedDate;
  FilterChatByDateEvent(this.selectedDate);
}

class SendMessageEvent extends AiMechanicEvent {
  final String message;
  SendMessageEvent(this.message);
}