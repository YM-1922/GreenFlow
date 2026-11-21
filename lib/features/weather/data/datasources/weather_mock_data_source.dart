import 'package:flutter/material.dart';
import '../../domain/entities/weather_entities.dart';

class WeatherMockDataSource {
  WeatherMockDataSource._();
  static final WeatherMockDataSource instance = WeatherMockDataSource._();

  CurrentWeatherEntity getCurrentWeather() {
    return const CurrentWeatherEntity(
      tempCelsius: 28,
      feelsLikeCelsius: 31,
      humidityPercent: 55,
      windKmh: 18,
      condition: WeatherCondition.sunny,
      locationEn: 'Al-Fayyum, Egypt',
      locationAr: 'الفيوم، مصر',
      lastUpdated: '06:30 AM',
    );
  }

  List<WeatherDayEntity> getFiveDayForecast() {
    return const [
      WeatherDayEntity(
        dayEn: 'Mon',
        dayAr: 'الإثنين',
        condition: WeatherCondition.sunny,
        highCelsius: 30,
        lowCelsius: 21,
        humidityPercent: 50,
        rainProbabilityPercent: 5,
        windKmh: 16,
        solarRadiationWm2: 820,
      ),
      WeatherDayEntity(
        dayEn: 'Tue',
        dayAr: 'الثلاثاء',
        condition: WeatherCondition.partlyCloudy,
        highCelsius: 28,
        lowCelsius: 20,
        humidityPercent: 58,
        rainProbabilityPercent: 15,
        windKmh: 20,
        solarRadiationWm2: 650,
      ),
      WeatherDayEntity(
        dayEn: 'Wed',
        dayAr: 'الأربعاء',
        condition: WeatherCondition.partlyCloudy,
        highCelsius: 27,
        lowCelsius: 19,
        humidityPercent: 62,
        rainProbabilityPercent: 20,
        windKmh: 22,
        solarRadiationWm2: 580,
      ),
      WeatherDayEntity(
        dayEn: 'Thu',
        dayAr: 'الخميس',
        condition: WeatherCondition.rainy,
        highCelsius: 24,
        lowCelsius: 17,
        humidityPercent: 80,
        rainProbabilityPercent: 60,
        windKmh: 28,
        solarRadiationWm2: 300,
      ),
      WeatherDayEntity(
        dayEn: 'Fri',
        dayAr: 'الجمعة',
        condition: WeatherCondition.cloudy,
        highCelsius: 26,
        lowCelsius: 18,
        humidityPercent: 70,
        rainProbabilityPercent: 30,
        windKmh: 18,
        solarRadiationWm2: 450,
      ),
    ];
  }

  List<AgronomicRecommendationEntity> getRecommendations() {
    return const [
      AgronomicRecommendationEntity(
        titleEn: '🌿 Optimal Irrigation Window',
        titleAr: '🌿 نافذة الري المثلى',
        bodyEn:
            'Weather forecast shows no rain for 3 days. Recommend irrigating tomorrow morning 06:00–08:00 for maximum efficiency.',
        bodyAr:
            'تُظهر توقعات الطقس عدم سقوط أمطار لمدة 3 أيام. يُنصح بالري صباح الغد من 06:00 حتى 08:00 لتحقيق أقصى كفاءة.',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF10B981),
      ),
      AgronomicRecommendationEntity(
        titleEn: '🌡 Heat Stress Alert',
        titleAr: '🌡 تحذير إجهاد حراري',
        bodyEn:
            'High temperatures expected (30°C+). Increase irrigation frequency for sensitive crops.',
        bodyAr:
            'تُتوقع درجات حرارة مرتفعة (أكثر من 30 درجة). زِد تكرار الري للمحاصيل الحساسة.',
        icon: Icons.thermostat_rounded,
        color: Color(0xFFF59E0B),
      ),
      AgronomicRecommendationEntity(
        titleEn: '☔ Rain Expected Day 4',
        titleAr: '☔ أمطار متوقعة اليوم الرابع',
        bodyEn:
            'Skip scheduled irrigation on Thursday. Forecast shows 60% rain probability.',
        bodyAr:
            'تخطَّ جدول الري المقرر يوم الخميس. تشير التوقعات إلى احتمال 60٪ لسقوط الأمطار.',
        icon: Icons.umbrella_rounded,
        color: Color(0xFF06B6D4),
      ),
    ];
  }
}
