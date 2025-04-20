import 'package:final_project/HomePage1/homePage1/ReminderHabits.dart';
import 'package:flutter/material.dart';
import 'DoneEditHabit.dart'; // Make sure this import is added

class CustomHabit extends StatefulWidget {
  const CustomHabit({super.key});

  @override
  State<CustomHabit> createState() => _CustomHabitState();
}

class _CustomHabitState extends State<CustomHabit> {
  final List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
  ];

  final List<String> colorNames = [
    "Red",
    "Orange",
    "Yellow",
    "Green",
    "Blue",
    "Indigo",
    "Purple",
    "Pink",
    "Brown",
    "Grey",
    "Cyan",
    "Teal",
    "Amber",
    "Lime",
    "Deep Orange",
    "Deep Purple",
  ];

  int selectedColorIndex = 0;
  int selectedGoal = 1;
  String displayGoalText = '';
  bool isReminderOn = false;
  String selectedFrequency = 'Everyday';
  int reminderHours = 0;
  int reminderMinutes = 0;
  int reminderTimes = 0;
  String reminderText = '';
  bool isEditingReminder = false;

  void _showGoalInputDialog() {
    String goalInput = '';
    String frequency = selectedFrequency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                goalInput = value;
              },
              decoration: InputDecoration(hintText: 'Enter number of times'),
            ),
            ListTile(
              title: Text("Everyday"),
              leading: Radio<String>(
                value: 'Everyday',
                groupValue: frequency,
                onChanged: (value) {
                  setState(() {
                    frequency = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Weekly"),
              leading: Radio<String>(
                value: 'Weekly',
                groupValue: frequency,
                onChanged: (value) {
                  setState(() {
                    frequency = value!;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedGoal = int.tryParse(goalInput) ?? 1;
                selectedFrequency = frequency;
                displayGoalText = '$selectedGoal time $selectedFrequency';
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReminderInputDialog() {
    String hoursInput = '';
    String minutesInput = '';
    String timesInput = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                hoursInput = value;
              },
              decoration: InputDecoration(hintText: 'Enter hours'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minutesInput = value;
              },
              decoration: InputDecoration(hintText: 'Enter minutes'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                timesInput = value;
              },
              decoration: InputDecoration(hintText: 'Enter number of times'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                reminderHours = int.tryParse(hoursInput) ?? 0;
                reminderMinutes = int.tryParse(minutesInput) ?? 0;
                reminderTimes = int.tryParse(timesInput) ?? 0;
                reminderText =
                    '$reminderHours hours, $reminderMinutes minutes, $reminderTimes times';
                isEditingReminder = false;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3953),
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Create Custom Habit',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10),
                    hintText: "Enter habit name",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ICON AND COLOR
              Container(
                width: 370,
                height: 120,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ICON AND COLOR", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 165,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_walk, size: 24, color: Colors.black),
                              SizedBox(width: 8),
                              Text("Walking", style: TextStyle(fontSize: 20, color: Colors.black)),
                            ],
                          ),
                        ),
                        Container(
                          width: 165,
                          height: 68,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => GridView.count(
                                      padding: EdgeInsets.all(12),
                                      crossAxisCount: 4,
                                      shrinkWrap: true,
                                      children: List.generate(colors.length, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedColorIndex = index;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: colors[index],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.black26),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colors[selectedColorIndex],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.black26),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  colorNames[selectedColorIndex],
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // GOAL SECTION
              Container(
                width: 370,
                height: 180,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("GOAL", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayGoalText.isEmpty ? "$selectedGoal time" : displayGoalText,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              _showGoalInputDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedFrequency = 'Everyday';
                            });
                          },
                          icon: Icon(Icons.calendar_today, color: Colors.black),
                          label: Text("Everyday", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedFrequency = 'Weekly';
                            });
                          },
                          icon: Icon(Icons.calendar_today, color: Colors.black),
                          label: Text("Weekly", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Reminder Section
              
              // Add Reminder Button
              Container(
                width: 370,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFFF3F3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReminderHabits()),
                    );
                  },
                  child: Text(
                    "Add Reminder",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Add Habit Button
              Container(
                width: 370,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFF3843FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    // Navigate to DoneEditHabit.dart when the button is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DoneEditHabit()),
                    );
                  },
                  child: Text(
                    'Add Habit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
