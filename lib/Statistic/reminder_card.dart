import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String time;

  const ReminderCard({super.key, 
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.black),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(time, style: TextStyle(color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
