import 'package:flutter/material.dart';

class RhetoricalMoveBadge extends StatelessWidget {
  final String move;
  final double? confidence;
  final bool isCompact;
  final bool showConfidence;

  const RhetoricalMoveBadge({
    super.key,
    required this.move,
    this.confidence,
    this.isCompact = false,
    this.showConfidence = true,
  });

  static Color getMoveColor(String move) {
    switch (move.toUpperCase()) {
      case 'BACKGROUND':
        return const Color(0xFF475569);
      case 'PURPOSE':
        return const Color(0xFF4338CA);
      case 'METHOD':
        return const Color(0xFF0D9488);
      case 'RESULT':
        return const Color(0xFF059669);
      case 'CONCLUSION':
        return const Color(0xFF7C3AED);
      case 'GAP':
        return const Color(0xFFD97706);
      case 'CONTRIBUTION':
        return const Color(0xFFE11D48);
      case 'LIMITATION':
        return const Color(0xFFB45309);
      case 'COMPARISON':
        return const Color(0xFF0891B2);
      case 'INTERPRETATION':
        return const Color(0xFF6D28D9);
      default:
        return const Color(0xFF64748B);
    }
  }

  static Color getMoveBg(String move) {
    switch (move.toUpperCase()) {
      case 'BACKGROUND':
        return const Color(0xFFF1F5F9);
      case 'PURPOSE':
        return const Color(0xFFEEF2FF);
      case 'METHOD':
        return const Color(0xFFF0FDFA);
      case 'RESULT':
        return const Color(0xFFECFDF5);
      case 'CONCLUSION':
        return const Color(0xFFF5F3FF);
      case 'GAP':
        return const Color(0xFFFFFBEB);
      case 'CONTRIBUTION':
        return const Color(0xFFFFF1F2);
      case 'LIMITATION':
        return const Color(0xFFFEF3C7);
      case 'COMPARISON':
        return const Color(0xFFECFEFF);
      case 'INTERPRETATION':
        return const Color(0xFFEDE9FE);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static String getVietnameseLabel(String move) {
    switch (move.toUpperCase()) {
      case 'BACKGROUND':
        return 'Bối cảnh';
      case 'PURPOSE':
        return 'Mục tiêu';
      case 'METHOD':
        return 'Phương pháp';
      case 'RESULT':
        return 'Kết quả';
      case 'CONCLUSION':
        return 'Kết luận';
      case 'GAP':
        return 'Khoảng trống';
      case 'CONTRIBUTION':
        return 'Đóng góp';
      case 'LIMITATION':
        return 'Hạn chế';
      case 'COMPARISON':
        return 'So sánh';
      case 'INTERPRETATION':
        return 'Biện luận';
      default:
        return 'Khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getMoveColor(move);
    final bg = getMoveBg(move);
    final label = getVietnameseLabel(move);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$move ($label)',
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Manrope',
            ),
          ),
          if (showConfidence && confidence != null) ...[
            const SizedBox(width: 6),
            Text(
              '${(confidence! * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: isCompact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: color.withAlpha(200),
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
