import 'package:final_project/HomePage1/homePage1/DoneEditHabit.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllTask.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  int _selectedPeriod = 1; // Default selected value for Period
  String _selectedTaskType = 'Once'; // Default selected value for Task Type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD9D9D9),  // AppBar background color updated
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewAllTask()),
            );
          },
        ),
        title: Center( // Center the title text in the AppBar
          child: Text(
            'Create New Task Goal ',
            style: TextStyle(color: Colors.black),  // Adjusted title color
          ),
        ),
      ),
      body: Container(
        color: Color(0xFF2D3953),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox added for gap between AppBar and container
            SizedBox(height: 100),
            
            // Container with height 500, background color white, and border radius of 2
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color set to white
                borderRadius: BorderRadius.circular(2), // Border radius for container
              ),
              height: 440, // Increased height to fit new content
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Your Goal Label
                  Text(
                    'Your Goal',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(height: 8.0),
                  // Your Goal Input Field
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2), // Border radius for input container
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Task Name Label
                  Text(
                    'Task Name',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(height: 8.0),
                  // Task Name Input Field
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2), // Border radius for input container
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Period Label and Drop-down Input Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Period',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Container(
                        width: 180, // Ensuring both dropdowns are the same size
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2), // Border radius for dropdown container
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButton<int>(
                          value: _selectedPeriod, // Displaying the selected value
                          isExpanded: true, // To make the dropdown fill the width
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
                  // Task Type Label and Drop-down Input Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task Type',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Container(
                        width: 180, // Ensuring both dropdowns are the same size
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2), // Border radius for dropdown container
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedTaskType, // Displaying the selected value
                          isExpanded: true, // To make the dropdown fill the width
                          items: [
                            'Once',
                            'Everyday',
                            'Weekly',
                            'Monthly',
                            'Custom', // Example of another option you can add
                          ]
                              .map((String taskType) =>
                                  DropdownMenuItem<String>(
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
                  SizedBox(height: 40.0),
                  // Create Now Button
                  Container(
                    width: double.infinity, // Make button take up the full width
                    height: 45, // Height of the button
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F3E0), // Button background color
                      borderRadius: BorderRadius.circular(2), // Border radius for button
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
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black, // Text color inside the button
                        ),
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
