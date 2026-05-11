import 'package:flutter/material.dart';

class Keypad extends StatelessWidget {
  final Function(String) onKey;
  final Function(int)? onPercentage;
  final bool showPercentageRow;

  const Keypad({
    super.key,
    required this.onKey,
    this.onPercentage,
    this.showPercentageRow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Percentage row (only for Loop calculator)
        if (showPercentageRow) ...[
          Row(
            children: [
              _buildPctKey(0),
              _buildPctKey(25),
              _buildPctKey(50),
              _buildPctKey(75),
              _buildPctKey(100),
            ],
          ),
          const SizedBox(height: 6),
        ],
        // Number keys
        Row(
          children: [
            _buildKey('7'),
            _buildKey('8'),
            _buildKey('9'),
            _buildFuncKey('CA'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildKey('4'),
            _buildKey('5'),
            _buildKey('6'),
            _buildFuncKey('C'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildKey('1'),
            _buildKey('2'),
            _buildKey('3'),
            _buildFuncKey('⌫'),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildKey('0'),
            _buildKey('.'),
            _buildFuncKey('±'),
            _buildCalcKey('Calc'),
          ],
        ),
      ],
    );
  }

  Widget _buildPctKey(int pct) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onPercentage?.call(pct),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              '$pct%',
              style: const TextStyle(fontSize: 12, color: Color(0xFFA78BFA)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onKey(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF19192A).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFuncKey(String key) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onKey(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF19192A).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'monospace',
                color: Color(0xFFFB923C),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalcKey(String key) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onKey('enter'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0A0F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
