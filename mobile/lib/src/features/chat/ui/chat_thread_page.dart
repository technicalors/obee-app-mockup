import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/chat/state/chat_thread_provider.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_composer.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/read_only_channel_banner.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_thread_list.dart';

class ChatThreadPage extends ConsumerStatefulWidget {
  const ChatThreadPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  String? _lastScrolledMessageId;

  bool get _canSend => _composerController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController()..addListener(_handleChange);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _composerController
      ..removeListener(_handleChange)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(chatThreadProvider(widget.conversationId));
    final currentThread = threadAsync.asData?.value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                key: const ValueKey('chat_thread_page'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey('chat_thread_back_button'),
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        tooltip: 'Quay lại',
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          threadAsync.asData?.value.title ?? 'Kênh công ty',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (currentThread?.kind == ChatThreadKind.group)
                        IconButton(
                          key: const ValueKey('chat_thread_group_info_button'),
                          onPressed: () => context.push(
                            '/app/chat/group-info/${widget.conversationId}',
                          ),
                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Thông tin nhóm',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Material(
                      color: colorScheme.surface,
                      child: threadAsync.when(
                        data: (thread) {
                          _scheduleScroll(thread);

                          return Column(
                            children: [
                              Expanded(
                                child: ChatThreadList(
                                  key: const ValueKey('chat_thread_list'),
                                  scrollController: _scrollController,
                                  thread: thread,
                                ),
                              ),
                              const Divider(height: 1),
                              if (thread.isReadOnly)
                                const ReadOnlyChannelBanner()
                              else
                                ChatComposer(
                                  controller: _composerController,
                                  enabled: _canSend,
                                  onSend: _canSend ? _sendMessage : null,
                                ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Không thể tải cuộc trò chuyện.\n$error',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleScroll(ChatThread thread) {
    if (thread.messages.isEmpty) {
      return;
    }

    final latestMessageId = thread.messages.last.id;
    if (_lastScrolledMessageId == latestMessageId) {
      return;
    }

    _lastScrolledMessageId = latestMessageId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    await ref
        .read(chatThreadControllerProvider(widget.conversationId))
        .sendMessage(text);
    _composerController.clear();
  }
}
