import 'package:flutter/material.dart';

class ShimmerBorderContainer extends StatefulWidget {
  const ShimmerBorderContainer({super.key});

  @override
  State<ShimmerBorderContainer> createState() => _ShimmerBorderContainerState();
}

class _ShimmerBorderContainerState extends State<ShimmerBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: SweepGradient(
              colors: [
                const Color(0xffDE0CF2),
                Color(0xff0499EF),
                const Color(0xffDE0CF2),
                Color(0xff0499EF),
              ],
             stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(_controller.value * 6.28),
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D),
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 185, 112, 1), Color.fromARGB(255, 163, 98, 0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              "Search your items here",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
