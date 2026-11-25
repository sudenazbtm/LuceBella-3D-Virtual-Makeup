import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIBot extends StatefulWidget {
  const AIBot({super.key});

  @override
  State<AIBot> createState() => _AIBotState();
}

class _AIBotState extends State<AIBot> {
  static bool _isInitialized = false;
  bool _isLoading = false;
  
  static late final GenerativeModel _model;
  static late final ChatSession _chatSession;

  static final List<Map<String, dynamic>> _messages = [
    {
      'type': 'bot',
      'text': 'Merhaba! Ben LuceBella AI asistanınız. Güzellik, makyaj ve cilt bakımı hakkında size nasıl yardımcı olabilirim?'
    }
  ];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickQuestions = [
    'Cilt tipimi nasıl belirlerim?',
    'Hangi renk bana yakışır?',
    'Makyaj önerileri',
    'Yüz şeklime göre kontür nasıl yapılır?'
  ];

  @override
  void initState() {
    super.initState();
    if (!_isInitialized) {
      _model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: 'YOUR_GEMINI_API_KEY',
        systemInstruction: Content.system(
            "Senin adın LuceBella AI. Sen uzman bir dijital makyöz, güzellik danışmanı ve asistanısın. Görevin, kullanıcılara cilt bakımı, makyaj teknikleri ve kişiselleştirilmiş güzellik sırları hakkında samimi, sıcak ve profesyonel bir dille tavsiyelerde bulunmak. Uzun paragraflardan kaçın, kısa ve net cevaplar ver. Kullanıcıları LuceBella'nın Sanal Makyaj, Yüz Analizi ve Ürün Kataloğu gibi özelliklerini kullanmaya teşvik et. Asla tıbbi tavsiye verme, sadece kozmetik ve estetik odaklı konuş."),
      );
      _chatSession = _model.startChat();
      _isInitialized = true;
    }
  }

  Future<void> _sendMessageToAI(String messageText) async {
    if (messageText.trim().isEmpty) return;

    setState(() {
      _messages.add({'type': 'user', 'text': messageText.trim()});
      _isLoading = true;
    });
    
    _inputController.clear();
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(messageText.trim()));
      if (response.text != null) {
        setState(() {
          _messages.add({'type': 'bot', 'text': response.text!});
        });
      }
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      setState(() {
        _messages.add({
          'type': 'bot', 
          'text': 'Üzgünüm, şu an bağlantımda bir sorun oluştu. Hata detay: ${e.toString().replaceAll('Exception: ', '')}'
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _handleSend() {
    _sendMessageToAI(_inputController.text);
  }

  void _handleQuickQuestion(String question) {
    _sendMessageToAI(question);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 16 : 100,
        right: 24,
      ),
      child: Container(
        width: 320,
        height: 384, 
        decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                children: [
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LuceBella AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  Expanded(
                    child: Container(
                      color: Colors.grey[50],
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_messages.length == 1 ? 1 : 0),
                        itemBuilder: (context, index) {
                          
                          if (index == _messages.length && _messages.length == 1) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  'Hızlı Sorular:',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._quickQuestions.map((q) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: GestureDetector(
                                    onTap: () => _handleQuickQuestion(q),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Text(
                                        q,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            );
                          }

                          if (index >= _messages.length + (_isLoading ? 1 : 0)) return const SizedBox.shrink();

                          if (index == _messages.length && _isLoading) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: const SizedBox(
                                      width: 24,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final message = _messages[index];
                          final isUser = message['type'] == 'user';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isUser ? Colors.black : Colors.grey[100],
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                                        bottomRight: Radius.circular(isUser ? 4 : 16),
                                      ),
                                    ),
                                    child: isUser
                                      ? Text(
                                          message['text'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        )
                                      : MarkdownBody(
                                          data: message['text'],
                                          styleSheet: MarkdownStyleSheet(
                                            p: TextStyle(color: Colors.grey[800], fontSize: 12, height: 1.4),
                                            listBullet: TextStyle(color: Colors.grey[800], fontSize: 12),
                                            strong: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 12),
                                            em: TextStyle(color: Colors.grey[800], fontStyle: FontStyle.italic, fontSize: 12),
                                          ),
                                        ),
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                      border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            onSubmitted: (_) => _handleSend(),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Mesajınızı yazın...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _handleSend,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}


class AIBotAction extends StatelessWidget {
  final VoidCallback? onPressed;

  const AIBotAction({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {
        showGeneralDialog(
          context: context,
          barrierColor: Colors.transparent, 
          barrierDismissible: true,
          barrierLabel: 'AIBot',
          pageBuilder: (context, _, __) {
            return const Align(
              alignment: Alignment.bottomRight,
              child: Material(
                color: Colors.transparent,
                child: AIBot(),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.black),
            ),
            SizedBox(width: 10),
            Text(
              'AI Asistan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}