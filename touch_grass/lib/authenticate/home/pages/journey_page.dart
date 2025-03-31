import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  String? currentQuestion;
  String? questionId;
  final TextEditingController answerController = TextEditingController();
  bool isLoading = true;
  bool hasAnsweredToday = false;
  Duration timeUntilNextQuestion = const Duration(hours: 12);
  Timer? countdownTimer;

  int userPoints = 0; // Track the user's points
  final List<int> milestones = List.generate(80, (index) => (index + 1) * 5); // Milestones up to 2000
  String selectedCategory = 'during_walk'; // Default category

  @override
  void initState() {
    super.initState();
    fetchDailyQuestion();
    checkIfAnsweredToday();
    fetchPoints(); 
  }

  @override
  void dispose() {
    answerController.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchDailyQuestion() async {
    try {
      // Fetch questions for the selected category from Firestore
      final questionSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('category', isEqualTo: selectedCategory) // Filter by category
          .get();

      if (questionSnapshot.docs.isNotEmpty) {
        // Randomly select a question
        final randomIndex = Random().nextInt(questionSnapshot.docs.length);
        final questionData = questionSnapshot.docs[randomIndex].data();

        setState(() {
          currentQuestion = questionData['text'];
          questionId = questionSnapshot.docs[randomIndex].id;
          isLoading = false;
        });
      } else {
        setState(() {
          currentQuestion = "No questions available for this category.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        currentQuestion = "Failed to load question.";
        isLoading = false;
      });
    }
  }

  Future<void> fetchPoints() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          userPoints = userDoc.data()?['points'] ?? 0; // Fetch the points
        });
      }
    } catch (e) {
      // Handle errors if needed
      print("Failed to fetch points: $e");
    }
  }

  Future<void> checkIfAnsweredToday() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final lastAnsweredTimestamp = userDoc.data()?['lastAnswered'] as Timestamp?;
        if (lastAnsweredTimestamp != null) {
          final lastAnswered = lastAnsweredTimestamp.toDate();
          final now = DateTime.now();

          if (lastAnswered.add(const Duration(hours: 12)).isAfter(now)) {
            setState(() {
              hasAnsweredToday = true;
              final nextQuestionTime = lastAnswered.add(const Duration(hours: 12));
              timeUntilNextQuestion = nextQuestionTime.difference(now);
              startCountdown();
            });
          }
        }
      }
    } catch (e) {
      // Handle errors if needed
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeUntilNextQuestion.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          hasAnsweredToday = false;
        });
      } else {
        setState(() {
          timeUntilNextQuestion -= const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> submitAnswer() async {
    if (answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an answer.")),
      );
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final answer = answerController.text;

      // Save the answer to Firestore under the user's document
      await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(userId)
          .collection('answers')
          .add({
        'questionId': questionId,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment the user's points and update the lastAnswered timestamp
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      await userDoc.set({
        'lastAnswered': FieldValue.serverTimestamp(),
        'points': FieldValue.increment(1), // Increment points
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Answer submitted successfully!")),
      );

      // Clear the text field
      answerController.clear();

      // Mark as answered today
      setState(() {
        hasAnsweredToday = true;
        timeUntilNextQuestion = const Duration(hours: 12);
        userPoints += 1; // Update points locally
        startCountdown();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit answer.")),
      );
    }
  }

  Widget buildCategorySelector() {
    return DropdownButton<String>(
      value: selectedCategory,
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue!;
          fetchDailyQuestion(); // Fetch questions for the selected category
        });
      },
      items: <String>['during_walk', 'post_walk']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value.replaceAll('_', ' ').toUpperCase(), // Display as "DURING WALK", etc.
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget buildPointsProgressBar() {
    // Determine the current and next milestone
    int nextMilestone = milestones.firstWhere((milestone) => milestone > userPoints, orElse: () => milestones.last);
    int previousMilestone = milestones.lastWhere((milestone) => milestone <= userPoints, orElse: () => 0);

    // Handle edge case: If the points are less than the first milestone
    if (userPoints < milestones.first) {
      previousMilestone = 0; // Start from 0
    }

    // Calculate progress percentage
    double progress = (userPoints - previousMilestone) / (nextMilestone - previousMilestone);

    // Ensure progress is between 0 and 1
    progress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Points Progress: $userPoints points",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 50), // Center the bar with padding
          height: 20, // Height of the progress bar
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // Rounded corners
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.green, Colors.yellow], // Gradient colors
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Match the container's border radius
            child: LinearProgressIndicator(
              value: progress, // Correctly set the progress value
              backgroundColor: Colors.grey[300], // Background color for the bar
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50), // Align with the progress bar
              child: Text("$previousMilestone points"),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50), // Align with the progress bar
              child: Text("$nextMilestone points"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Journey"),
        centerTitle: true,
        backgroundColor: const Color(0xFFbfd37a),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                buildCategorySelector(), // Add the category selector
                Expanded(
                  child: hasAnsweredToday
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Thank you for submitting today!",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Next question in: ${timeUntilNextQuestion.inHours}:${(timeUntilNextQuestion.inMinutes % 60).toString().padLeft(2, '0')}:${(timeUntilNextQuestion.inSeconds % 60).toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currentQuestion ?? "No question available.",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: answerController,
                                decoration: const InputDecoration(
                                  hintText: "Write your answer here...",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 5,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: submitAnswer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFbfd37a),
                                ),
                                child: const Text("Submit Answer"),
                              ),
                            ],
                          ),
                        ),
                ),
                buildPointsProgressBar(), // Add points progress bar at the bottom
              ],
            ),
    );
  }
}