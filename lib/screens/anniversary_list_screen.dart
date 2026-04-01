import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anniversary.dart';
import '../utils/calculator.dart';
import 'anniversary_detail_screen.dart';

class AnniversaryListScreen extends StatefulWidget {
  const AnniversaryListScreen({super.key});
  @override
  State<AnniversaryListScreen> createState() => _AnniversaryListScreenState();
}

class _AnniversaryListScreenState extends State<AnniversaryListScreen> {
  List<Anniversary> _list = [];
  final String _key = 'anniversary_list';

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) setState(() => _list = Anniversary.decode(data));
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Anniversary.encode(_list));
  }

  void _showAnniversaryDialog({Anniversary? anniversary}) {
    String title = anniversary?.title ?? '';
    DateTime selectedDate = anniversary?.date ?? DateTime.now();
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(selectedDate));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(anniversary == null ? '새 기념일 등록' : '기념일 수정', style: const TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(initialValue: title, decoration: const InputDecoration(labelText: '기념일 이름'), onChanged: (v) => title = v),
              const SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: '날짜 (YYYY-MM-DD)', suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2100));
                  if (picked != null) { selectedDate = picked; dateController.text = DateFormat('yyyy-MM-dd').format(picked); }
                })),
                keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8), DateInputFormatter()],
                onChanged: (v) { try { if (v.length == 10) selectedDate = DateFormat('yyyy-MM-dd').parseStrict(v); } catch (_) {} },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(onPressed: () {
              if (title.trim().isEmpty) return;
              setState(() {
                final newAni = Anniversary(id: anniversary?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), title: title, date: selectedDate, targetDate: anniversary?.targetDate, targetValue: anniversary?.targetValue);
                if (anniversary == null) { _list.add(newAni); }
                else { final index = _list.indexWhere((e) => e.id == anniversary.id); if (index != -1) _list[index] = newAni; }
              });
              _saveData(); Navigator.pop(context);
            }, child: const Text('저장')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(title: const Text('기념일 목록', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: _list.isEmpty ? const Center(child: Text('등록된 기념일이 없어요.', style: TextStyle(color: Colors.black38))) : ListView.builder(padding: const EdgeInsets.all(20), itemCount: _list.length, itemBuilder: (context, index) {
        final ani = _list[index];
        final days = Calculator.today.difference(DateTime(ani.date.year, ani.date.month, ani.date.day)).inDays + 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnniversaryDetailScreen(anniversary: ani))).then((_) => _loadData()),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(backgroundColor: Colors.teal[50], radius: 22, child: const Icon(Icons.favorite, color: Colors.teal, size: 22)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(ani.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                                  Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18), onPressed: () => _showAnniversaryDialog(anniversary: ani), constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () { setState(() => _list.removeAt(index)); _saveData(); }, constraints: const BoxConstraints(), padding: const EdgeInsets.all(4)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${DateFormat('yyyy년 MM월 dd일').format(ani.date)} | $days일째', style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (ani.targetDate != null) ...[
                      const SizedBox(height: 16),
                      _buildMiniGoal(ani),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: Colors.teal[300]),
                          const SizedBox(width: 6),
                          Text('상세 기록 보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.teal[400])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAnniversaryDialog(), backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.add, color: Colors.white, size: 30)),
    );
  }

  Widget _buildMiniGoal(Anniversary ani) {
    final progress = Calculator.getTargetProgress(ani.date, ani.targetDate!);
    final remaining = ani.targetDate!.difference(Calculator.today).inDays;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${ani.targetValue.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}일 목표', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
              Text('D-$remaining', style: const TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.teal[50], valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[300]!)),
          ),
        ],
      ),
    );
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
