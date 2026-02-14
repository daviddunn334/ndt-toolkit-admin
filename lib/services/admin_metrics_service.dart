import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMetricsService {
  static final AdminMetricsService _instance = AdminMetricsService._internal();
  factory AdminMetricsService() => _instance;
  AdminMetricsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _metricsDoc =>
      _firestore.collection('admin_metrics').doc('cost_reliability');

  Future<Map<String, dynamic>> getMetrics() async {
    try {
      final snapshot = await _metricsDoc.get();
      return snapshot.data() ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<void> incrementStorageUpload({String source = 'unknown'}) async {
    await _metricsDoc.set({
      'storage_uploads_total': FieldValue.increment(1),
      'storage_uploads_by_source.$source': FieldValue.increment(1),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> incrementFunctionCall({
    required String name,
    required bool success,
  }) async {
    await _metricsDoc.set({
      'function_calls_total': FieldValue.increment(1),
      'function_calls_failed': FieldValue.increment(success ? 0 : 1),
      'function_calls_by_name.$name': FieldValue.increment(1),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> recordError({required String screen}) async {
    await _metricsDoc.set({
      'error_events_total': FieldValue.increment(1),
      'error_events_by_screen.$screen': FieldValue.increment(1),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> incrementToolUsage({required String toolName}) async {
    await _metricsDoc.set({
      'tool_usage_total': FieldValue.increment(1),
      'tool_usage_by_name.$toolName': FieldValue.increment(1),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}