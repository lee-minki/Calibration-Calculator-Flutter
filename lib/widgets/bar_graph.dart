import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final double percentage;

  const BarGraph({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percentage.clamp(0.0, 100.0);
    
    return Column(
      children: [
        // Percentage display
        Text(
          '${pct.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Color(0xFF00D4FF),
          ),
        ),
        const SizedBox(height: 4),
        // Bar track
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Fill - aligned to left
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: pct / 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x8000D4FF),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Tick labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace')),
            Text('25', style: TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace')),
            Text('50', style: TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace')),
            Text('75', style: TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace')),
            Text('100', style: TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace')),
          ],
        ),
      ],
    );
  }
}
