import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'submit_inquiry_screen.dart';
import '../../core/translations.dart';

class InquiryHomeScreen extends StatefulWidget {
  const InquiryHomeScreen({super.key});

  @override
  State<InquiryHomeScreen> createState() => _InquiryHomeScreenState();
}

class _InquiryHomeScreenState extends State<InquiryHomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();

  final List<InquiryMessage> _messages = [
    InquiryMessage(
      id: 'welcome',
      text: 'Hello! I am GovBot. Ask me about how to apply, who qualifies, or the requirements for our assistance programs.'.tr(),
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _listen() async {
    if (!_isListening) {
      try {
        bool available = await _speechToText.initialize(
          onError: (val) => debugPrint('STT Error: $val'),
          onStatus: (val) => debugPrint('STT Status: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speechToText.listen(
            onResult: (val) => setState(() {
              _messageController.text = val.recognizedWords;
            }),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not initialize microphone. Please check app permissions.'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('STT Init Exception: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition not available on this device: '.tr() + e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }



  void _sendMessage([String? predefinedMessage]) {
    final userMessage = predefinedMessage ?? _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add(
        InquiryMessage(
          id: DateTime.now().toString(),
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    if (predefinedMessage == null) {
      _messageController.clear();
    }

    final botResponse = _generateBotResponse(userMessage);

    // Simulate quick bot response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add(
            InquiryMessage(
              id: DateTime.now().toString(),
              text: botResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _flutterTts.speak(botResponse);
      }
    });
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
      _messages.add(
        InquiryMessage(
          id: 'welcome',
          text: 'Conversation cleared. '.tr() + 'Hello! I am GovBot. Ask me about how to apply, who qualifies, or the requirements for our assistance programs.'.tr(),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  String _generateBotResponse(String input) {


    final text = input.toLowerCase();

    if (text.contains('how') || text.contains('apply') || text.contains('process') ||
        text.contains('paano') || text.contains('pano') || text.contains('mag-apply') || text.contains('proseso') || // Tagalog
        text.contains('unsaon') || text.contains('pag-apply') || text.contains('pamaagi') || // Bisaya
        text.contains('panon') || text.contains('anda') || // Muslim/Maranao
        text.contains('m\'pano') || text.contains('ma-apa') // Subanen
        ) {
      return 'To apply for any program, go to the Home screen, select a specific assistance service, review the requirements, and tap "Start Eligibility Assessment" to begin.';
    }
    
    if (text.contains('who') || text.contains('qualify') || text.contains('eligible') || text.contains('eligibility') ||
        text.contains('sino') || text.contains('pwede') || text.contains('kwalipikado') || // Tagalog
        text.contains('kinsa') || text.contains('puyde') || // Bisaya
        text.contains('sinta') || text.contains('s\'nu') // Subanen
        ) {
      return 'Eligibility depends on the specific program. Generally, you must be a resident of the municipality. Please check the specific program\'s page for detailed applicant qualifications.';
    }
    
    if (text.contains('education') || text.contains('scholar') || text.contains('school') ||
        text.contains('edukasyon') || text.contains('eskwela') || text.contains('pag-aaral') || text.contains('skul') || // Tagalog
        text.contains('eskwelahan') || text.contains('skwelahan') || text.contains('pagtuon') || // Bisaya
        text.contains('madrasah') || text.contains('guro') // Muslim/Subanen
        ) {
      return 'Educational Assistance provides financial support for college students. You will need your Certificate of Enrollment, Statement of Account, and a valid School ID.';
    }
    
    if (text.contains('medical') || text.contains('health') || text.contains('hospital') || text.contains('medicine') ||
        text.contains('medikal') || text.contains('kalusugan') || text.contains('ospital') || text.contains('gamot') || // Tagalog
        text.contains('tambal') || text.contains('tambalanan') || text.contains('hospitel') || // Bisaya
        text.contains('bulong') || text.contains('paggamot') // Subanen/Muslim
        ) {
      return 'Medical Assistance helps cover hospital bills and medicines. Requirements typically include a Medical Certificate, Statement of Account, and a valid ID.';
    }
    
    if (text.contains('burial') || text.contains('funeral') || text.contains('death') ||
        text.contains('libing') || text.contains('patay') || text.contains('burol') || text.contains('namatay') || // Tagalog
        text.contains('lubong') || text.contains('haya') || // Bisaya
        text.contains('paglubong') || text.contains('minatay') || text.contains('janaza') // Subanen/Muslim (Janaza = Islamic funeral)
        ) {
      return 'Burial Assistance provides support for the families of deceased residents. Please prepare the Death Certificate and Funeral Service receipt.';
    }
    
    if (text.contains('employ') || text.contains('job') || text.contains('work') ||
        text.contains('trabaho') || text.contains('empleyo') || text.contains('hanapbuhay') || // Tagalog
        text.contains('panginabuhi') // Bisaya
        ) {
      return 'Employment Assistance helps job seekers through referrals and endorsements. You will need your Personal Data Sheet (PDS) and Resume.';
    }
    
    if (text.contains('transport') || text.contains('travel') ||
        text.contains('byahe') || text.contains('pamasahe') || text.contains('transportasyon') || text.contains('uwi') || // Tagalog
        text.contains('pasahe') || text.contains('pauli') || // Bisaya
        text.contains('muli') || text.contains('p\'muli') // Subanen
        ) {
      return 'Transportation Assistance supports essential travel. You need a Valid ID and a proof or letter explaining the purpose of your request.';
    }
    
    if (text.contains('require') || text.contains('document') ||
        text.contains('kailangan') || text.contains('dokumento') || text.contains('papeles') || text.contains('rekisitos') || // Tagalog
        text.contains('kinahanglan') // Bisaya
        ) {
      return 'Requirements vary by program. Please navigate to the specific program on the Home screen to view its complete list of required documents.';
    }
    
    if (text.contains('hi') || text.contains('hello') || text.contains('hey') ||
        text.contains('kamusta') || text.contains('musta') || text.contains('uy') || // Tagalog
        text.contains('kumusta') || text.contains('agi lang') || // Bisaya
        text.contains('assalamualaikum') || text.contains('salam') || // Muslim
        text.contains('g\'m\'sta') // Subanen
        ) {
      return 'Hello! Ask me about our assistance programs (Educational, Medical, Burial, Employment, Transportation) or how to apply.';
    }

    return 'I am an automated assistant. For specific inquiries not covered here, please visit the municipal office for further assistance.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GovBot Assistant'.tr()),
        automaticallyImplyLeading: false,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Conversation'.tr(),
            onPressed: _clearConversation,
          ),
          IconButton(
            icon: const Icon(Icons.edit_document),
            tooltip: 'Manual Inquiry'.tr(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubmitInquiryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.isUser;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : const Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser || Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser || Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _isListening ? Colors.red.shade100 : Colors.grey.shade200,
                  child: IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Theme.of(context).primaryColor, size: 20),
                    onPressed: _listen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
