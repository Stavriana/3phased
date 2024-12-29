import 'package:flutter/material.dart';

class CustomCounterWidget extends StatefulWidget {
  final String labelText;
  final int minValue;
  final int maxValue;
  final int initialValue;
  final Function(int) onValueChanged;

  const CustomCounterWidget({
    super.key,
    required this.labelText,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  State<CustomCounterWidget> createState() => _CustomCounterWidgetState();
}

class _CustomCounterWidgetState extends State<CustomCounterWidget> {
  late int counter;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue < widget.minValue || widget.initialValue > widget.maxValue) {
      throw ArgumentError('Initial value must be between minValue and maxValue');
    }
    counter = widget.initialValue;
  }

  void _decreaseCounter() {
    setState(() {
      if (counter > widget.minValue) {
        counter--;
        widget.onValueChanged(counter);
      }
    });
  }

  void _increaseCounter() {
    setState(() {
      if (counter < widget.maxValue) {
        counter++;
        widget.onValueChanged(counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              widget.labelText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Semantics(
                label: 'Decrease Counter',
                button: true,
                child: GestureDetector(
                  onTap: _decreaseCounter,
                  child: const Icon(Icons.remove, size: 28, color: Colors.purple),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    '$counter',
                    key: ValueKey<int>(counter),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Semantics(
                label: 'Increase Counter',
                button: true,
                child: GestureDetector(
                  onTap: _increaseCounter,
                  child: const Icon(Icons.add, size: 28, color: Colors.purple),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
