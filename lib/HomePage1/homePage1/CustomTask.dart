import 'package:final_project/HomePage1/homePage1/DoneEditHabit.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllTask.dart';
import 'package:flutter/material.dart';

class CustomTask extends StatefulWidget {
  const CustomTask({super.key});

  @override
  _CustomTaskState createState() => _CustomTaskState();
}

class _CustomTaskState extends State<CustomTask> {
  int _selectedPeriod = 1;
  String _selectedTaskType = 'Once';
  String _customPeriod = ''; // New: stores input for custom period

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D9D9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewAllTask()),
            );
          },
        ),
        title: const Center(
          child: Text(
            'Edit Task Goal',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF2D3953),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              height: _selectedTaskType == 'Custom' ? 510 : 440,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Goal', style: TextStyle(color: Colors.black, fontSize: 18)),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Task Name', style: TextStyle(color: Colors.black, fontSize: 18)),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 42,
                    child: TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Period', style: TextStyle(color: Colors.black, fontSize: 18)),
                      Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Task Type', style: TextStyle(color: Colors.black, fontSize: 18)),
                      Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedTaskType,
                          isExpanded: true,
                          items: ['Once', 'Everyday', 'Weekly', 'Monthly', 'Custom']
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

                  // Conditionally show custom time input
                  if (_selectedTaskType == 'Custom') ...[
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Custom Period', style: TextStyle(color: Colors.black, fontSize: 18)),
                        SizedBox(
                          width: 180,
                          height: 42,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _customPeriod = value;
                              });
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              hintText: 'Enter time (e.g. 5 days)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40.0),
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Optional: you can use _customPeriod here for logic
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DoneEditTask()),
                        );
                      },
                      child: const Text(
                        'Edit Task',
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
