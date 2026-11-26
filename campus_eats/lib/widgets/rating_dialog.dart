import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class RatingDialog extends StatefulWidget {
  final Function(int rating, String comment) onSubmitted;

  const RatingDialog({super.key, required this.onSubmitted});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Rate your Meal', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How was the food and service?', style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13)),
          const SizedBox(height: 24),
          
          // Star Rating Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _rating;
              return IconButton(
                onPressed: () => setState(() => _rating = starIndex),
                icon: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: isSelected ? Colors.amber : AppTheme.onSurfaceDim,
                  size: 32,
                ),
              );
            }),
          ),
          
          const SizedBox(height: 24),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add a comment (optional)...',
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceDim)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
          onPressed: () {
            widget.onSubmitted(_rating, _commentCtrl.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
