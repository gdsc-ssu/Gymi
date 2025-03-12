import 'dart:math';

/// Manages a collection of OneEuroFilters for filtering multiple values.
class OneEuroFilterManager {
  static const double _defaultFrequency = 30.0;
  static const double _defaultMinCutOFF = 1.0;
  static const double _defaultBeta = 0.007;
  static const double _defaultDCutOFF = 1.0;

  late final List<_OneEuroFilter> _filters;
  late final List<double> _filteredValues;
  late double _freq, _minCutOff, _beta, _dCutOff;

  /// OneEuroFilterManager constructor.
  ///
  /// [count]: The number of values to filter. For example, if set to 2, it filters two input values separately.
  /// [freq]: /// [freq]: Represents the sampling frequency of the data. The default value is [_defaultFrequency].
  /// [minCutOff]: Minimum cutoff frequency used to filter noise in the data. The default value is [_defaultMinCutOFF].
  /// [beta]: Indicates the strength of applying the derivative filter. The default value is [_defaultBeta].
  /// [dCutOff]: Represents the cutoff frequency for the derivative data. The default value is [_defaultDCutOFF].
  ///
  /// Use this constructor to initialize the filter and specify the number of values to filter and the filter's settings.
  ///
  OneEuroFilterManager(
      {required int count,
      freq = _defaultFrequency,
      minCutOff = _defaultMinCutOFF,
      beta = _defaultBeta,
      dCutOff = _defaultDCutOFF}) {
    _freq = freq <= 0 ? _defaultFrequency : freq;
    _minCutOff = minCutOff <= 0 ? _defaultMinCutOFF : minCutOff;
    _dCutOff = dCutOff <= 0 ? _defaultDCutOFF : dCutOff;
    _beta = beta;
    _filters = List<_OneEuroFilter>.generate(
        count, (idx) => _OneEuroFilter(_freq, _minCutOff, _beta, _dCutOff));
    _filteredValues = List<double>.filled(count, 0.0);
  }

  /// Performs filtering for the given timestamp and a list of values.
  ///
  /// [timestamp]: Represents the timestamp of the data and is used for filtering.
  /// [val]: A list of values to be filtered, representing the values for which you want to obtain filtered results.
  ///
  /// Filtered values are stored in [_filteredValues]. If a value is invalid or anomalous, the filter is reset, and false is returned.
  /// If the filtering is successful, it returns true.
  ///
  /// Use this method to perform filtering on the given data and obtain the filtered results. If filtering fails or if there are invalid values, the filter is reset, and false is returned.
  ///
  bool filterValues(int timestamp, List<double> val) {
    if (val.length != _filters.length) {
      return false;
    }

    try {
      for (int idx = 0; idx < val.length; ++idx) {
        double filteredVal =
            _filters[idx].filter(val[idx], timestamp: timestamp);
        if (_isInvalidValue(filteredVal)) {
          _initFilters();
          return false;
        } else {
          _filteredValues[idx] = filteredVal;
        }
      }
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  /// Retrieves the filtered values obtained after applying the filter.
  ///
  /// This function returns a list of filtered double values that have been processed
  /// using the filter. It allows you to access the filtered results for further use.
  ///
  /// Returns:
  /// A list of filtered double values.
  ///
  List<double> getFilteredValues() {
    return _filteredValues;
  }

  void _initFilters() {
    for (int i = 0; i < _filters.length; i++) {
      _filters[i] = _OneEuroFilter(_freq, _minCutOff, _beta, _dCutOff);
    }
  }

  bool _isInvalidValue(double val) {
    return val.isInfinite || val.isNaN;
  }
}

class _OneEuroFilter {
  late double freq, minCutOff, beta, dCutOff;
  late _LowPassFilter _x, _dx;
  late int lastTime;
  static const int _undefinedTime = -1;

  double _alpha(double cutoff) {
    double te = 1.0 / freq;
    double tau = 1.0 / (2 * pi * cutoff);
    return 1.0 / (1.0 + tau / te);
  }

  _OneEuroFilter(this.freq, this.minCutOff, this.beta, this.dCutOff) {
    _x = _LowPassFilter(alpha: _alpha(minCutOff));
    _dx = _LowPassFilter(alpha: _alpha(dCutOff));
    lastTime = _undefinedTime;
  }

  double filter(double value, {int timestamp = _undefinedTime}) {
    if (lastTime != _undefinedTime && timestamp != _undefinedTime) {
      freq = 1000.0 / (timestamp - lastTime);
    }

    if (timestamp != _undefinedTime) {
      lastTime = timestamp;
    }

    double dvalue =
        _x.hasLastRawValue() ? (value - _x.lastRawValue()) * freq : 0.0;
    double edvalue = _dx.filterWithAlpha(dvalue, _alpha(dCutOff));

    double cutoff = minCutOff + beta * edvalue.abs();
    return _x.filterWithAlpha(value, _alpha(cutoff));
  }
}

class _LowPassFilter {
  late double y, a, s;
  bool initialized = false;

  void _setAlpha(double alpha) {
    if (alpha <= 0.0 || alpha > 1.0) {
      throw Exception("alpha should be in (0.0, 1.0)");
    }
    a = alpha;
  }

  _LowPassFilter({required double alpha, double initVal = 0}) {
    y = initVal;
    s = initVal;
    initialized = initVal != 0;
    _setAlpha(alpha);
  }

  double filter(double value) {
    double result;
    if (initialized) {
      result = a * value + (1.0 - a) * s;
    } else {
      result = value;
      initialized = true;
    }
    y = value;
    s = result;
    return result;
  }

  double filterWithAlpha(double value, double alpha) {
    _setAlpha(alpha);
    return filter(value);
  }

  bool hasLastRawValue() {
    return initialized;
  }

  double lastRawValue() {
    return y;
  }
}
