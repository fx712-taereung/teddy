import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'glassCard.dart';

// GlassDialog: iOS 스타일 유리 효과 다이얼로그 위젯 (Glass effect dialog widget)
class GlassDialog extends StatelessWidget {
  final String? title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructiveAction;

  // 텍스트 필드 옵션 / Text field options
  final bool showTextField;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;

  const GlassDialog({
    Key? key,
    this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.isDestructiveAction = false,
    this.showTextField = false,
    this.prefixIcon,
    this.placeholder,
    this.controller,
    this.onSubmitted,
  }) : super(key: key);

  // 다이얼로그 가로 길이 결정 / Dialog width helper
  double _getDialogWidth(double screenWidth) {
    if (screenWidth < 500) {
      return screenWidth * 0.75;
    } else {
      return 350;
    }
  }

  // 다이얼로그 패딩 결정 / Dialog padding helper
  double _getDialogPadding(double screenWidth) {
    if (screenWidth < 350) {
      return 2;
    } else if (screenWidth < 500) {
      return 8;
    } else if (screenWidth < 800) {
      return 16;
    } else {
      return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double dialogWidth = _getDialogWidth(width);
    final double dialogPadding = _getDialogPadding(width);

    final linkTextColor = CupertinoDynamicColor.withBrightness(
      color: CupertinoColors.systemGrey4,
      darkColor: CupertinoColors.systemGrey4,
    ).resolveFrom(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: dialogPadding, vertical: 24),
      child: GlassCard(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 180,
            maxWidth: dialogWidth,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12,),
                if (title != null && title!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.96)
                            : Colors.black.withOpacity(0.90),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (title != null && title!.isNotEmpty) const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.75)
                          : Colors.black.withOpacity(0.72),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (showTextField) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: placeholder ?? tr('search_placeholder'),
                        filled: true,
                        fillColor: CupertinoColors.systemGrey.withOpacity(0.125),
                        prefixIcon: prefixIcon,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.5),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      onSubmitted: onSubmitted,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    // 취소 버튼 / Cancel button
                    Expanded(
                      child: GlassCard(
                        minWidthMax: true,
                        padding: EdgeInsets.zero,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          onPressed: onCancel ?? () => Navigator.of(context).pop(),
                          child: Text(
                            cancelText ?? tr('cancel'),
                            style: TextStyle(
                              color: linkTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 확인 버튼 / Confirm button
                    Expanded(
                      child: GlassCard(
                        minWidthMax: true,
                        padding: EdgeInsets.zero,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                          child: Text(
                            confirmText ?? tr('confirm'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}