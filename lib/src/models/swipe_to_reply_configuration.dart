/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:flutter/material.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class SwipeToReplyConfiguration {
  /// Used to give color of reply icon while swipe to reply.
  final Color? replyIconColor;

  /// Used to give animation duration while swipe to reply.
  /// Duration for background builder [backgroundBuilder].
  final Duration? animationDuration;

  /// BackgroundBuilder on Swipe gesture.
  final Widget Function(BuildContext context, SwipeDirection direction,
      AnimationController progress, double value)? backgroundBuilder;

  /// Provides callback when user swipe chat bubble from left side.
  final void Function(String message, String sendBy)? onLeftSwipe;

  /// Provides callback when user swipe chat bubble from right side.
  final void Function(String message, String sendBy)? onRightSwipe;

  const SwipeToReplyConfiguration({
    this.replyIconColor,
    this.animationDuration,
    this.onRightSwipe,
    this.backgroundBuilder,
    this.onLeftSwipe,
  });
}
