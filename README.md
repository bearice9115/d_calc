# 📅 d_calc (디-캘크)

> **다중 사용자 프로필을 지원하는 프리미엄 D-Day 관리 및 사주/운세 매칭 솔루션**

`d_calc`은 단순한 날짜 계산기를 넘어, 사용자의 생일(양력/음력)을 기반으로 한 정교한 기념일 관리와 데이터 시각화를 제공하는 Flutter 앱입니다.

---

## ✨ 핵심 기능 (Key Features)

- **👤 다중 프로필 관리**: 가족, 친구, 연인 등 여러 명의 프로필을 등록하고 각각의 기념일을 관리할 수 있습니다.
- **🌙 하이브리드 생일 계산**: 
  - **띠(12지신)**: 음력 연도를 기준으로 정확하게 산출.
  - **별자리/탄생석/탄생화**: 양력 월/일을 기준으로 매칭.
- **📊 데이터 시각화**: `fl_chart`를 활용하여 목표 D-Day까지의 남은 일수를 도넛/파이 차트로 한눈에 확인.
- **⏳ 상세 일수 계산**: 오늘까지 살아온 날(경과일), 다음 생일까지 남은 일수, 만나이 등을 상세히 제공.
- **🇰🇷 완벽한 한국어 지원**: 한국어 달력 및 공휴일 연동을 위한 로컬라이제이션 적용.

---

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 / 라이브러리 |
| :--- | :--- |
| **Framework** | Flutter |
| **Language** | Dart |
| **Storage** | `shared_preferences` (JSON Serialization) |
| **Charts** | `fl_chart` |
| **Date Logic** | `intl`, `klc` (Korean Lunar Calendar) |
| **L10n** | `flutter_localizations` |

---

## 📂 프로젝트 구조 (Project Structure)

```text
lib/
├── main.dart             # 앱 진입점 및 테마/로컬 설정
├── models/
│   ├── person.dart       # 사용자 프로필 데이터 모델
│   └── anniversary.dart  # 기념일 데이터 모델
├── screens/
│   ├── home_screen.dart        # 프로필 목록 및 추가
│   ├── detail_screen.dart      # 상세 정보 및 차트 UI
│   └── anniversary_list.dart   # 기념일 목록 관리
└── utils/
    └── calculator.dart   # 양/음력 변환 및 사주 매칭 로직
```

---

## 🚀 시작하기 (Getting Started)

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 앱 실행
```bash
flutter run
```

---

## 🎨 디자인 가이드라인

- **Color**: 깨끗한 `White` 배경에 부드러운 `Pink[200]`와 `Teal[300]` 액센트 컬러를 사용합니다.
- **UI**: 모든 정보는 모서리가 둥근(`BorderRadius: 12.0`) `Card` 위젯에 담아 깔끔하게 시각화합니다.

---

## 🛡️ 예외 처리

- **미래 날짜 방지**: 생일 설정 시 오늘 이후의 날짜 선택을 차단합니다.
- **데이터 안정성**: 데이터 파싱 오류 발생 시 기본값을 반환하여 앱의 안정성을 보장합니다.
