import 'package:flutter/material.dart';
import '../repositories/habit_repository.dart';
import '../api/models/default_habit.dart';

class SignUpPage2 extends StatefulWidget {
  final String
      userId; // Mantenemos como String ya que así viene en el código original

  const SignUpPage2({Key? key, required this.userId}) : super(key: key);

  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final HabitRepository _habitRepository = HabitRepository();
  final Set<String> _selectedHabits = {};
  List<DefaultHabit> _defaultHabits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDefaultHabits();
  }

  Future<void> _loadDefaultHabits() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load default habits from API
      final habits = await _habitRepository.getDefaultHabits();

      setState(() {
        _defaultHabits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load habits: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(String habit) {
    setState(() {
      if (_selectedHabits.contains(habit)) {
        _selectedHabits.remove(habit);
      } else {
        _selectedHabits.add(habit);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_selectedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one habit')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Corregido para usar userId
      bool success = await _habitRepository.bulkAssignHabitsByName(
        userId: widget.userId, // Cambiado de username a userId
        habitNames: _selectedHabits.toList(),
      );

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage3(
              userId: widget.userId, // Cambiado de username a userId
              selectedHabits: _selectedHabits,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save habits. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Map habit names to their appropriate icons
  IconData _getIconForHabit(String habit) {
    switch (habit.toLowerCase()) {
      case 'drink water':
        return Icons.local_drink;
      case 'run':
        return Icons.directions_run;
      case 'study':
        return Icons.school;
      case 'journal':
        return Icons.book;
      case 'read book':
        return Icons.bookmark;
      case 'sleep':
        return Icons.bed;
      case 'swimming':
        return Icons.pool;
      case 'meditation':
        return Icons.self_improvement;
      case 'exercise':
        return Icons.fitness_center;
      case 'coding':
        return Icons.code;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildHabitContainer(String name, IconData icon) {
    return GestureDetector(
      onTap: () => _toggleSelection(name),
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedHabits.contains(name)
                ? Colors.blue
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _defaultHabits.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null && _defaultHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDefaultHabits,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F3E0),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    }

    // If we have habits from API, use them
    if (_defaultHabits.isNotEmpty) {
      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: _defaultHabits.length,
            itemBuilder: (context, index) {
              final habit = _defaultHabits[index];
              final icon = _getIconForHabit(habit.name);
              return _buildHabitContainer(habit.name, icon);
            },
          ),
        ],
      );
    }

    // Fallback to predefined habits if API returns empty
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHabitContainer('Drink Water', Icons.local_drink),
            _buildHabitContainer('Run', Icons.directions_run),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHabitContainer('Study', Icons.school),
            _buildHabitContainer('Journal', Icons.book),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHabitContainer('Read Book', Icons.bookmark),
            _buildHabitContainer('Sleep', Icons.bed),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHabitContainer('Swimming', Icons.pool),
            _buildHabitContainer('Meditation', Icons.self_improvement),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        title: const Center(
          child: Text(
            'Create Account',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF2D3953),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Choose your first habits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  'You may add more habits later',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic content based on API data
              _buildContent(),

              const SizedBox(height: 40),

              if (_isLoading && _defaultHabits.isNotEmpty)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white)),

              if (!_isLoading)
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F3E0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      minimumSize: const Size(345, 52),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 20),
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

// Actualizado el SignUpPage3 para usar userId en lugar de username
class SignUpPage3 extends StatelessWidget {
  final String userId;
  final Set<String> selectedHabits;

  const SignUpPage3({
    Key? key,
    required this.userId,
    required this.selectedHabits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual implementation
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        title: const Text('Complete Sign Up'),
      ),
      body: Container(
        color: const Color(0xFF2D3953),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Account created successfully!',
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'User ID: $userId', // Cambiado de username a userId
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Selected Habits: ${selectedHabits.join(", ")}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F3E0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  minimumSize: const Size(345, 52),
                ),
                onPressed: () {
                  // Navigate to the main app screen
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
