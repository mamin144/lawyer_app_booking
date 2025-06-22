import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'كيف يمكنني حجز استشارة قانونية؟',
      answer:
          'يمكنك اختيار المحامي المناسب من قائمة المحامين، ثم تحديد تاريخ و موعد الاستشارة، وبعدها تأكيد الحجز والدفع .',
    ),
    FAQItem(
      question: 'ما أنواع الاستشارات القانونية المتوفرة؟',
      answer:
          'يمكنك الحصول على استشارات في مجالات مثل: القضايا الجنائية، الأحوال الشخصية، القضايا التجارية، العقارات، العمل والعمال، وغيرها.',
    ),
    FAQItem(
      question: 'كيف يتم الدفع مقابل الاستشارة؟',
      answer: 'يتم الدفع عن طريق وسائل الدفع المتوفرة في التطبيق مثل: stripe',
    ),
    FAQItem(
      question: 'هل يمكنني تقييم المحامي بعد انتهاء الاستشارة؟',
      answer:
          'نعم، نحرص على جودة الخدمة، لذلك يمكنك تقييم المحامي وكتابة تعليق بعد انتهاء الجلسة.',
    ),
    FAQItem(
      question: 'هل المحامون موثوقون ومسجلون رسميًا؟',
      answer:
          'نعم، جميع المحامين في التطبيق يتم التحقق من بياناتهم المهنية ورخصهم القانونية قبل الموافقة على حساباتهم.',
    ),
    FAQItem(
      question: 'هل الاستشارات سرية؟',
      answer:
          'بالتأكيد، جميع الاستشارات تتم بسرية تامة، ويتم حماية خصوصية المستخدمين عبر تشفير المحادثات والبيانات.',
    ),
    FAQItem(
      question: 'هل يمكنني استخدام التطبيق من خارج بلدي؟',
      answer:
          'نعم، التطبيق يدعم الاستشارات عن بُعد عبر الإنترنت ويمكنك استخدامه من أي مكان.',
    ),
    FAQItem(
      question: 'كيف أستخدم الشات بوت؟',
      answer:
          'ببساطة، افتح صفحة الشات بوت من القائمة أو من الواجهة الرئيسية، ثم ابدأ بكتابة سؤالك أو اختيار أحد المواضيع المقترحة',
    ),
    FAQItem(
      question: 'ما فائدة الشات بوت في التطبيق؟',
      answer:
          'الشات بوت هو مساعد ذكي داخل التطبيق يساعدك في:\n• معرفة نوع الاستشارة التي تحتاجها.\n• توجيهك إلى المحامي المناسب بناءً على مشكلتك.\n• الإجابة عن الأسئلة العامة حول استخدام التطبيق.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1F41BB),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'الأسئلة الشائعة',
            style: TextStyle(
              color: Color(0xFF1F41BB),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1F41BB),
                      const Color(0xFF1F41BB).withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F41BB).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الأسئلة الشائعة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'إجابات على أكثر الأسئلة شيوعاً',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // FAQ List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _faqItems.length,
                  itemBuilder: (context, index) {
                    return FAQCard(faqItem: _faqItems[index]);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}

class FAQCard extends StatefulWidget {
  final FAQItem faqItem;

  const FAQCard({
    super.key,
    required this.faqItem,
  });

  @override
  State<FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.faqItem.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF1F41BB),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.faqItem.answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
