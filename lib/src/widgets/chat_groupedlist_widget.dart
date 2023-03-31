// ignore_for_file: unused_element

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
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/utils/constants/constants.dart';
import 'package:chatview/src/widgets/chat_view_inherited_widget.dart';
import 'package:chatview/src/widgets/type_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list_extended/scrollable_positioned_list_extended.dart';
// import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import 'chat_bubble_widget.dart';
import 'chat_group_header.dart';

class ChatGroupedListWidget extends StatefulWidget {
  const ChatGroupedListWidget({
    Key? key,
    required this.showPopUp,
    required this.showTypingIndicator,
    required this.scrollController,
    required this.chatBackgroundConfig,
    required this.replyMessage,
    required this.assignReplyMessage,
    required this.onChatListTap,
    required this.onChatBubbleLongPress,
    required this.isEnableSwipeToSeeTime,

    this.messageConfig,
    this.chatBubbleConfig,
    this.profileCircleConfig,
    this.swipeToReplyConfig,
    this.repliedMessageConfig,
    this.typeIndicatorConfig,
    this.reactionPopupConfig,
  }) : super(key: key);

  /// Allow user to swipe to see time while reaction pop is not open.
  final bool showPopUp;

  /// Allow user to show typing indicator.
  final bool showTypingIndicator;
  final ItemScrollController scrollController;

  /// Allow user to give customisation to background of chat
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Allow user to giving customisation different types
  /// messages
  final MessageConfiguration? messageConfig;

  /// Allow user to giving customisation to chat bubble
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Allow user to giving customisation to profile circle
  final ProfileCircleConfiguration? profileCircleConfig;

  /// Allow user to giving customisation to swipe to reply
  final SwipeToReplyConfiguration? swipeToReplyConfig;
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Allow user to giving customisation typing indicator
  final TypeIndicatorConfiguration? typeIndicatorConfig;

  /// Provides reply message if actual message is sent by replying any message.
  final ReplyMessage replyMessage;

  /// Provides callback for assigning reply message when user swipe on chat bubble.
  final MessageCallBack assignReplyMessage;

  /// Provides callback when user tap anywhere on whole chat.
  final VoidCallBack onChatListTap;

  /// Provides callback when user press chat bubble for certain time then usual.
  final void Function(double, double, Message) onChatBubbleLongPress;

  /// Provide flag for turn on/off to see message crated time view when user
  /// swipe whole chat.
  final bool isEnableSwipeToSeeTime;

  final ReactionPopupConfiguration? reactionPopupConfig;



  @override
  State<ChatGroupedListWidget> createState() => _ChatGroupedListWidgetState();
}

