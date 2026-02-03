import '../../data/model/about_config_model.dart';

enum AboutConfigStatus { initial, loading, success, failure }

class AboutConfigState {
  final AboutConfigStatus status;
  final AboutConfigModel? config;
  final String? errorMessage;

  const AboutConfigState({
    this.status = AboutConfigStatus.initial,
    this.config,
    this.errorMessage,
  });

  AboutConfigState copyWith({
    AboutConfigStatus? status,
    AboutConfigModel? config,
    String? errorMessage,
  }) {
    return AboutConfigState(
      status: status ?? this.status,
      config: config ?? this.config,
      errorMessage: errorMessage,
    );
  }
}