import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarTransaction {
  final String title;
  final int amount;
  final bool isExpense;
  final IconData icon;
  final Color color;

  CalendarTransaction({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.icon,
    required this.color,
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<CalendarTransaction>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('created', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created', isLessThan: Timestamp.fromDate(end))
        .get();

    Map<DateTime, List<CalendarTransaction>> temp = {};

    for (final doc in snap.docs) {
      final d = doc.data();
      final dt = (d['created'] as Timestamp).toDate();
      final dayKey = DateTime.utc(dt.year, dt.month, dt.day);

      final isExpense = d['type'] == 'expense';
      final color = isExpense ? Colors.red : Colors.green;
      final icon = isExpense ? Icons.trending_down : Icons.trending_up;

      temp.putIfAbsent(dayKey, () => []);
      temp[dayKey]!.add(
        CalendarTransaction(
          title: d['title'],
          amount: d['amount'],
          isExpense: isExpense,
          icon: icon,
          color: color,
        ),
      );
    }

    setState(() {
      _events = temp;
    });
  }

  List<CalendarTransaction> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _selectYearMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
      });
      _loadMonthData();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color yellowColor = const Color(0xFFFFF78A);
    Color peachColor = const Color(0xFFF6A987);

    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "History",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: peachColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,

                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },

                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          _loadMonthData();
                        },

                        eventLoader: _getEventsForDay,

                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),

                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF00BFA5),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                          weekendTextStyle: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "Transactions on ${DateFormat('dd MMM yyyy').format(_selectedDay!)}",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: _buildTransactionList()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Center(child: Text("No transactions", style: GoogleFonts.poppins(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, i) {
        final t = events[i];
        return ListTile(
          leading: Icon(t.icon, color: t.color),
          title: Text(t.title, style: GoogleFonts.poppins()),
          trailing: Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(t.amount),
            style: GoogleFonts.poppins(color: t.isExpense ? Colors.red : Colors.green),
          ),
        );
      },
    );
  }
}
