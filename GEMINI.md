# GEMINI.md - d_calc AI 개발 지침서

## 📌 Project Overview (프로젝트 개요)
**d_calc**은 다중 사용자 프로필을 지원하며, 양/음력 변환 및 정교한 사주/운세 매칭을 제공하는 프리미엄 D-Day 관리 모바일 앱입니다. 사용자의 생일, 기념일 등을 기준으로 디데이와 경과 일수를 계산하고 차트로 시각화합니다.

### Core Technologies
- **Framework:** Flutter
- **Language:** Dart
- **Linter:** `flutter_lints`

## 🎯 App Features (구현할 핵심 기능)
1. **다중 프로필 관리:** 여러 명의 이름과 생일(양/음력 여부 포함)을 등록, 수정, 삭제할 수 있는 기능.
2. **하이브리드 생일 계산 (가장 중요):** - 생일 등록 시 양력/음력 선택 가능.
   - **띠 (12지신):** 무조건 입력된 생일의 **'음력 연도'**를 기준으로 계산.
   - **별자리, 탄생석, 탄생화:** 무조건 입력된 생일의 **'양력 월/일'**을 기준으로 계산.
3. **상세 나이 및 경과일 계산:** 상세 화면에서 탄생일 기준 오늘까지의 만나이 및 경과 일수(+주/월)를 상세하게 제공. (다음 생일 남은 일수는 텍스트로만 표시)
4. **목표 D-Day 계산 및 저장:** 상세 화면에서 특정 일자 또는 목표 나이를 설정하여 저장.
5. **데이터 시각화:** 설정된 목표 D-Day를 기준으로 남은 일수 등을 `fl_chart`를 활용해 차트(도넛/파이 차트 등)로 시각화.
6. **한국어 달력 지원:** `flutter_localizations`를 적용하여 DatePicker 등을 완벽한 한국어로 출력.

## 🎨 UI/UX & Styling Guidelines (디자인 및 스타일링 지침)
Flutter에서는 CSS 대신 위젯 속성을 사용합니다. 코드를 생성할 때 다음 디자인 규칙을 엄격히 준수하세요:
- **Color Palette:**
  - Background: 깔끔한 하얀색 (`Colors.white`) 또는 아주 연한 배경 (`Colors.grey[50]`)
  - Primary Text: 가독성 높은 진한 검은색/회색 (`Colors.black87`)
  - Accent Color: 로맨틱한 분위기에 맞는 부드러운 파스텔 톤 (`Colors.pink[200]`, `Colors.teal[300]`)
- **Typography:**
  - 제목(Title): 직관적이고 굵게 (`fontSize: 22` 이상, `fontWeight: FontWeight.bold`)
  - 본문(Body): 편안한 크기 (`fontSize: 16`, `height: 1.5`)
- **Layout & Components:**
  - 화면 전체 여백(Padding)은 기본적으로 `16.0`을 유지합니다.
  - 정보 단위별로 모서리가 둥근 `Card` 위젯(`elevation: 2`, `borderRadius: 12.0`) 안에 담아 깔끔하게 분리합니다.
  - 데이터가 없는 초기 상태에는 반드시 친절한 안내 문구와 아이콘이 포함된 빈 화면(Empty State)을 구현합니다.

## 💾 Data Management & Architecture (데이터 및 구조)
- **Local Storage:** `shared_preferences` 패키지와 JSON 인코딩/디코딩을 사용하여 다중 프로필 목록과 개인별 목표 D-Day 데이터를 기기에 영구 저장하고 불러옵니다.
- **Project Structure:** 코드가 길어지므로 반드시 아래 구조로 파일을 완벽히 분리하여 코드를 제공하세요.
  - `lib/models/person.dart` (데이터 모델)
  - `lib/utils/calculator.dart` (음/양력 변환 및 매칭, 날짜 계산 로직 전담)
  - `lib/screens/home_screen.dart` (프로필 목록 UI 및 추가 다이얼로그)
  - `lib/screens/detail_screen.dart` (상세 나이 정보, 목표 D-Day 설정 및 차트 UI)
  - `lib/main.dart` (앱 시작점 및 로컬라이제이션 설정)

## 📦 External Packages (외부 라이브러리)
추가 패키지가 필요할 경우, 터미널 설치 명령어(`flutter pub add [패키지명]`)를 먼저 안내하세요.
- 날짜 포맷팅: `intl`
- 차트 구현: `fl_chart`
- 로컬 저장소: `shared_preferences`
- 음력 변환: `korean_lunar_calendar`
- 한국어 지원: `flutter_localizations`

## 🛡️ Error Handling (예외 처리)
- 미래 날짜 입력 방지: 생일 등을 '오늘보다 미래'로 설정하려고 하면 `SnackBar`를 띄워 경고 메시지를 보여주세요.
- 윤년(2월 29일) 계산이 정확히 떨어지도록 `DateTime` 로직을 구성하세요.
- 데이터 파싱 오류(null 처리)를 방지하여 앱이 튕기지 않도록 안전하게 코딩하세요.

## 🤖 AI Assistant Instructions (Gemini 행동 지침)
- **Target Audience:** 사용자는 Flutter 초보자입니다.
- **Language & Comments:** 모든 설명과 코드 내 주석은 **친절한 한국어**로 작성하세요. 특히 날짜 계산 로직이 어떻게 작동하는지 상세히 주석을 달아주세요.
- **Bracket Management:** 위젯 트리가 깊어질 때 닫는 괄호 뒤에 `// Column`, `// Card` 등 주석을 필수로 달아주세요.
- **Testing Context:** 테스트 변수는 `1970-03-19`로 설정하여 코드의 정확성을 보여주세요.
- **Code Completeness:** 항상 즉시 실행(`flutter run`) 가능한 **완전한 전체(Full) 코드**를 제공하세요. 조각 코드는 지양합니다.