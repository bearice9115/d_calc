import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../utils/calculator.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Person> _personList = [];
  final String _storageKey = 'person_list';
  bool _isLoading = true;
  bool _isNavigating = false;
  DateTime? _lastTapTime;

  @override
  void initState() { super.initState(); _initAndLoad(); }

  Future<void> _initAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null && mounted) {
        setState(() { _personList = Person.decode(data); _isLoading = false; });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Person.encode(_personList));
  }

  void _showPersonDialog({Person? person}) {
    String name = person?.name ?? '';
    DateTime actualDate = person?.birthday ?? DateTime.now();
    bool isActualLunar = person?.isLunar ?? false;
    int aniMode = 0;
    if (person != null) {
      if (person.refBirthday.month == person.birthday.month && person.refBirthday.day == person.birthday.day) {
        aniMode = person.isRefLunar ? 1 : 0;
      } else { aniMode = 2; }
    }
    DateTime customRefDate = person?.refBirthday ?? actualDate;
    final actualDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(actualDate));
    final customRefController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(customRefDate));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          DateTime finalRefDate; bool finalIsRefLunar;
          if (aniMode == 0) { finalRefDate = actualDate; finalIsRefLunar = false; }
          else if (aniMode == 1) { finalRefDate = actualDate; finalIsRefLunar = true; }
          else { finalRefDate = customRefDate; finalIsRefLunar = false; }
          final nextBdayInfo = Calculator.getNextBirthdayInfo(finalRefDate, finalIsRefLunar);
          return AlertDialog(
            title: Text(person == null ? '새 인물 등록' : '정보 수정', style: const TextStyle(fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(initialValue: name, decoration: const InputDecoration(labelText: '이름'), onChanged: (v) => name = v),
                    const SizedBox(height: 24),
                    const Align(alignment: Alignment.centerLeft, child: Text('📍 태어난 날', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey))),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: ChoiceChip(label: const Text('양력'), selected: !isActualLunar, onSelected: (s) => setDialogState(() => isActualLunar = false))),
                      const SizedBox(width: 8),
                      Expanded(child: ChoiceChip(label: const Text('음력'), selected: isActualLunar, onSelected: (s) => setDialogState(() => isActualLunar = true))),
                    ]),
                    TextFormField(
                      controller: actualDateController,
                      decoration: InputDecoration(hintText: 'YYYY-MM-DD', suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: actualDate, firstDate: DateTime(1900), lastDate: DateTime.now());
                        if (picked != null) { actualDate = picked; actualDateController.text = DateFormat('yyyy-MM-dd').format(picked); if (aniMode != 2) customRefDate = picked; setDialogState(() {}); }
                      })),
                      keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8), DateInputFormatter()],
                      onChanged: (v) { try { if (v.length == 10) { actualDate = DateFormat('yyyy-MM-dd').parseStrict(v); if (aniMode != 2) customRefDate = actualDate; setDialogState(() {}); } } catch (_) {} },
                    ),
                    const SizedBox(height: 24),
                    const Align(alignment: Alignment.centerLeft, child: Text('🎂 기념할 방식', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.pinkAccent))),
                    const SizedBox(height: 8),
                    SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                      ChoiceChip(label: const Text('양력'), selected: aniMode == 0, onSelected: (s) => setDialogState(() => aniMode = 0)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('음력'), selected: aniMode == 1, onSelected: (s) => setDialogState(() => aniMode = 1)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('기타'), selected: aniMode == 2, onSelected: (s) => setDialogState(() => aniMode = 2)),
                    ])),
                    if (aniMode == 2) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: customRefController,
                        decoration: InputDecoration(labelText: '기념일 날짜', hintText: 'YYYY-MM-DD', suffixIcon: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () async {
                          final picked = await showDatePicker(context: context, initialDate: customRefDate, firstDate: DateTime(1900), lastDate: DateTime(2100));
                          if (picked != null) { customRefDate = picked; customRefController.text = DateFormat('yyyy-MM-dd').format(picked); setDialogState(() {}); }
                        })),
                        keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8), DateInputFormatter()],
                        onChanged: (v) { try { if (v.length == 10) { customRefDate = DateFormat('yyyy-MM-dd').parseStrict(v); setDialogState(() {}); } } catch (_) {} },
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(15)), child: Column(children: [
                      const Text('🎁 다음 기념일 (D-Day)', style: TextStyle(fontSize: 11, color: Colors.pink)),
                      const SizedBox(height: 4),
                      Text('${DateFormat('yyyy년 MM월 dd일').format(nextBdayInfo['date'])} (${nextBdayInfo['text']})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent, fontSize: 13)),
                    ])),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              ElevatedButton(
                onPressed: () {
                  if (name.trim().isEmpty) return;
                  setState(() {
                    final newPerson = Person(id: person?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), name: name, birthday: actualDate, isLunar: isActualLunar, refBirthday: finalRefDate, isRefLunar: aniMode == 1, nextBirthday: nextBdayInfo['date'], targetDDayDate: person?.targetDDayDate, targetDDayValue: person?.targetDDayValue, targetAgeDate: person?.targetAgeDate, targetAgeValue: person?.targetAgeValue);
                    if (person == null) { _personList.add(newPerson); }
                    else { final index = _personList.indexWhere((p) => p.id == person.id); if (index != -1) _personList[index] = newPerson; }
                  });
                  _saveData(); Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('저장'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(title: const Text('소중한 생일 목록', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)) : _personList.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cake_outlined, size: 80, color: Colors.pink[100]), const SizedBox(height: 16), const Text('등록된 사람이 없어요.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 16))])) : ListView.builder(padding: const EdgeInsets.all(20), itemCount: _personList.length, itemBuilder: (context, index) {
        final p = _personList[index]; final prog = Calculator.getDetailedProgress(p.birthday, p.isLunar);
        return PersonListTile(person: p, age: prog['age'] ?? 0, onDelete: () { setState(() => _personList.removeAt(index)); _saveData(); }, onEdit: () => _showPersonDialog(person: p), onTap: () {
          final now = DateTime.now(); if (_isNavigating) return; if (_lastTapTime != null && now.difference(_lastTapTime!) < const Duration(milliseconds: 600)) return;
          _isNavigating = true; _lastTapTime = now; setState(() {});
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(person: p))).then((_) { if (mounted) { setState(() { _isNavigating = false; _initAndLoad(); }); } });
        });
      }),
      floatingActionButton: FloatingActionButton(onPressed: () => _showPersonDialog(), backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.add, color: Colors.white, size: 30)),
    );
  }
}

