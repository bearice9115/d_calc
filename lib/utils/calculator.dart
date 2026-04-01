import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:klc/klc.dart' as klc;

class Calculator {
  static DateTime get today => DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

  // 1. 생일 기준 정보 계산 (음력 지원)
  static Map<String, int> getDetailedProgress(DateTime birthday, bool isLunar) {
    DateTime solarDate;
    try {
      if (isLunar) {
        klc.setLunarDate(birthday.year, birthday.month, birthday.day, false);
        int sy = klc.getSolarYear();
        int sm = klc.getSolarMonth();
        int sd = klc.getSolarDay();
        if (sy < 1900) sy = birthday.year;
        solarDate = DateTime(sy, sm, sd);
      } else {
        solarDate = DateTime(birthday.year, birthday.month, birthday.day);
      }
    } catch (e) {
      debugPrint('날짜 변환 에러: $e');
      solarDate = birthday;
    }

    final int totalDays = today.difference(solarDate).inDays + 1;
    
    int age = today.year - solarDate.year;
    if (today.month < solarDate.month || (today.month == solarDate.month && today.day < solarDate.day)) {
      age--;
    }
    return {
      'age': age < 0 ? 0 : age,
      'days': totalDays < 1 ? 1 : totalDays,
      'weeks': totalDays ~/ 7,
      'months': totalDays ~/ 30,
    };
  }

  // 2. 상세 경과 텍스트 (O년 O개월 O일)
  static String getDetailedElapsedText(DateTime start) {
    int y = today.year - start.year;
    int m = today.month - start.month;
    int d = today.day - start.day;
    if (d < 0) {
      m -= 1;
      d += DateTime(today.year, today.month, 0).day;
    }
    if (m < 0) {
      y -= 1;
      m += 12;
    }
    List<String> parts = [];
    if (y > 0) parts.add('$y년');
    if (m > 0) parts.add('$m개월');
    if (d > 0) parts.add('$d일');
    return parts.isEmpty ? "오늘" : parts.join(' ');
  }

  // 3. 별자리 계산 함수 (양력 기준)
  static String getConstellation(int month, int day) {
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "물병자리";
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return "물고기자리";
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "양자리";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "황소자리";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return "쌍둥이자리";
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return "게자리";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "사자자리";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 23)) return "처녀자리";
    if ((month == 9 && day >= 24) || (month == 10 && day <= 22)) return "천칭자리";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 22)) return "전갈자리";
    if ((month == 11 && day >= 23) || (month == 12 && day <= 24)) return "사수자리";
    return "염소자리";
  }

  // 4. 하이브리드 사주/매칭 로직 (별자리 추가)
  static Map<String, String> getFullMatches(DateTime birthday, bool isLunar) {
    int lYear;
    try {
      if (isLunar) lYear = birthday.year;
      else {
        klc.setSolarDate(birthday.year, birthday.month, birthday.day);
        lYear = klc.getLunarYear();
      }
    } catch (_) { lYear = birthday.year; }

    int sMonth, sDay;
    try {
      if (isLunar) {
        klc.setLunarDate(birthday.year, birthday.month, birthday.day, false);
        sMonth = klc.getSolarMonth();
        sDay = klc.getSolarDay();
      } else {
        sMonth = birthday.month;
        sDay = birthday.day;
      }
    } catch (_) { sMonth = birthday.month; sDay = birthday.day; }

    int safeMonthIndex = (sMonth - 1).clamp(0, 11);
    final animals = ["원숭이", "닭", "개", "돼지", "쥐", "소", "호랑이", "토끼", "용", "뱀", "말", "양"];
    final stones = ["가넷", "자수정", "아쿠아마린", "다이아몬드", "에메랄드", "진주", "루비", "페리도트", "사파이어", "오팔", "토파즈", "터키석"];
    final flowers = ["수선화", "제비꽃", "데이지", "스위트피", "은방울꽃", "장미", "델피늄", "글라디올러스", "과꽃", "금잔화", "국화", "포인세티아"];

    return {
      'zodiac': "${animals[lYear % 12]}띠",
      'stone': stones[safeMonthIndex],
      'flower': flowers[safeMonthIndex],
      'constellation': getConstellation(sMonth, sDay),
    };
  }

  // 5. 기념일 및 D-Day 관련 로직
  static int daysSince(DateTime date) => today.difference(DateTime(date.year, date.month, date.day)).inDays + 1;
  
  static DateTime getTargetDate(DateTime start, int targetDays) => start.add(Duration(days: targetDays - 1));
  
  static String formatDate(DateTime date) => DateFormat('yyyy년 MM월 dd일').format(date);

  static double getTargetProgress(DateTime birthday, DateTime targetDate) {
    final birth = DateTime(birthday.year, birthday.month, birthday.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final int totalDuration = target.difference(birth).inDays;
    final int elapsed = today.difference(birth).inDays;
    if (totalDuration <= 0) return 0.0;
    if (elapsed >= totalDuration) return 1.0;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  // [🚨 복구] 생일 상세 화면에서 목표 나이 설정 시 사용
  static DateTime getTargetAgeDate(DateTime birthday, int targetAge) {
    return DateTime(birthday.year + targetAge, birthday.month, birthday.day);
  }

  /// [추가] 기준 생일(refDate)이 특정 나이가 되는 해의 날짜를 계산합니다.
  static DateTime getTargetRefAgeDate(DateTime birthday, DateTime refDate, bool isRefLunar, int targetAge) {
    // 목표 연도 = 태어난 해 + 목표 나이
    final targetYear = birthday.year + targetAge;
    
    if (!isRefLunar) {
      // 양력 기준일 경우 해당 연도의 월/일 그대로 반환
      return DateTime(targetYear, refDate.month, refDate.day);
    } else {
      // 음력 기준일 경우 해당 연도의 음력 월/일에 해당하는 양력 날짜 계산
      try {
        klc.setLunarDate(targetYear, refDate.month, refDate.day, false);
        return DateTime(klc.getSolarYear(), klc.getSolarMonth(), klc.getSolarDay());
      } catch (e) {
        // 음력 변환 실패 시 기본 양력 반환 (윤달 등 예외 처리)
        return DateTime(targetYear, refDate.month, refDate.day);
      }
    }
  }

  // 6. 다음 생일 정보 계산
  static Map<String, dynamic> getNextBirthdayInfo(DateTime birthday, bool isLunar) {
    final now = today;
    DateTime nextSolar;
    try {
      if (isLunar) {
        klc.setLunarDate(now.year, birthday.month, birthday.day, false);
        nextSolar = DateTime(klc.getSolarYear(), klc.getSolarMonth(), klc.getSolarDay());
        if (nextSolar.isBefore(now)) {
          klc.setLunarDate(now.year + 1, birthday.month, birthday.day, false);
          nextSolar = DateTime(klc.getSolarYear(), klc.getSolarMonth(), klc.getSolarDay());
        }
      } else {
        nextSolar = DateTime(now.year, birthday.month, birthday.day);
        if (nextSolar.isBefore(now)) {
          nextSolar = DateTime(now.year + 1, birthday.month, birthday.day);
        }
      }
    } catch (e) {
      nextSolar = birthday;
    }
    final int dDay = nextSolar.difference(now).inDays;
    return {
      'date': nextSolar,
      'dDay': dDay,
      'text': dDay == 0 ? '오늘 생일! 🎂' : 'D-$dDay',
    };
  }
}
