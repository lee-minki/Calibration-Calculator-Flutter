import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/keypad.dart';

class PositionerCalculatorScreen extends StatefulWidget {
  const PositionerCalculatorScreen({super.key});

  @override
  State<PositionerCalculatorScreen> createState() => _PositionerCalculatorScreenState();
}

class _PositionerCalculatorScreenState extends State<PositionerCalculatorScreen> {
  // Buffers
  String sensorZeroMa = '4';
  String sensorSpanMa = '20';
  String physZeroMa = '5.5';
  String physSpanMa = '18.5';
  String desiredZeroPct = '-0.5';
  String desiredSpanPct = '99.5';
  
  // Focus
  String focusElement = 'physZeroMa';
  bool freshFocus = false;

  Map<String, double> get dcsResult {
    final zeroMa = double.tryParse(physZeroMa) ?? 0;
    final spanMa = double.tryParse(physSpanMa) ?? 0;
    final zeroPct = double.tryParse(desiredZeroPct) ?? 0;
    final spanPct = double.tryParse(desiredSpanPct) ?? 100;
    
    if (spanPct == zeroPct) {
      return {'dcsZeroMa': zeroMa, 'dcsSpanMa': spanMa};
    }
    
    final slope = (spanMa - zeroMa) / (spanPct - zeroPct);
    final dcsZeroMa = zeroMa + (0 - zeroPct) * slope;
    final dcsSpanMa = zeroMa + (100 - zeroPct) * slope;
    
    return {'dcsZeroMa': dcsZeroMa, 'dcsSpanMa': dcsSpanMa};
  }

  String get currentBuffer {
    switch (focusElement) {
      case 'sensorZeroMa': return sensorZeroMa;
      case 'sensorSpanMa': return sensorSpanMa;
      case 'physZeroMa': return physZeroMa;
      case 'physSpanMa': return physSpanMa;
      case 'desiredZeroPct': return desiredZeroPct;
      case 'desiredSpanPct': return desiredSpanPct;
      default: return physZeroMa;
    }
  }

  void setBuffer(String value) {
    setState(() {
      switch (focusElement) {
        case 'sensorZeroMa': sensorZeroMa = value; break;
        case 'sensorSpanMa': sensorSpanMa = value; break;
        case 'physZeroMa': physZeroMa = value; break;
        case 'physSpanMa': physSpanMa = value; break;
        case 'desiredZeroPct': desiredZeroPct = value; break;
        case 'desiredSpanPct': desiredSpanPct = value; break;
      }
    });
  }

  void handleKey(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      String buffer = currentBuffer;
      
      switch (key) {
        case 'CA':
          sensorZeroMa = '4';
          sensorSpanMa = '20';
          physZeroMa = '5.5';
          physSpanMa = '18.5';
          desiredZeroPct = '-0.5';
          desiredSpanPct = '99.5';
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

  void setFocus(String field) {
    HapticFeedback.selectionClick();
    setState(() {
      focusElement = field;
      freshFocus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = dcsResult;
    final zeroPct = double.tryParse(desiredZeroPct) ?? 0;
    final spanPct = double.tryParse(desiredSpanPct) ?? 100;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Sensor mA Range Section
          _buildSectionCard(
            'SENSOR mA RANGE (센서 범위)',
            Row(
              children: [
                Expanded(child: _buildInputCard('Zero mA', sensorZeroMa, 'sensorZeroMa')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputCard('Span mA', sensorSpanMa, 'sensorSpanMa')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Physical Measurement Section
          _buildSectionCard(
            'PHYSICAL MEASUREMENT (현장 측정값)',
            Row(
              children: [
                Expanded(child: _buildInputCard('Zero Position mA', physZeroMa, 'physZeroMa')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputCard('Span Position mA', physSpanMa, 'physSpanMa')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Desired DCS Range Section
          _buildSectionCard(
            'DESIRED DCS RANGE (원하는 표시 범위)',
            Row(
              children: [
                Expanded(child: _buildInputCard('Zero Point %', desiredZeroPct, 'desiredZeroPct')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputCard('Span Point %', desiredSpanPct, 'desiredSpanPct')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Result Section
          _buildResultSection(result),
          const SizedBox(height: 8),
          
          // Zone Graph
          _buildZoneGraph(zeroPct, spanPct),
          const SizedBox(height: 12),
          
          // Keypad
          Keypad(
            onKey: handleKey,
            showPercentageRow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF19192A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInputCard(String label, String value, String field) {
    final isActive = focusElement == field;
    return GestureDetector(
      onTap: () => setFocus(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF00D4FF) : Colors.transparent,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF00D4FF),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(Map<String, double> result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DCS SETTING (설정값)',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildResultBox('0% mA', result['dcsZeroMa']!)),
              const SizedBox(width: 8),
              Expanded(child: _buildResultBox('100% mA', result['dcsSpanMa']!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox(String label, double value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Color(0xFF00D4FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneGraph(double zeroPct, double spanPct) {
    return Row(
      children: [
        // Zero Zone (-5 to 5)
        Expanded(child: _buildZone('Zero Zone', zeroPct, -5, 5)),
        const SizedBox(width: 8),
        // Span Zone (95 to 105)
        Expanded(child: _buildZone('Span Zone', spanPct, 95, 105)),
      ],
    );
  }

  Widget _buildZone(String title, double value, double min, double max) {
    final position = ((value - min) / (max - min)).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 6),
          // Track with marker and tick marks
          SizedBox(
            height: 40,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background track
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Tick marks (0.5% small, 1% large)
                    ...List.generate(21, (i) {
                      final tickValue = min + (i * 0.5);
                      final tickPos = (i / 20) * trackWidth;
                      final isLargeTick = i % 2 == 0; // 1% intervals
                      final isCenterTick = i == 10; // 0% or 100%
                      
                      return Positioned(
                        left: tickPos - 0.5,
                        top: isLargeTick ? 6 : 10,
                        child: Container(
                          width: 1,
                          height: isLargeTick ? 24 : 16,
                          color: isCenterTick 
                            ? const Color(0xFF00D4FF) 
                            : Colors.white24,
                        ),
                      );
                    }),
                    // Marker
                    Positioned(
                      left: position * (trackWidth - 6),
                      top: 8,
                      child: Container(
                        width: 6,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          // Tick labels (1% intervals only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (i) {
              final labelValue = (min + i).toInt();
              final isCenterLabel = i == 5;
              return SizedBox(
                width: 20,
                child: Text(
                  '$labelValue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: isCenterLabel ? FontWeight.bold : FontWeight.normal,
                    color: isCenterLabel ? const Color(0xFF00D4FF) : Colors.white38,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          // Current value
          Text(
            '$value%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Color(0xFF00D4FF),
            ),
          ),
        ],
      ),
    );
  }
}
