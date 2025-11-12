// import 'package:flutter/material.dart';
//
// class DefaultSearchField extends StatelessWidget {
//   const DefaultSearchField ({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(
//           Icons.search_rounded,
//           color: theme.colorScheme.onSurface.withOpacity(0.5),
//         ),
//         suffixIcon: controller.text.isNotEmpty
//             ? IconButton(
//           icon: Icon(
//             Icons.clear_rounded,
//             color: theme.colorScheme.onSurface.withOpacity(0.5),
//           ),
//           onPressed: () {
//             controller.clear();
//           },
//         )
//             : null,
//         filled: true,
//         fillColor: theme.colorScheme.surface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: theme.colorScheme.primary,
//             width: 2,
//           ),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//       ),
//     );
//   }
// }
