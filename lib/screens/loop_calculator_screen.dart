import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/keypad.dart';
import '../widgets/bar_graph.dart';

class LoopCalculatorScreen extends StatefulWidget {
  const LoopCalculatorScreen({super.key});

  @override
  State<LoopCalculatorScreen> createState() => _LoopCalculatorScreenState();
}

class _LoopCalculatorScreenState extends State<LoopCalculatorScreen> {
  // Buffers
  String inputLow = '0';
  String inputHigh = '100';
  String outputLow = '4';
  String outputHigh = '20';
  String inputValue = '0';
  
  // Focus
  String focusElement = 'inputValue';
  bool freshFocus = false;

  double get result {
    final iLow = double.tryParse(inputLow) ?? 0;
    final iHigh = double.tryParse(inputHigh) ?? 100;
    final oLow = double.tryParse(outputLow) ?? 4;
    final oHigh = double.tryParse(outputHigh) ?? 20;
    final iVal = double.tryParse(inputValue) ?? 0;
    
    if (iHigh == iLow) return oLow;
    return oLow + ((iVal - iLow) / (iHigh - iLow)) * (oHigh - oLow);
  }

  double get percentage {
    final oLow = double.tryParse(outputLow) ?? 4;
    final oHigh = double.tryParse(outputHigh) ?? 20;
    if (oHigh == oLow) return 0;
    return ((result - oLow) / (oHigh - oLow)) * 100;
  }

  String get currentBuffer {
    switch (focusElement) {
      case 'inputLow': return inputLow;
      case 'inputHigh': return inputHigh;
      case 'outputLow': return outputLow;
      case 'outputHigh': return outputHigh;
      default: return inputValue;
    }
  }

  void setBuffer(String value) {
    setState(() {
      switch (focusElement) {
        case 'inputLow': inputLow = value; break;
        case 'inputHigh': inputHigh = value; break;
        case 'outputLow': outputLow = value; break;
        case 'outputHigh': outputHigh = value; break;
        default: inputValue = value;
      }
    });
  }

  void handleKey(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      String buffer = currentBuffer;
      
      switch (key) {
        case 'CA':
          inputLow = '0';
          inputHigh = '100';
          outputLow = '4';
          outputHigh = '20';
          inputValue = '0';
          freshFocus = false;
          break;
        case 'C':
          setBuffer('0');
          freshFocus = false;
          break;
        case '⌫':
          setBuffer(buffer.length > 1 ? buffer.substring(0, buffer.length - 1) : '0');
          freshFocus = false;
          break;
        case '±':
          if (buffer.startsWith('-')) {
            setBuffer(buffer.substring(1));
          } else if (buffer != '0') {
            setBuffer('-$buffer');
          }
          freshFocus = false;
          break;
        case '.':
          if (freshFocus) {
            setBuffer('0.');
          } else if (!buffer.contains('.')) {
            setBuffer('$buffer.');
          }
          freshFocus = false;
          break;
        default:
          if (RegExp(r'^\d$').hasMatch(key)) {
            if (freshFocus) {
              setBuffer(key);
            } else {
              setBuffer(buffer == '0' ? key : buffer + key);
            }
            freshFocus = false;
          }
      }
    });
  }

  void handlePercentage(int pct) {
    HapticFeedback.mediumImpact();
    final iLow = double.tryParse(inputLow) ?? 0;
    final iHigh = double.tryParse(inputHigh) ?? 100;
    final value = iLow + (pct / 100) * (iHigh - iLow);
    setState(() {
      inputValue = value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      focusElement = 'inputValue';
    });
  }

  void setFocus(String field) {
    HapticFeedback.selectionClick();
    setState(() {
      focusElement = field;
      freshFocus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Range Inputs
          Row(
            children: [
              Expanded(child: _buildRangeCard('INPUT LOW', inputLow, 'inputLow')),
              const SizedBox(width: 8),
              Expanded(child: _buildRangeCard('INPUT HIGH', inputHigh, 'inputHigh')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildRangeCard('OUTPUT LOW', outputLow, 'outputLow')),
              const SizedBox(width: 8),
              Expanded(child: _buildRangeCard('OUTPUT HIGH', outputHigh, 'outputHigh')),
            ],
          ),
          const SizedBox(height: 12),
          
          // Main Display
          _buildMainDisplay(),
          const SizedBox(height: 8),
          
          // Result Display
          _buildResultDisplay(),
          const SizedBox(height: 12),
          
          // Keypad
          Keypad(
            onKey: handleKey,
            onPercentage: handlePercentage,
            showPercentageRow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeCard(String label, String value, String field) {
    final isActive = focusElement == field;
    return GestureDetector(
      onTap: () => setFocus(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF19192A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF00D4FF) : Colors.white10,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF00D4FF),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDisplay() {
    final isActive = focusElement == 'inputValue';
    return GestureDetector(
      onTap: () => setFocus('inputValue'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF19192A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF00D4FF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
              blurRadius: 15,
            ),
          ] : null,
        ),
        child: Column(
          children: [
            const Text(
              'INPUT VALUE',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white38,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              inputValue,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    final pct = percentage.clamp(0.0, 100.0).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'OUTPUT VALUE',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), ''),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(height: 8),
          BarGraph(percentage: pct),
        ],
      ),
    );
  }
}
