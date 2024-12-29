import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Slider Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SliderExamplePage(),
    );
  }
}

class SliderExamplePage extends StatefulWidget {
  const SliderExamplePage({super.key});

  @override
  State<SliderExamplePage> createState() => _SliderExamplePageState();
}

class _SliderExamplePageState extends State<SliderExamplePage> {
  double sliderValue = 50.0;

  void handleSliderChange(double value) {
    setState(() {
      sliderValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Slider Example'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Unfocus any active input fields
        },
        child: Center(
          child: CustomSliderWidget(
            labelText: 'Adjust Timer',
            minValue: 0,
            maxValue: 100,
            stepSize: 1,
            initialValue: sliderValue,
            onChanged: handleSliderChange,
          ),
        ),
      ),
    );
  }
}

class CustomSliderWidget extends StatefulWidget {
  final String labelText;
  final double minValue;
  final double maxValue;
  final double stepSize;
  final double initialValue;
  final ValueChanged<double> onChanged;

  const CustomSliderWidget({
    super.key,
    required this.labelText,
    required this.minValue,
    required this.maxValue,
    required this.stepSize,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<CustomSliderWidget> createState() => _CustomSliderWidgetState();
}

class _CustomSliderWidgetState extends State<CustomSliderWidget> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    activeTrackColor: Colors.grey.shade500,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: const Color(0xFFE8D012),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: widget.minValue,
                    max: widget.maxValue,
                    divisions: ((widget.maxValue - widget.minValue) /
                            widget.stepSize)
                        .round(),
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                        widget.onChanged(value);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${_currentValue.toInt()}s",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8D012),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
