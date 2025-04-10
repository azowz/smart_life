import 'package:final_project/HomePage1/homePage1/DoneEditHabit.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllTask.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  int _selectedPeriod = 1;
  String _selectedTaskType = 'Once';
  String _customDuration = ''; // <-- Added custom duration state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewAllTask()),
            );
          },
        ),
        title: Center(
          child: Text(
            'Create New Task Goal ',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF2D3953),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              height: 500, // <-- Slightly increased to fit new field
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Goal', style: TextStyle(color: Colors.black, fontSize: 18)),
                  SizedBox(height: 8.0),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text('Task Name', style: TextStyle(color: Colors.black, fontSize: 18)),
                  SizedBox(height: 8.0),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Period', style: TextStyle(color: Colors.black, fontSize: 18)),
                      Container(
                        width: 180,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButton<int>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          items: List.generate(
                            30,
                            (index) => DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text('${index + 1} days'),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Task Type', style: TextStyle(color: Colors.black, fontSize: 18)),
                      Container(
                        width: 180,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedTaskType,
                          isExpanded: true,
                          items: [
                            'Once',
                            'Everyday',
                            'Weekly',
                            'Monthly',
                            'Custom',
                          ]
                              .map((String taskType) => DropdownMenuItem<String>(
                                    value: taskType,
                                    child: Text(taskType),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTaskType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Custom duration input appears only if "Custom" is selected
                  if (_selectedTaskType == 'Custom') ...[
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Custom Duration', style: TextStyle(color: Colors.black, fontSize: 18)),
                        Container(
                          width: 180,
                          height: 42,
                          child: TextField(
                            onChanged: (val) => _customDuration = val,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "e.g. 5 Days",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 30.0),
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F3E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DoneEditTask()),
                        );
                      },
                      child: Text(
                        'Create Now',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
