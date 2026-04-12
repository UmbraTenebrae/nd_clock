import 'package:home_widget/home_widget.dart';
import '../models/app_settings.dart';
import '../models/view_type.dart';
import '../utils/time_utils.dart';

/// Pushes current progress state to the Android home screen widget.
/// iOS WidgetKit is not wired up (requires Xcode to add the extension target).
class WidgetService {
  static const _androidProvider = 'PrismWidgetProvider';

  static Future<void> update(AppSettings settings, DateTime now) async {
    final view = settings.activeView;
    final progress = progressFor(view, now, settings);
    final displayLabel = currentDisplayLabel(view, now, settings);
    final countdown = countdownLabel(view, now, settings);

    await HomeWidget.saveWidgetData<double>('prism_progress', progress);
    await HomeWidget.saveWidgetData<String>('prism_view_label', view.label);
    await HomeWidget.saveWidgetData<String>('prism_display_label', displayLabel);
    await HomeWidget.saveWidgetData<String>('prism_countdown', countdown);

    await HomeWidget.updateWidget(
      androidName: _androidProvider,
      qualifiedAndroidName: 'com.ndclock.nd_clock.$_androidProvider',
    );
  }
}
