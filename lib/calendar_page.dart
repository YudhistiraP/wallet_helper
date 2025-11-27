import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

  late Map<DateTime, List<CalendarTransaction>> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    _events = {
      DateTime.utc(_focusedDay.year, _focusedDay.month, _focusedDay.day): [
        CalendarTransaction(title: "Makan Siang", amount: 25000, isExpense: true, icon: Icons.fastfood, color: Colors.red),
        CalendarTransaction(title: "Ojek Online", amount: 15000, isExpense: true, icon: Icons.motorcycle, color: Colors.orange),
      ],
      DateTime.utc(_focusedDay.year, _focusedDay.month, _focusedDay.day + 1): [
        CalendarTransaction(title: "Freelance", amount: 500000, isExpense: false, icon: Icons.laptop, color: Colors.green),
      ],
      DateTime.utc(_focusedDay.year, _focusedDay.month, _focusedDay.day - 3): [
        CalendarTransaction(title: "Belanja Bulanan", amount: 350000, isExpense: true, icon: Icons.shopping_bag, color: Colors.blue),
        CalendarTransaction(title: "Listrik", amount: 100000, isExpense: true, icon: Icons.electric_bolt, color: Colors.yellow),
      ],
    };
  }

  List<CalendarTransaction> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _selectYearMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00BFA5),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
      });
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
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },

                        eventLoader: _getEventsForDay,

                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey),
                          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey),
                        ),

                        calendarBuilders: CalendarBuilders(
                          headerTitleBuilder: (context, day) {
                            return GestureDetector(
                              onTap: _selectYearMonth,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('MMMM yyyy').format(day),
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                  ],
                                ),
                              ),
                            );
                          },

                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),

                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF00BFA5),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: GoogleFonts.poppins(),
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
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "Transactions on ${DateFormat('dd MMM yyyy').format(_selectedDay!)}",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          Expanded(
                            child: _buildTransactionList(),
                          ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text("No transactions", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final transaction = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: transaction.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(transaction.icon, color: transaction.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  transaction.title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(transaction.amount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: transaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}