class _ChatGroupedListWidgetState extends State<ChatGroupedListWidget>
    with TickerProviderStateMixin {
  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  bool get showPopUp => widget.showPopUp;

  bool get showTypingIndicator => widget.showTypingIndicator;

  bool highlightMessage = false;
  final ValueNotifier<String?> _replyId = ValueNotifier(null);

  ChatBubbleConfiguration? get chatBubbleConfig => widget.chatBubbleConfig;

  ProfileCircleConfiguration? get profileCircleConfig =>
      widget.profileCircleConfig;
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  FeatureActiveConfig? featureActiveConfig;

  ChatController? chatController;

  bool get isEnableSwipeToSeeTime => widget.isEnableSwipeToSeeTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _autoGetPosition();
  }

  void _autoGetPosition() {
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.scrollController.scrollListener(
        (notification) {
          /// do with notification
        },
      );
    });
  }

  void _initializeAnimation() {
    // When this flag is on at that time only animation controllers will be
    // initialized.
    if (isEnableSwipeToSeeTime) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      );
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(
        CurvedAnimation(
          curve: Curves.decelerate,
          parent: _animationController!,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      chatController = provide!.chatController;
    }
    _initializeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) => isEnableSwipeToSeeTime
          ? showPopUp
              ? null
              : _onHorizontalDrag(details)
          : null,
      onHorizontalDragEnd: (details) => isEnableSwipeToSeeTime
          ? showPopUp
              ? null
              : _animationController?.reverse()
          : null,
      onTap: widget.onChatListTap,
      child: Column(
        children: [
          Flexible(
            child: _animationController != null
                ? AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      return _chatStreamBuilder;
                    },
                  )
                : _chatStreamBuilder,
          ),
          widget.showTypingIndicator
              ? TypingIndicator(
                  typeIndicatorConfig: widget.typeIndicatorConfig,
                  chatBubbleConfig: chatBubbleConfig?.inComingChatBubbleConfig,
                  showIndicator: widget.showTypingIndicator,
                  profilePic: profileCircleConfig?.profileImageUrl,
                )
              : ValueListenableBuilder(
                  valueListenable: ChatViewInheritedWidget.of(context)!
                      .chatController
                      .typingIndicatorNotifier,
                  builder: (context, value, child) => TypingIndicator(
                        typeIndicatorConfig: widget.typeIndicatorConfig,
                        chatBubbleConfig:
                            chatBubbleConfig?.inComingChatBubbleConfig,
                        showIndicator: value as bool,
                        profilePic: profileCircleConfig?.profileImageUrl,
                      )),
          SizedBox(
            height: MediaQuery.of(context).size.width *
                (widget.replyMessage.message.isNotEmpty ? 0.3 : 0.14),
          ),
        ],
      ),
    );
  }

  Future<void> _onReplyTap(String id, List<Message>? messages) async {
    // Finds the replied message if exists
    final repliedMessages = messages?.firstWhere((message) => id == message.id);

    // Scrolls to replied message and highlights
    if (repliedMessages != null && messages != null) {
      if (widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
              .enableHighlightRepliedMsg ??
          false) {
        _replyId.value = id;

        if (widget.repliedMessageConfig?.repliedMsgAutoScrollConfig.isJumpTo ??
            true) {
          widget.scrollController
              .jumpTo(index: messages.indexOf(repliedMessages));
        } else {
          widget.scrollController.scrollTo(
              index: messages.indexOf(repliedMessages),
              duration: widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                      .highlightDuration ??
                  const Duration(milliseconds: 300),
              curve: widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                      .highlightScrollCurve ??
                  Curves.linear,
              alignment: widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                      .alignment ??
                  0);
        }

        Future.delayed(
          widget.repliedMessageConfig?.repliedMsgAutoScrollConfig
                  .highlightDuration ??
              const Duration(milliseconds: 300),
          () {
            _replyId.value = null;
          },
        );
      }
    }
  }

  /// When user swipe at that time only animation is assigned with value.
  void _onHorizontalDrag(DragUpdateDetails details) {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.2, 0.0),
    ).animate(
      CurvedAnimation(
        curve: chatBackgroundConfig.messageTimeAnimationCurve,
        parent: _animationController!,
      ),
    );

    details.delta.dx > 1
        ? _animationController?.reverse()
        : _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _replyId.dispose();
    super.dispose();
  }

  Widget get _chatStreamBuilder {
    return StreamBuilder<List<Message>>(
      stream: chatController?.messageStreamController.stream,
      builder: (context, snapshot) {
        return snapshot.connectionState.isActive
            ? ScrollablePositionedList.builder(
                itemScrollController: widget.scrollController,
                itemCount: ChatViewInheritedWidget.of(context)!
                    .chatController
                    .initialMessageList
                    .length,
                reverse: true,
                itemBuilder: (context, index) {
                  final Message message = ChatViewInheritedWidget.of(context)!
                      .chatController
                      .initialMessageList[index];

                  return Column(
                    children: [
                      if (snapshot.data != null &&
                          snapshot.data!.isNotEmpty &&
                          index != snapshot.data!.length - 1 &&
                          !sameDay(
                              message.createdAt.millisecondsSinceEpoch,
                              snapshot.data![index + 1].createdAt
                                  .millisecondsSinceEpoch)) ...[
                        _GroupSeparatorBuilder(
                            separator: message.createdAt.toIso8601String())
                      ],
                      if (snapshot.data != null &&
                          snapshot.data!.isNotEmpty &&
                          index == snapshot.data!.length - 1) ...[
                        _GroupSeparatorBuilder(
                            separator: message.createdAt.toIso8601String())
                      ],
                      ValueListenableBuilder<String?>(
                        valueListenable: _replyId,
                        builder: (context, state, child) {
                          return ChatBubbleWidget(
                            key: GlobalKey(),

                            messageTimeTextStyle:
                                chatBackgroundConfig.messageTimeTextStyle,
                            messageTimeIconColor:
                                chatBackgroundConfig.messageTimeIconColor,
                            message: message,
                            messageConfig: widget.messageConfig,
                            chatBubbleConfig: chatBubbleConfig,
                            profileCircleConfig: profileCircleConfig,
                            swipeToReplyConfig: widget.swipeToReplyConfig,
                            repliedMessageConfig: widget.repliedMessageConfig,
                            slideAnimation: _slideAnimation,
                            onLongPress: (yCoordinate, xCoordinate) =>
                                widget.onChatBubbleLongPress(
                              yCoordinate,
                              xCoordinate,
                              message,
                            ),
                            onSwipe: widget.assignReplyMessage,
                            shouldHighlight: state == message.id,
                            onReplyTap: widget
                                        .repliedMessageConfig
                                        ?.repliedMsgAutoScrollConfig
                                        .enableScrollToRepliedMsg ??
                                    false
                                ? (replyId) =>
                                    _onReplyTap(replyId, snapshot.data)
                                : null,
                          );
                        },
                      ),
                    ],
                  );
                },
              )
            : Center(
                child: chatBackgroundConfig.loadingWidget ??
                    const CircularProgressIndicator(),
              );
      },
    );
  }
}

class _GroupSeparatorBuilder extends StatelessWidget {
  const _GroupSeparatorBuilder({
    Key? key,
    required this.separator,
    this.groupSeparatorBuilder,
    this.defaultGroupSeparatorConfig,
  }) : super(key: key);
  final String separator;
  final StringWithReturnWidget? groupSeparatorBuilder;
  final DefaultGroupSeparatorConfiguration? defaultGroupSeparatorConfig;

  @override
  Widget build(BuildContext context) {
    return groupSeparatorBuilder != null
        ? groupSeparatorBuilder!(separator)
        : ChatGroupHeader(
            day: DateTime.parse(separator),
            groupSeparatorConfig: defaultGroupSeparatorConfig,
          );
  }
}
