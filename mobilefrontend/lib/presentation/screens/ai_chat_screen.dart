import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/providers/chat_provider.dart';
import '../../data/models/chat_models.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedModel = 'anthropic/claude-3-haiku';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // 1. Neural Grid Background
          Positioned.fill(child: _buildNeuralBackground()),

          SafeArea(
            child: Column(
              children: [
                // 2. Tactical Header
                _buildHeader(),

                // 3. Message Stream
                Expanded(
                  child: chatState.messages.isEmpty 
                    ? _buildWelcomeState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(24),
                        itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == chatState.messages.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildMessageBubble(chatState.messages[index]);
                        },
                      ),
                ),

                // 4. Neural Input Section
                _buildInputSection(chatState.isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuralBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.5,
          colors: [Color(0xFF0F172A), Colors.transparent],
        ),
      ),
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 20, height: 1, color: AppTheme.accentTeal.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  const Text('NEURAL INTERFACE V4.0', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.accentTeal)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('AI ASSISTANT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -1, color: Colors.white)),
            ],
          ),
          _buildModelSelector(),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedModel,
          dropdownColor: const Color(0xFF0F172A),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.accentTeal),
          icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.white24),
          items: const [
            DropdownMenuItem(value: 'anthropic/claude-3-haiku', child: Text('CLAUDE 3 HAIKU')),
            DropdownMenuItem(value: 'mistralai/mistral-7b-instruct:free', child: Text('MISTRAL 7B')),
          ],
          onChanged: (v) => setState(() => _selectedModel = v!),
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accentTeal.withOpacity(0.1)),
              ),
              child: const Icon(Icons.lightbulb_outline, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text('INTELLIGENCE UPLINK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'STANDING BY FOR TECHNICAL INQUIRIES REGARDING STORAGE PRESSURE, SAFETY PROTOCOLS, AND CONSUMPTION ANALYTICS.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isUser ? 'SOURCE NODE' : 'INTELLIGENCE ENGINE',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: isUser ? AppTheme.accentTeal : AppTheme.accentBlue,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.accentTeal.withOpacity(0.05) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isUser ? AppTheme.accentTeal.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
            ),
            child: Text(
              message.content,
              style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: const TextStyle(fontSize: 8, color: Colors.white10),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentTeal),
          ),
          const SizedBox(width: 8),
          const Text('PROCESSING DATA...', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildInputSection(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isLoading,
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'TRANSMIT REQUEST...',
                hintStyle: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.1), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: isLoading ? null : _handleSend,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(chatProvider.notifier).sendMessage(text, _selectedModel);
    _scrollToBottom();
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
