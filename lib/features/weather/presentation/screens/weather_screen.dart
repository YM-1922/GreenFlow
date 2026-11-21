import 'package:flutter/material.dart';
import '../../domain/entities/weather_entities.dart';
import '../../data/datasources/weather_mock_data_source.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _dataSource = WeatherMockDataSource.instance;
  late CurrentWeatherEntity _current;
  late List<WeatherDayEntity> _forecast;
  late List<AgronomicRecommendationEntity> _recommendations;

  @override
  void initState() {
    super.initState();
    _current = _dataSource.getCurrentWeather();
    _forecast = _dataSource.getFiveDayForecast();
    _recommendations = _dataSource.getRecommendations();
  }

  bool get _isArabic {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }

  String _t(String en, String ar) => _isArabic ? ar : en;

  IconData _weatherIcon(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return Icons.beach_access_rounded;
      case WeatherCondition.windy:
        return Icons.air_rounded;
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm_rounded;
    }
  }

  Color _weatherIconColor(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return Colors.amber;
      case WeatherCondition.partlyCloudy:
        return Colors.blueGrey;
      case WeatherCondition.cloudy:
        return Colors.grey;
      case WeatherCondition.rainy:
        return Colors.blue;
      case WeatherCondition.windy:
        return Colors.teal;
      case WeatherCondition.thunderstorm:
        return Colors.purple;
    }
  }

  String _conditionLabel(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return _t('Sunny', 'مشمس');
      case WeatherCondition.partlyCloudy:
        return _t('Partly Cloudy', 'غائم جزئياً');
      case WeatherCondition.cloudy:
        return _t('Cloudy', 'غائم');
      case WeatherCondition.rainy:
        return _t('Rainy', 'ممطر');
      case WeatherCondition.windy:
        return _t('Windy', 'عاصف');
      case WeatherCondition.thunderstorm:
        return _t('Thunderstorm', 'عاصفة رعدية');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    const primaryGreen = Color(0xFF10B981);
    const navyBlue = Color(0xFF0F172A);
    const cyanAccent = Color(0xFF06B6D4);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('Weather & Forecasts', 'الطقس والتوقعات'),
          style: TextStyle(
            color: isDark ? Colors.white : navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _current = _dataSource.getCurrentWeather();
                _forecast = _dataSource.getFiveDayForecast();
                _recommendations = _dataSource.getRecommendations();
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Hero Current Weather Card ─────────────────────────────
          _CurrentWeatherCard(
            entity: _current,
            weatherIcon: _weatherIcon(_current.condition),
            weatherIconColor: _weatherIconColor(_current.condition),
            conditionLabel: _conditionLabel(_current.condition),
            isArabic: _isArabic,
            primaryGreen: primaryGreen,
            navyBlue: navyBlue,
          ),
          const SizedBox(height: 20),

          // ── 5-Day Forecast ─────────────────────────────────────────
          Text(
            _t('5-Day Forecast', 'توقعات 5 أيام'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : navyBlue,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final day = _forecast[i];
                return _ForecastCard(
                  day: day,
                  weatherIcon: _weatherIcon(day.condition),
                  weatherIconColor: _weatherIconColor(day.condition),
                  conditionLabel: _conditionLabel(day.condition),
                  isArabic: _isArabic,
                  navyBlue: navyBlue,
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── Rain Probability Bar Chart ─────────────────────────────
          Text(
            _t('Rain Probability (%)', 'احتمالية هطول الأمطار (٪)'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : navyBlue,
            ),
          ),
          const SizedBox(height: 10),
          _RainBarChart(
            forecast: _forecast,
            isArabic: _isArabic,
            cyanAccent: cyanAccent,
            navyBlue: navyBlue,
          ),
          const SizedBox(height: 20),

          // ── Smart Irrigation Recommendations ──────────────────────
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: primaryGreen, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _t('Smart Irrigation Recommendations', 'توصيات الري الذكية'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : navyBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecommendationCard(
                entity: rec,
                isArabic: _isArabic,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Disclaimer ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t(
                      'Demo weather data – Connect to OpenWeatherMap API for live forecasts',
                      'بيانات طقس تجريبية – اربط بـ OpenWeatherMap API للحصول على توقعات حية',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Current Weather Hero Card ──────────────────────────────────────────────

class _CurrentWeatherCard extends StatelessWidget {
  final CurrentWeatherEntity entity;
  final IconData weatherIcon;
  final Color weatherIconColor;
  final String conditionLabel;
  final bool isArabic;
  final Color primaryGreen;
  final Color navyBlue;

  const _CurrentWeatherCard({
    required this.entity,
    required this.weatherIcon,
    required this.weatherIconColor,
    required this.conditionLabel,
    required this.isArabic,
    required this.primaryGreen,
    required this.navyBlue,
  });

  String _t(String en, String ar) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : navyBlue;
    final subtextColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF182740), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location row
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: primaryGreen, size: 16),
              const SizedBox(width: 4),
              Text(
                isArabic ? entity.locationAr : entity.locationEn,
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_t('Updated', 'آخر تحديث')} ${entity.lastUpdated}',
                style: TextStyle(color: subtextColor, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Temperature + icon row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(weatherIcon, size: 72, color: weatherIconColor),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entity.tempCelsius.toStringAsFixed(0)}°C',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    conditionLabel,
                    style: TextStyle(
                      fontSize: 18,
                      color: weatherIconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_t('Feels like', 'يبدو مثل')} ${entity.feelsLikeCelsius.toStringAsFixed(0)}°C',
                    style: TextStyle(color: subtextColor, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                icon: Icons.water_drop_rounded,
                label: _t('Humidity', 'الرطوبة'),
                value: '${entity.humidityPercent.toStringAsFixed(0)}%',
                color: const Color(0xFF06B6D4),
              ),
              _StatChip(
                icon: Icons.air_rounded,
                label: _t('Wind', 'الرياح'),
                value: '${entity.windKmh.toStringAsFixed(0)} km/h',
                color: Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 5-Day Forecast Card ────────────────────────────────────────────────────

class _ForecastCard extends StatelessWidget {
  final WeatherDayEntity day;
  final IconData weatherIcon;
  final Color weatherIconColor;
  final String conditionLabel;
  final bool isArabic;
  final Color navyBlue;

  const _ForecastCard({
    required this.day,
    required this.weatherIcon,
    required this.weatherIconColor,
    required this.conditionLabel,
    required this.isArabic,
    required this.navyBlue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : navyBlue;
    final subtextColor = isDark ? Colors.white60 : Colors.grey.shade600;

    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182740) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isArabic ? day.dayAr : day.dayEn,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
              fontSize: 13,
            ),
          ),
          Icon(weatherIcon, color: weatherIconColor, size: 32),
          Text(
            '${day.highCelsius.toStringAsFixed(0)}° / ${day.lowCelsius.toStringAsFixed(0)}°',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: 12,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop_rounded,
                  size: 11, color: Colors.blue.shade300),
              const SizedBox(width: 2),
              Text(
                '${day.rainProbabilityPercent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, color: subtextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rain Probability Bar Chart ─────────────────────────────────────────────

class _RainBarChart extends StatelessWidget {
  final List<WeatherDayEntity> forecast;
  final bool isArabic;
  final Color cyanAccent;
  final Color navyBlue;

  const _RainBarChart({
    required this.forecast,
    required this.isArabic,
    required this.cyanAccent,
    required this.navyBlue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade700;
    const maxBarHeight = 80.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182740) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: forecast.map((day) {
          final pct = day.rainProbabilityPercent;
          final barH = maxBarHeight * (pct / 100);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 10, color: textColor),
              ),
              const SizedBox(height: 4),
              Container(
                width: 28,
                height: barH.clamp(4.0, maxBarHeight),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cyanAccent.withValues(alpha: 0.7),
                      cyanAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? day.dayAr : day.dayEn,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Recommendation Card ────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final AgronomicRecommendationEntity entity;
  final bool isArabic;

  const _RecommendationCard({
    required this.entity,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182740) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entity.color.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: entity.color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: entity.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entity.icon, color: entity.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? entity.titleAr : entity.titleEn,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: entity.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic ? entity.bodyAr : entity.bodyEn,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
