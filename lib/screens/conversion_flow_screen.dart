
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(home: ConversionFlowScreen()));
}

class ConversionFlowScreen extends StatefulWidget {
  const ConversionFlowScreen({super.key});

  @override
  State<ConversionFlowScreen> createState() => _ConversionFlowScreenState();
}

class _ConversionFlowScreenState extends State<ConversionFlowScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Flow'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          setState(() {
            if (_currentStep < 3) {
              _currentStep += 1;
            } else {
              // Last step, process the file
            }
          });
        },
        onStepCancel: () {
          setState(() {
            if (_currentStep > 0) {
              _currentStep -= 1;
            } else {
              Navigator.of(context).pop();
            }
          });
        },
        steps: const [
          Step(
            title: Text('File Picker'),
            content: Text('File Picker UI'),
          ),
          Step(
            title: Text('Text Editor'),
            content: Text('Text Editor UI'),
          ),
          Step(
            title: Text('Audio Config'),
            content: Text('Audio Config UI'),
          ),
          Step(
            title: Text('Processing'),
            content: Text('Processing UI'),
          ),
        ],
      ),
    );
  }
}
