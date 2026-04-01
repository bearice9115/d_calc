import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anniversary.dart';
import '../utils/calculator.dart';

class AnniversaryDetailScreen extends StatefulWidget {
  final Anniversary anniversary;
  const AnniversaryDetailScreen({super.key, required this.anniversary});
  @override
  State<AnniversaryDetailScreen> createState() => _AnniversaryDetailScreenState();
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String value;
  const _DetailSection(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.black38)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
  }
}

class _AnniversaryDetailScreenState extends State<AnniversaryDetailScreen> {
  late Anniversary _ani;
  late TextEditingController _targetController;
  int _tempTotalDays = 0;

  @override
  void initState() {
    super.initState();
    _ani = widget.anniversary;
    _tempTotalDays = _ani.targetValue ?? 1000;
    _targetController = TextEditingController(text: _tempTotalDays.toString());
  }

  Future<void> _updateTarget() async {
    final targetDate = _ani.date.add(Duration(days: _tempTotalDays - 1));
    final updated = _ani.copyWith(targetDate: targetDate, targetValue: _tempTotalDays);
    
    setState(() => _ani = updated);
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('anniversary_list');
    if (data != null) {
      List<Anniversary> list = Anniversary.decode(data);
      final index = list.indexWhere((e) => e.id == _ani.id);
      if (index != -1) {
        list[index] = updated;
        await prefs.setString('anniversary_list', Anniversary.encode(list));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('목표가 저장되었습니다!'), duration: Duration(seconds: 1)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = Calculator.today.difference(DateTime(_ani.date.year, _ani.date.month, _ani.date.day)).inDays + 1;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(title: Text(_ani.title, style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTopCard(days),
            const SizedBox(height: 32),
            _buildTargetSetting(),
            const SizedBox(height: 32),
            if (_ani.targetDate != null) _buildJourney(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(int days) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal[50]!, Colors.blue[50]!]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 20)]),
      child: Column(
        children: [
          const Text('우리가 함께한 시간', style: TextStyle(color: Colors.black45, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$days', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.teal)),
              const SizedBox(width: 4),
              const Text('일째', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          const Divider(height: 40),
          _DetailSection('시작일', DateFormat('yyyy년 MM월 dd일').format(_ani.date)),
        ],
      ),
    );
  }

  Widget _buildTargetSetting() {
    final targetDate = _ani.date.add(Duration(days: _tempTotalDays - 1));
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 20)]),
      child: Column(
        children: [
          const Text('🎯 목표 디데이 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('목표 일수', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              SizedBox(width: 100, child: TextField(controller: _targetController, keyboardType: TextInputType.number, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 18), decoration: const InputDecoration(suffixText: ' 일', border: InputBorder.none), onChanged: (v) { final d = int.tryParse(v); if (d != null) setState(() => _tempTotalDays = d); })),
            ],
          ),
          Slider(value: _tempTotalDays.toDouble().clamp(0, 40000), min: 0, max: 40000, divisions: 400, activeColor: Colors.teal[300], onChanged: (v) { setState(() { _tempTotalDays = v.toInt(); _targetController.text = _tempTotalDays.toString(); }); }),
          const SizedBox(height: 16),
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)), child: Column(children: [const Text('목표일 (예상)', style: TextStyle(fontSize: 12, color: Colors.black38)), const SizedBox(height: 4), Text('${DateFormat('yyyy-MM-dd').format(targetDate)} (D-${targetDate.difference(Calculator.today).inDays})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _updateTarget, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[300], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('목표 저장하기', style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildJourney() {
    final progress = Calculator.getTargetProgress(_ani.date, _ani.targetDate!);
    final safeValue = progress.clamp(0.0, 1.0);
    final percentage = (safeValue * 100).toStringAsFixed(1);
    final elapsed = Calculator.today.difference(_ani.date).inDays;
    final total = _ani.targetDate!.difference(_ani.date).inDays;

    return Column(
      children: [
        const Text('목표 달성 여정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('달성률', style: TextStyle(fontWeight: FontWeight.bold)), Text('$percentage%', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.teal[300]))]),
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10))),
                  FractionallySizedBox(widthFactor: safeValue, child: Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[200]!, Colors.teal[200]!]), borderRadius: BorderRadius.circular(10)))),
                  LayoutBuilder(builder: (context, constraints) { return Padding(padding: EdgeInsets.only(left: (constraints.maxWidth * safeValue) - 15), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Icon(Icons.favorite, color: Colors.red[300], size: 20))); }),
                ],
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('시작', style: TextStyle(fontSize: 10, color: Colors.black38)), Text(DateFormat('yyyy-MM-dd').format(_ani.date), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('목표일', style: TextStyle(fontSize: 10, color: Colors.black38)), Text(DateFormat('yyyy-MM-dd').format(_ani.targetDate!), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
              ]),
              const SizedBox(height: 24),
              Text('총 $total일 중 $elapsed일 경과', style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
