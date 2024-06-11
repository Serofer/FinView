//lib/user_data/timeframe_manager.dart

class TimeframeManager {
  static final TimeframeManager _instance = TimeframeManager._internal();
  
  factory TimeframeManager() {
    return _instance;
  }
  
  TimeframeManager._internal();

  String _selectedTimeframe = 'Last 7 Days';

  String get selectedTimeframe => _selectedTimeframe;

  set selectedTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
  }
}