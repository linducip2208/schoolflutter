import 'dart:convert';
import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/api/upload_repository.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/websocket/pusher_service.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/chat_repository.dart';

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({super.key, required this.conversationId});
  final int conversationId;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final ChatRepository _repo = ChatRepository();
  final UploadRepository _uploads = UploadRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late Future<List<Map<String, dynamic>>> _future;
  final List<Map<String, dynamic>> _live = <Map<String, dynamic>>[];
  bool _sending = false;
  double? _uploadProgress;

  String get _channel => 'private-conversation.${widget.conversationId}';

  @override
  void initState() {
    super.initState();
    _future = _repo.messages(widget.conversationId);
    _subscribe();
  }

  Future<void> _subscribe() async {
    try {
      await PusherService.instance.subscribe(_channel, _onPusherEvent);
    } catch (_) {}
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.eventName != 'message.new') return;
    try {
      final Map<String, dynamic> data =
          json.decode(event.data) as Map<String, dynamic>;
      // The sender also receives its own broadcast (no socket_id exclusion
      // on mobile); ignore it — the sent echo is already in the list.
      final int? meId = context.read<AuthBloc>().state.user?.id;
      final dynamic senderId = data['sender_id'] ?? (data['sender'] is Map ? (data['sender'] as Map)['id'] : null);
      if (meId != null && senderId is num && senderId.toInt() == meId) return;
      if (mounted) {
        setState(() => _live.add(data));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent + 80,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _send() async {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final Map<String, dynamic> sent =
          await _repo.send(widget.conversationId, text);
      _input.clear();
      if (mounted) setState(() => _live.add(sent));
    } on OfflineQueuedException catch (e) {
      if (!mounted) return;
      _input.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Picks an image, uploads it (with progress), then sends it as a
  /// message attachment. Upload failures surface inline; the message
  /// itself still goes through the offline outbox.
  Future<void> _attach() async {
    if (_sending) return;
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final CancelToken cancel = CancelToken();
    setState(() {
      _sending = true;
      _uploadProgress = 0;
    });
    try {
      final Map<String, dynamic> up = await _uploads.upload(
        file: File(picked.path),
        purpose: 'chat',
        cancelToken: cancel,
        onProgress: (int sent, int total) {
          if (mounted && total > 0) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );
      final Map<String, dynamic> sent = await _repo.send(
        widget.conversationId,
        _input.text.trim().isEmpty ? 'Foto' : _input.text.trim(),
        file: up['path'] as String?,
      );
      _input.clear();
      if (mounted) setState(() => _live.add(sent));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload gagal: ${e.message}')));
    } on OfflineQueuedException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _uploadProgress = null;
        });
      }
    }
  }

  @override
  void dispose() {
    PusherService.instance.unsubscribe(_channel);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int? meId = context.watch<AuthBloc>().state.user?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (BuildContext c,
                  AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const AppLoading();
                }
                if (snap.hasError) {
                  return AppError(
                      message: '${snap.error}',
                      onRetry: () => setState(
                          () => _future = _repo.messages(widget.conversationId)));
                }
                final List<Map<String, dynamic>> all =
                    <Map<String, dynamic>>[...?snap.data, ..._live];
                if (all.isEmpty) {
                  return const AppEmpty(title: 'Belum ada pesan');
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: all.length,
                  itemBuilder: (BuildContext c, int i) {
                    final Map<String, dynamic> m = all[i];
                    // Backend sends `sender_id` (+ nested `sender`); the old
                    // `user_id` key never existed in API responses.
                    final dynamic rawSender = m['sender_id'] ??
                        (m['sender'] is Map
                            ? (m['sender'] as Map)['id']
                            : m['user_id']);
                    final bool mine =
                        (rawSender as num?)?.toInt() == meId;
                    final Color bg = mine
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: mine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(m['body'] as String? ?? '',
                                      style: TextStyle(
                                        color:
                                            mine ? Colors.white : null,
                                      )),
                                  if (m['file'] != null &&
                                      (m['file'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _AttachmentThumb(
                                      file: m['file'] as String,
                                      mine: mine,
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  if (m['created_at'] != null)
                                    Text(
                                      DateFormatter.time(DateTime.parse(
                                          m['created_at'] as String)),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: mine
                                            ? Colors.white70
                                            : Theme.of(context).hintColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: _uploadProgress != null
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              value: _uploadProgress,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.attach_file),
                    tooltip: 'Lampirkan foto',
                    onPressed: _sending ? null : _attach,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline thumbnail for image attachments in a bubble.
class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({required this.file, required this.mine});
  final String file;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    if (!UploadRepository.looksLikeImage(file)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.attach_file,
              size: 16, color: mine ? Colors.white70 : null),
          const SizedBox(width: 4),
          Flexible(
            child: Text('Lampiran',
                style: TextStyle(
                    fontSize: 12,
                    color: mine ? Colors.white70 : null)),
          ),
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        UploadRepository.displayUrl(file),
        width: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
            size: 40),
        loadingBuilder: (BuildContext c, Widget child,
            ImageChunkEvent? progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 180,
            height: 120,
            child: Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }
}
