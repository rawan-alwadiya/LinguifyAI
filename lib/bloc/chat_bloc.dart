import 'package:LinguifyAI/api/api_models/chat_response_model.dart';
import 'package:LinguifyAI/api/chat_api_controller.dart';
import 'package:LinguifyAI/database/chat_db_operations.dart';
import 'package:LinguifyAI/models/chat_message_model.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_events.dart';
import 'chat_states.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  final ChatDatabaseOperations _dbOperations = ChatDatabaseOperations();
  final ChatApiController _chatApiController = ChatApiController();
  String? userId = SharedPrefController.instance.getUserId();

  ChatBloc(super.initialState) {
    on<SendMessageEvent>(_onSendMessage);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<DeleteLastMessageEvent>(_onDeleteLastMessage);
    on<DeleteChatHistoryEvent>(_onDeleteChatHistory);

    add(LoadMessagesEvent());
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      //Save user's message immediately
      await _dbOperations.saveMessage(event.message, event.isUser);
      emit(ChatLoaded(await _dbOperations.getMessages()));

      // Add a temporary 'typing...' message
      await _dbOperations.saveMessage('typing...', false);
      emit(ChatLoaded(await _dbOperations.getMessages()));

      //Make the API request
      ChatResponse chatResponse = await (userId != null
          ? _chatApiController.sendChat(event.message, userId)
          : _chatApiController.sendChat(event.message, null));

      // Remove the 'typing...' message
      await _dbOperations.deleteLastMessage();
      await _dbOperations.saveMessage(chatResponse.response, false);
      emit(ChatLoaded(await _dbOperations.getMessages()));

    } catch (e) {
      await _dbOperations.deleteLastMessage();
      await _dbOperations.saveMessage('An error occurred. Please try again.', false);
      emit(ChatLoaded(await _dbOperations.getMessages()));
    }
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      final messages = await _dbOperations.getMessages();
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
  
  Future<void> _onDeleteLastMessage(DeleteLastMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _dbOperations.deleteLastMessage();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onDeleteChatHistory(DeleteChatHistoryEvent event, Emitter<ChatState> emit) async {
    try {
      await _dbOperations.deleteChatHistory();
      emit(ChatLoaded([]));  // Emit an empty list to clear the UI
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}