class PersonListTile extends StatelessWidget {
  final Person person; final int age; final VoidCallback onDelete; final VoidCallback onEdit; final VoidCallback onTap;
  const PersonListTile({super.key, required this.person, required this.age, required this.onDelete, required this.onEdit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.pink[50], shape: BoxShape.circle), child: Icon(Icons.cake, color: Colors.pinkAccent[100], size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(person.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18), onPressed: onEdit, constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: onDelete, constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('만 $age세', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Text('생일: ${DateFormat('MM-dd').format(person.birthday)}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                  Text('기념기준: ${DateFormat('MM-dd').format(person.refBirthday)} (${person.isRefLunar ? "음력" : "양력"})', style: const TextStyle(fontSize: 12, color: Colors.pinkAccent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        if (person.targetDDayDate != null || person.targetAgeDate != null) ...[
          const SizedBox(height: 12),
          if (person.targetDDayDate != null) _buildMiniGoal(context, title: '${person.targetDDayValue.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}일 목표', date: person.targetDDayDate!, progress: Calculator.getTargetProgress(person.refBirthday, person.targetDDayDate!), color: Colors.teal),
          if (person.targetDDayDate != null && person.targetAgeDate != null) const SizedBox(height: 8),
          if (person.targetAgeDate != null) _buildMiniGoal(context, title: '만 ${person.targetAgeValue}세 목표', date: person.targetAgeDate!, progress: Calculator.getTargetProgress(person.refBirthday, person.targetAgeDate!), color: Colors.pinkAccent),
        ],
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, size: 14, color: Colors.teal[300]), const SizedBox(width: 6), Text('상세 기록 보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.teal[400]))])),
      ])))),
    );
  }

  Widget _buildMiniGoal(BuildContext context, {required String title, required DateTime date, required double progress, required Color color}) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        Text('D-${date.difference(Calculator.today).inDays} (${DateFormat("yyyy-MM-dd").format(date)})', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Colors.black38)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.6)))),
    ]));
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', '');
    if (text.length > 8) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 3 || i == 5) && i != text.length - 1) buffer.write('-');
    }
    final formatted = buffer.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
