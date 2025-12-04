import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sound_service.dart';

/// Провайдер сервиса вибрации
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  service.init();
  return service;
});
