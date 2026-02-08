import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/audio_player/audio_player_streams.dart';
import 'package:spotube/provider/connect/clients.dart';
import 'package:spotube/provider/metadata_plugin/audio_source/quality_presets.dart';
import 'package:spotube/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:spotube/provider/metadata_plugin/updater/update_checker.dart';
import 'package:spotube/provider/server/bonsoir.dart';
import 'package:spotube/provider/server/server.dart';
import 'package:spotube/provider/tray_manager/tray_manager.dart';

/// Hook to initialize all app-level providers that need to be active
/// throughout the app lifecycle. This consolidates multiple ref.listen
/// calls into a single reusable hook for better maintainability.
/// 
/// These providers typically:
/// - Set up event listeners
/// - Initialize background services
/// - Manage system integrations (tray, server, etc.)
void useAppInitializers(WidgetRef ref) {
  // Audio player stream listeners for playback events
  ref.listen(audioPlayerStreamListenersProvider, (_, __) {});
  
  // Network discovery and connectivity
  ref.listen(bonsoirProvider, (_, __) {});
  ref.listen(connectClientsProvider, (_, __) {});
  ref.listen(serverProvider, (_, __) {});
  
  // System integrations
  ref.listen(trayManagerProvider, (_, __) {});
  
  // Plugin system
  ref.listen(metadataPluginsProvider, (_, __) {});
  ref.listen(metadataPluginProvider, (_, __) {});
  ref.listen(audioSourcePluginProvider, (_, __) {});
  
  // Update checkers
  ref.listen(metadataPluginUpdateCheckerProvider, (_, __) {});
  ref.listen(audioSourcePluginUpdateCheckerProvider, (_, __) {});
}