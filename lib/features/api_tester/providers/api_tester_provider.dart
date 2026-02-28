import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';
import '../services/api_service.dart';
import '../utils/variable_resolver.dart';
import 'environment_provider.dart';
import '../../settings/providers/settings_provider.dart';

class ApiTesterState {
  final RequestModel request;
  final ResponseModel? response;
  final bool isLoading;
  final List<RequestModel> history;
  final List<CollectionModel> collections;
  final List<RequestModel> savedRequests;
  final String? activeCollectionId;

  const ApiTesterState({
    required this.request,
    this.response,
    this.isLoading = false,
    this.history = const [],
    this.collections = const [],
    this.savedRequests = const [],
    this.activeCollectionId,
  });

  ApiTesterState copyWith({
    RequestModel? request,
    ResponseModel? response,
    bool? isLoading,
    List<RequestModel>? history,
    List<CollectionModel>? collections,
    List<RequestModel>? savedRequests,
    String? activeCollectionId,
    bool clearResponse = false,
  }) {
    return ApiTesterState(
      request: request ?? this.request,
      response: clearResponse ? null : (response ?? this.response),
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      collections: collections ?? this.collections,
      savedRequests: savedRequests ?? this.savedRequests,
      activeCollectionId: activeCollectionId ?? this.activeCollectionId,
    );
  }
}

class ApiTesterNotifier extends StateNotifier<ApiTesterState> {
  final Ref _ref;
  static const _historyBoxName = 'api_history';
  static const _collectionsBoxName = 'api_collections';
  static const _savedReqBoxName = 'api_saved_requests';

  ApiTesterNotifier(this._ref)
      : super(ApiTesterState(
          request: RequestModel(id: const Uuid().v4()),
        )) {
    refreshData();
  }

  Future<void> refreshData() async {
    final historyBox = await Hive.openBox<String>(_historyBoxName);
    final collectionsBox = await Hive.openBox<String>(_collectionsBoxName);
    final savedBox = await Hive.openBox<String>(_savedReqBoxName);

    final history = historyBox.values
        .map((v) {
          try {
            return RequestModel.fromJson(jsonDecode(v));
          } catch (_) {
            return null;
          }
        })
        .whereType<RequestModel>()
        .toList()
        .reversed
        .toList();

    final collections = collectionsBox.values
        .map((v) {
          try {
            return CollectionModel.fromJson(jsonDecode(v));
          } catch (_) {
            return null;
          }
        })
        .whereType<CollectionModel>()
        .toList();

    final saved = savedBox.values
        .map((v) {
          try {
            return RequestModel.fromJson(jsonDecode(v));
          } catch (_) {
            return null;
          }
        })
        .whereType<RequestModel>()
        .toList();

    state = state.copyWith(
      history: history.take(20).toList(),
      collections: collections,
      savedRequests: saved,
    );
  }

  void updateMethod(String method) {
    state = state.copyWith(
        request: state.request.copyWith(method: method), clearResponse: true);
  }

  void updateUrl(String url) {
    // Parse query params from URL
    final uri = Uri.tryParse(url);
    Map<String, String> newParams = Map.from(state.request.params);
    
    if (uri != null && uri.hasQuery) {
      newParams = uri.queryParameters;
    } else if (uri != null && !url.contains('?')) {
      // If URL was cleared of params, clear the map
      newParams = {};
    }

    state = state.copyWith(
      request: state.request.copyWith(
        url: url,
        params: newParams,
      ),
    );
  }

  void updateHeaders(Map<String, String> headers) {
    state = state.copyWith(request: state.request.copyWith(headers: headers));
  }

  void updateParams(Map<String, String> params) {
    // Update URL with new params
    String url = state.request.url;
    final uri = Uri.tryParse(url);
    
    if (uri != null) {
      final newUri = uri.replace(queryParameters: params.isEmpty ? null : params);
      url = newUri.toString();
      // Remove trailing '?' if query is empty and it wasn't there before
      if (params.isEmpty && url.endsWith('?')) {
        url = url.substring(0, url.length - 1);
      }
    }

    state = state.copyWith(
      request: state.request.copyWith(
        params: params,
        url: url,
      ),
    );
  }

  void updateBody(String body) {
    state = state.copyWith(request: state.request.copyWith(body: body));
  }

  void updateBodyType(String type) {
    state = state.copyWith(request: state.request.copyWith(bodyType: type));
  }

  void updateBearerToken(String token) {
    state = state.copyWith(
        request: state.request.copyWith(bearerToken: token));
  }

  void updateBasicAuth(String user, String pass) {
    state = state.copyWith(
        request:
            state.request.copyWith(basicAuthUser: user, basicAuthPassword: pass));
  }

  void updateApiKey(String key, String header) {
    state = state.copyWith(
        request: state.request.copyWith(apiKey: key, apiKeyHeader: header));
  }

  void loadRequest(RequestModel req) {
    state = state.copyWith(request: req, clearResponse: true);
  }

  void newRequest() {
    state = ApiTesterState(
      request: RequestModel(id: const Uuid().v4()),
      history: state.history,
      collections: state.collections,
      savedRequests: state.savedRequests,
    );
  }

  Future<void> sendRequest() async {
    if (state.request.url.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, clearResponse: true);

    final env = _ref.read(environmentProvider).activeEnvironment;
    final variables = env?.variables ?? {};
    
    // Resolve variables for the one-off request
    final resolvedReq = state.request.copyWith(
      url: VariableResolver.resolve(state.request.url, variables),
      headers: VariableResolver.resolveMap(state.request.headers, variables),
      body: VariableResolver.resolve(state.request.body, variables),
    );

    final timeout = _ref.read(settingsProvider).requestTimeoutSeconds;
    final response = await ApiService.sendRequest(
      resolvedReq,
      timeoutSeconds: timeout,
    );

    // Save to history
    await _addToHistory(state.request);

    state = state.copyWith(isLoading: false, response: response);
  }

  Future<void> _addToHistory(RequestModel req) async {
    final box = await Hive.openBox<String>(_historyBoxName);
    // Remove older entries with same URL+method
    for (final key in box.keys.toList()) {
      try {
        final m = RequestModel.fromJson(jsonDecode(box.get(key)!));
        if (m.url == req.url && m.method == req.method) {
          await box.delete(key);
        }
      } catch (_) {}
    }
    await box.put(req.id, jsonEncode(req.toJson()));

    // Keep only last 20
    if (box.length > 20) {
      final keys = box.keys.toList();
      await box.delete(keys.first);
    }

    await refreshData();
  }

  Future<void> saveToCollection(String collectionId, {String? name}) async {
    final savedBox = await Hive.openBox<String>(_savedReqBoxName);
    final req = state.request.copyWith(collectionId: collectionId, name: name);
    await savedBox.put(req.id, jsonEncode(req.toJson()));
    await refreshData();
  }

  Future<void> createCollection(String name) async {
    final box = await Hive.openBox<String>(_collectionsBoxName);
    final col = CollectionModel(
      id: const Uuid().v4(),
      name: name,
      requestIds: [],
      createdAt: DateTime.now(),
    );
    await box.put(col.id, jsonEncode(col.toJson()));
    await refreshData();
  }

  Future<void> clearHistory() async {
    final box = await Hive.openBox<String>(_historyBoxName);
    await box.clear();
    await refreshData();
  }
}

final apiTesterProvider =
    StateNotifierProvider<ApiTesterNotifier, ApiTesterState>(
  (ref) => ApiTesterNotifier(ref),
);
