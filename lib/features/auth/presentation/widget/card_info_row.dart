import 'package:flutter/material.dart';

class CardInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const CardInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.multiline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.fade,
            softWrap: multiline,
          ),
        ),
      ],
    );
  }
}