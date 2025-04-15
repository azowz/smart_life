import 'package:final_project/Statistic/done_Calender.dart';
import 'package:flutter/material.dart';



class ReminderHabits extends StatefulWidget {
  const ReminderHabits({super.key});

  @override
  _ReminderHabitsState createState() => _ReminderHabitsState();
}

class _ReminderHabitsState extends State<ReminderHabits> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  String? _selectedCategory;
  final TextEditingController _noteController = TextEditingController();
  bool _enableReminder = false;
  bool _enableRepeat = false;

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3953),
      appBar: AppBar(
        title: Text('Add Reminder'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Let's set the\nschedule easily",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // عنوان تاريخ الاختيار
              const Text(
                'Select the date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // مربع تاريخ الاختيار
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDateSection(
                      context: context,
                      title: 'From',
                      date: _fromDate,
                      isFrom: true,
                    ),
                    const SizedBox(height: 20),
                    _buildDateSection(
                      context: context,
                      title: 'To', 
                      date: _toDate,
                      isFrom: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // اختيار الوقت
              const Text(
                'Select time',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildTimeSelector(context),

              const SizedBox(height: 20),
              _buildOptionsRow(),

              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildCategorySelector(),

              const SizedBox(height: 20),
              const Text(
                'Note :',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildNoteField(),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF3F3E0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                   
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DoneCalendar(),
                      ),
                    );
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // باقي دوال الـ Widget المساعدة...
  Widget _buildDateSection({
    required BuildContext context,
    required String title,
    required DateTime date,
    required bool isFrom,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateBox(
              date: date.subtract(const Duration(days: 2)),
              isSelected: false,
              onTap: () {
                setState(() {
                  if (isFrom) {
                    _fromDate = date.subtract(const Duration(days: 2));
                  } else {
                    _toDate = date.subtract(const Duration(days: 2));
                  }
                });
              },
            ),
            _buildDateBox(
              date: date.subtract(const Duration(days: 1)),
              isSelected: false,
              onTap: () {
                setState(() {
                  if (isFrom) {
                    _fromDate = date.subtract(const Duration(days: 1));
                  } else {
                    _toDate = date.subtract(const Duration(days: 1));
                  }
                });
              },
            ),
            _buildDateBox(
              date: date,
              isSelected: true,
              onTap: () => isFrom ? _selectFromDate(context) : _selectToDate(context),
            ),
            _buildOtherDateBox(
              onTap: () => isFrom ? _selectFromDate(context) : _selectToDate(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateBox({
    required DateTime date,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getShortWeekdayName(date.weekday),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherDateBox({
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Other\nDate',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildReminderButton(),
          _buildRepeatButton(),
        ],
      ),
    );
  }

  Widget _buildReminderButton() {
    return GestureDetector(
      onTap: () => setState(() => _enableReminder = !_enableReminder),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _enableReminder ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _enableReminder ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.alarm,
              size: 16,
              color: _enableReminder ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              "10 mins before",
              style: TextStyle(
                fontSize: 12,
                color: _enableReminder ? Colors.blue : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatButton() {
    return GestureDetector(
      onTap: () => setState(() => _enableRepeat = !_enableRepeat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _enableRepeat ? Colors.purple[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _enableRepeat ? Colors.purple : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat,
              size: 16,
              color: _enableRepeat ? Colors.purple : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              "Repeat",
              style: TextStyle(
                fontSize: 12,
                color: _enableRepeat ? Colors.purple : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Sun';
      case 2: return 'Mon';
      case 3: return 'Tue';
      case 4: return 'Wed';
      case 5: return 'Thu';
      case 6: return 'Fri';
      case 7: return 'Sat';
      default: return '';
    }
  }

  Widget _buildTimeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _selectStartTime(context);
        await _selectEndTime(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'From\n${_startTime.format(context)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_forward),
            Text(
              'To\n${_endTime.format(context)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {
        'label': 'Hangout',
        'color': Colors.purple[400]!,
        'unselectedColor': Colors.purple[100]!,
      },
      {
        'label': 'Busy',
        'color': Colors.orange[400]!,
        'unselectedColor': Colors.orange[100]!,
      },
      {
        'label': 'Weekend',
        'color': Colors.blue[400]!,
        'unselectedColor': Colors.blue[100]!,
      },
      {
        'label': 'Other',
        'color': Colors.grey[400]!,
        'unselectedColor': Colors.grey[200]!,
      },
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['label'];
          return OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = isSelected ? null : category['label'] as String;
              });
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: isSelected
                  ? category['color'] as Color
                  : category['unselectedColor'] as Color,
              foregroundColor: isSelected ? Colors.white : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: isSelected
                    ? category['color'] as Color
                    : Colors.grey[300]!,
                width: 1.0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(
              category['label'] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      maxLines: 3,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Type your notes here...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}