class TimeframeManager {
  static final TimeframeManager _instance = TimeframeManager._internal();
  
  factory TimeframeManager() {
    return _instance;
  }
  
  TimeframeManager._internal();

  String _selectedTimeframe = 'This Year';
  int _groupedSections = 0;
  int _timeshift = 0;

  String get selectedTimeframe => _selectedTimeframe;

  set selectedTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
  }

  int get groupedSections => _groupedSections;

  set groupedSections(int sections) {
    _groupedSections = sections;
  }

  int get timeshift => _timeshift;

  set timeshift(int shift) {
    _timeshift = shift;
  }
  
}
