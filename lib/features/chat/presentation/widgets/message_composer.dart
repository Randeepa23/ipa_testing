import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onSavedResponse,
    required this.onInternalNote,
    required this.onTransfer,
    required this.onResolve,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onSavedResponse;
  final VoidCallback onInternalNote;
  final VoidCallback onTransfer;
  final VoidCallback onResolve;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onSavedResponse,
                  icon: const Icon(Icons.library_books_outlined),
                ),
                IconButton(
                  onPressed: onInternalNote,
                  icon: const Icon(Icons.note_add_outlined),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onTransfer,
                  child: const Text('Transfer'),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: onResolve, child: const Text('Resolve')),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: enabled ? onSend : null,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
