import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../utils/calculator.dart';

class DetailScreen extends StatefulWidget {
  final Person person;
  const DetailScreen({super.key, required this.person});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Person _person;
  late TextEditingController _ageController;
  late TextEditingController _totalDaysController;
  bool _isReady = false;
  int _selectedMode = 0; // 0: 디데이, 1: 나이
  double _tempAge = 0;
  int _tempTotalDays = 0;

  late Map<String, int> _cachedProg;
  late Map<String, String> _cachedMatches;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
    _ageController = TextEditingController();
    _totalDaysController = TextEditingController();
    final detailed = Calculator.getDetailedProgress(_person.birthday, _person.isLunar);
    _tempAge = _person.targetAgeValue?.toDouble() ?? (detailed['age']?.toDouble() ?? 0.0);
    _tempTotalDays = _person.targetDDayValue ?? (detailed['days'] ?? 0);
    _totalDaysController.text = _tempTotalDays.toString();
    _ageController.text = _tempAge.toInt().toString();
    _initCalculations();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isReady = true);
    });
  }

  void _initCalculations() {
    _cachedProg = Calculator.getDetailedProgress(_person.birthday, _person.isLunar);
    _cachedMatches = Calculator.getFullMatches(_person.birthday, _person.isLunar);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _totalDaysController.dispose();
    super.dispose();
  }

  Future<void> _updateGoal({DateTime? date, int? value, required bool isAge}) async {
    if (date == null || value == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final updatedPerson = isAge 
      ? _person.copyWith(targetAgeDate: date, targetAgeValue: value)
      : _person.copyWith(targetDDayDate: date, targetDDayValue: value);
    setState(() { _person = updatedPerson; _initCalculations(); });
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('person_list');
    if (data != null) {
      List<Person> list = Person.decode(data);
      final index = list.indexWhere((p) => p.id == _person.id);
      if (index != -1) {
        list[index] = updatedPerson;
        await prefs.setString('person_list', Person.encode(list));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAge ? '나이 목표가 저장되었습니다!' : '디데이 목표가 저장되었습니다!'), duration: const Duration(seconds: 1)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return const Scaffold(backgroundColor: Color(0xFFFFFEFA), body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)));
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(title: Text('${_person.name}님의 기록', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            _buildElegantInfoCard(_cachedProg, _cachedMatches),
            const SizedBox(height: 24),
            _buildTargetSettingArea(),
            const SizedBox(height: 24),
            if (_person.targetDDayDate != null) ...[
              _buildJourneySection(
                title: '${_person.targetDDayValue.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}일 여정',
                targetDate: _person.targetDDayDate!,
                progress: Calculator.getTargetProgress(_person.refBirthday, _person.targetDDayDate!),
              ),
              const SizedBox(height: 32),
            ],
            if (_person.targetAgeDate != null) ...[
              _buildJourneySection(
                title: '만 ${_person.targetAgeValue}세 여정',
                targetDate: _person.targetAgeDate!,
                progress: Calculator.getTargetProgress(_person.refBirthday, _person.targetAgeDate!),
              ),
              const SizedBox(height: 50),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildElegantInfoCard(Map<String, int> prog, Map<String, String> matches) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.pink[50]!, Colors.teal[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('지나온 아름다운 나날들', style: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${prog['days']}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.teal, letterSpacing: -1)),
              const SizedBox(width: 2),
              const Text('일째', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)), // [1] 단위 축소
            ],
          ),
          const Divider(height: 30, thickness: 0.5, color: Colors.black12),
          if (_person.nextBirthday != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cake, size: 16, color: Colors.pinkAccent),
                const SizedBox(width: 6),
                Text('다음 생일: ${Calculator.formatDate(_person.nextBirthday!)} (D-${_person.nextBirthday!.difference(Calculator.today).inDays})', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.pinkAccent)),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoDetail('만나이', '만 ${prog['age']}세'),
              _infoDetail('경과 월', '${prog['months']}개월'),
              _infoDetail('경과 주', '${prog['weeks']}주'),
            ],
          ),
          const SizedBox(height: 20),
          // [2] 한 줄로 표현되는 콤팩트한 정보 섹션
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _compactMatchChip(matches['zodiac'] ?? '-', Icons.pets, Colors.orange),
                const SizedBox(width: 8),
                _compactMatchChip(matches['stone'] ?? '-', Icons.diamond, Colors.blue),
                const SizedBox(width: 8),
                _compactMatchChip(matches['flower'] ?? '-', Icons.local_florist, Colors.pink),
                const SizedBox(width: 8),
                _compactMatchChip(matches['constellation'] ?? '-', Icons.auto_awesome, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactMatchChip(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _infoDetail(String label, String value) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.black38)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87))]);
  }

  Widget _buildTargetSettingArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          const Text('🎯 목표 설정', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('디데이', style: TextStyle(fontSize: 12)), icon: Icon(Icons.flag_outlined, size: 16)),
              ButtonSegment(value: 1, label: Text('나이', style: TextStyle(fontSize: 12)), icon: Icon(Icons.cake_outlined, size: 16)),
            ],
            selected: {_selectedMode},
            onSelectionChanged: (Set<int> newSelection) => setState(() => _selectedMode = newSelection.first),
            style: SegmentedButton.styleFrom(backgroundColor: Colors.grey[50], selectedBackgroundColor: Colors.teal[100], selectedForegroundColor: Colors.teal[800], side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 20),
          if (_selectedMode == 0) _buildDDayInputMode(),
          if (_selectedMode == 1) _buildAgeInputMode(),
        ],
      ),
    );
  }

  Widget _buildDDayInputMode() {
    final targetDateForTempDays = _person.refBirthday.add(Duration(days: _tempTotalDays - 1));
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('목표 일수', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13)),
            SizedBox(width: 80, child: TextField(controller: _totalDaysController, keyboardType: TextInputType.number, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16), decoration: const InputDecoration(suffixText: ' 일', border: InputBorder.none, isDense: true), onChanged: (val) { final d = int.tryParse(val); if (d != null) setState(() => _tempTotalDays = d); })),
          ],
        ),
        Slider(value: _tempTotalDays.toDouble().clamp(0, 40000), min: 0, max: 40000, divisions: 400, activeColor: Colors.teal[300], inactiveColor: Colors.teal[50], onChanged: (val) { setState(() { _tempTotalDays = val.toInt(); _totalDaysController.text = _tempTotalDays.toString(); }); }),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [10000, 20000, 30000].map((days) => Padding(padding: const EdgeInsets.only(right: 6.0), child: ActionChip(label: Text('${days ~/ 1000}천일', style: const TextStyle(fontSize: 11)), onPressed: () => setState(() { _tempTotalDays = days; _totalDaysController.text = _tempTotalDays.toString(); }), backgroundColor: _tempTotalDays == days ? Colors.teal[100] : Colors.grey[50], side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), visualDensity: VisualDensity.compact))).toList())),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)), child: Column(children: [const Text('목표일 (예상)', style: TextStyle(fontSize: 11, color: Colors.black38)), const SizedBox(height: 2), Text('${Calculator.formatDate(targetDateForTempDays)} (D-${targetDateForTempDays.difference(Calculator.today).inDays})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))])),
        const SizedBox(height: 12),
        // [3] 슬림해진 버튼
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateGoal(date: targetDateForTempDays, value: _tempTotalDays, isAge: false), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[300], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('디데이 목표 저장', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
      ],
    );
  }

  Widget _buildAgeInputMode() {
    final targetDateForTempAge = Calculator.getTargetRefAgeDate(_person.birthday, _person.refBirthday, _person.isRefLunar, _tempAge.toInt());
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('목표 나이', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(8)), child: Text('만 ${_tempAge.toInt()}세', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.pink, fontSize: 16))),
          ],
        ),
        Slider(value: _tempAge, min: 0, max: 100, divisions: 100, activeColor: Colors.pink[200], inactiveColor: Colors.pink[50], onChanged: (val) => setState(() => _tempAge = val)),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [20, 40, 60, 80, 100].map((age) => Padding(padding: const EdgeInsets.only(right: 6.0), child: ActionChip(label: Text('$age세', style: const TextStyle(fontSize: 11)), onPressed: () => setState(() => _tempAge = age.toDouble()), backgroundColor: _tempAge.toInt() == age ? Colors.pink[100] : Colors.grey[50], side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), visualDensity: VisualDensity.compact))).toList())),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)), child: Column(children: [const Text('목표일 (예상)', style: TextStyle(fontSize: 11, color: Colors.black38)), const SizedBox(height: 2), Text('${Calculator.formatDate(targetDateForTempAge)} (D-${targetDateForTempAge.difference(Calculator.today).inDays})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))])),
        const SizedBox(height: 12),
        // [3] 슬림해진 버튼
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateGoal(date: targetDateForTempAge, value: _tempAge.toInt(), isAge: true), style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[200], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('나이 목표 저장', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
      ],
    );
  }

  Widget _buildJourneySection({required String title, required DateTime targetDate, required double progress}) {
    final remaining = targetDate.difference(Calculator.today).inDays;
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
        const SizedBox(height: 4),
        Text('D-$remaining (${Calculator.formatDate(targetDate)})', style: const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(height: 16),
        _buildEmotionalChart(progress, targetDate),
      ],
    );
  }

  Widget _buildEmotionalChart(double progress, DateTime targetDate) {
    final double safeValue = (progress.isNaN || progress <= 0) ? 0.0 : progress.clamp(0.0, 1.0);
    final percentage = (safeValue * 100).toStringAsFixed(1);
    final int elapsedFromRef = Calculator.today.difference(_person.refBirthday).inDays;
    final int totalToTarget = targetDate.difference(_person.refBirthday).inDays;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('목표 달성률', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)), Text('$percentage%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.pink[300]))]),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10))),
              FractionallySizedBox(widthFactor: safeValue, child: Container(height: 10, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal[200]!, Colors.pink[200]!]), borderRadius: BorderRadius.circular(10)))),
              LayoutBuilder(builder: (context, constraints) { return Padding(padding: EdgeInsets.only(left: (constraints.maxWidth * safeValue) - 12), child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)]), child: Icon(Icons.directions_run, color: Colors.pink[300], size: 16))); }),
            ],
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('시작', style: TextStyle(fontSize: 9, color: Colors.black38)), Text(Calculator.formatDate(_person.refBirthday), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('목표일', style: TextStyle(fontSize: 9, color: Colors.black38)), Text(Calculator.formatDate(targetDate), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
          ]),
          const SizedBox(height: 16),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.teal[50]!.withOpacity(0.3), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('총 $totalToTarget일 중 ', style: const TextStyle(fontSize: 12, color: Colors.black54)), Text('$elapsedFromRef일', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal[700])), const Text(' 경과', style: TextStyle(fontSize: 12, color: Colors.black54))])),
        ],
      ),
    );
  }
}
