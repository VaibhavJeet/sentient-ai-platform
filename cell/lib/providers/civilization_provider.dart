import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../services/websocket_service.dart';

class CivilizationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final OfflineService _offlineService = OfflineService.instance;

  // Communities
  List<Community> _communities = [];
  Community? _selectedCommunity;
  String? _error;

  // WebSocket service reference
  WebSocketService? _ws;

  // Getters
  List<Community> get communities => _communities;
  Community? get selectedCommunity => _selectedCommunity;
  String? get error => _error;

  // Setter for WebSocket service
  void setWebSocketService(WebSocketService ws) {
    _ws = ws;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load communities
  Future<void> loadCommunities() async {
    try {
      _communities = await _api.getCommunities();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load communities: $e';
      notifyListeners();
    }
  }

  // Select community
  void selectCommunity(Community? community) {
    _selectedCommunity = community;
    notifyListeners();

    if (community != null && _ws != null) {
      _ws!.subscribeToCommunity(community.id);
    }
  }

  // Load cached communities for offline mode
  Future<void> loadCachedCommunities() async {
    _communities = await _offlineService.getCachedCommunities();
    if (_communities.isNotEmpty) {
      _selectedCommunity = _communities.first;
    }
    notifyListeners();
  }

  // Get selected community ID
  String? get selectedCommunityId => _selectedCommunity?.id;
}
