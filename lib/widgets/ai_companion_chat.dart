import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../providers/app_riverpod.dart';

class AICompanionChat extends ConsumerStatefulWidget {
  const AICompanionChat({super.key});

  @override
  ConsumerState<AICompanionChat> createState() => _AICompanionChatState();
}

class _AICompanionChatState extends ConsumerState<AICompanionChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(appRiverpod);
    _scrollToBottom();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Disclaimer
          _buildDisclaimer(),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: provider.companionChatHistory.length,
              itemBuilder: (context, index) {
                final msg = provider.companionChatHistory[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // Quick Replies
          _buildQuickReplies(provider),

          // Input Area
          _buildInputArea(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 28, color: Color(0xFF64748B)),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'رفيقي الذكي ✨',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: 'Cairo'),
              ),
              Text(
                'دائماً معك للاستماع',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontFamily: 'Cairo'),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFFE0E7FF),
            child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: const Color(0xFFFEF3C7),
      child: const Text(
        'تنبيه: هذا رفيق ذكاء اصطناعي للدردشة الودية فقط، وليس بديلاً عن الاستشارة الطبية أو التواصل البشري.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: Color(0xFF92400E), fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChatBubble(CompanionMessage msg) {
    final isAI = msg.isFromAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAI) const Spacer(),
          Flexible(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isAI ? Colors.white : const Color(0xFF6366F1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isAI ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isAI ? Radius.zero : const Radius.circular(20),
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: Text(
                msg.text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isAI ? FontWeight.w500 : FontWeight.bold,
                  color: isAI ? const Color(0xFF1E293B) : Colors.white,
                  fontFamily: 'Cairo',
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isAI) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(AppRiverpod provider) {
    final replies = ['أشعر بالوحدة 😔', 'أنا سعيد اليوم! 😊', 'هل يمكنك مساعدتي؟ 🤔', 'أريد الحديث فقط 🗣️'];
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: replies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ActionChip(
              label: Text(replies[index], style: const TextStyle(fontSize: 11, fontFamily: 'Cairo')),
              onPressed: () => provider.sendCompanionMessage(replies[index]),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(AppRiverpod provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                provider.sendCompanionMessage(_messageController.text);
                _messageController.clear();
              }
            },
            icon: const Icon(Icons.send_rounded, color: Color(0xFF6366F1), size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontFamily: 'Cairo'),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
