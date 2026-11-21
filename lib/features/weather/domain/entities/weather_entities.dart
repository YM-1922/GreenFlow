import 'package:flutter/material.dart';

enum WeatherCondition { sunny, partlyCloudy, cloudy, rainy, windy, thunderstorm }

class WeatherDayEntity {
  final String dayEn;
  final String dayAr;
  final WeatherCondition condition;
  final double highCelsius;
  final double lowCelsius;
  final double humidityPercent;
  final double rainProbabilityPercent;
  final double windKmh;
  final double solarRadiationWm2;

  const WeatherDayEntity({
    required this.dayEn,
    required this.dayAr,
    required this.condition,
    required this.highCelsius,
    required this.lowCelsius,
    required this.humidityPercent,
    required this.rainProbabilityPercent,
    required this.windKmh,
    required this.solarRadiationWm2,
  });
}

class CurrentWeatherEntity {
  final double tempCelsius;
  final double feelsLikeCelsius;
  final double humidityPercent;
  final double windKmh;
  final WeatherCondition condition;
  final String locationEn;
  final String locationAr;
  final String lastUpdated;

  const CurrentWeatherEntity({
    required this.tempCelsius,
    required this.feelsLikeCelsius,
    required this.humidityPercent,
    required this.windKmh,
    required this.condition,
    required this.locationEn,
    required this.locationAr,
    required this.lastUpdated,
  });
}

class AgronomicRecommendationEntity {
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final IconData icon;
  final Color color;

  const AgronomicRecommendationEntity({
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.icon,
    required this.color,
  });
}
