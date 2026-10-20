import 'dart:async';

import 'package:flutter/material.dart';

class IntroFlowScreen extends StatefulWidget {
  const IntroFlowScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<IntroFlowScreen> createState() => _IntroFlowScreenState();
}

class _IntroFlowScreenState extends State<IntroFlowScreen> {
  static const _primary = Color(0xFF0D8279);
  static const _background = Color(0xFFF4F8F7);

  final PageController _pageController = PageController();
  Timer? _splashTimer;
  bool _showOnboarding = false;
  int _page = 0;

  static const _pages = [
    _OnboardingPageData(
      title: 'Cadastre seus Pacientes',
      description:
          'Gerencie facilmente o histórico de cada paciente: idade, sexo, comorbidades e biometria para organizar as avaliações no consultório.',
    ),
    _OnboardingPageData(
      title: 'Predição de Risco Cardíaco',
      description:
          'Utilize algoritmos baseados em IA para analisar dados clínicos de forma preditiva, identificando ameaças graves de forma rápida e segura.',
    ),
    _OnboardingPageData(
      title: 'Agende Consultas',
      description:
          'Mantenha sua agenda organizada e seja lembrado das reavaliações médicas ideais para otimizar os tratamentos preventivos.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _showOnboarding = true);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page == _pages.length - 1) {
      widget.onCompleted();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _showOnboarding
              ? _buildOnboarding()
              : const _SplashScreen(key: ValueKey('splash')),
        ),
      ),
    );
  }

  Widget _buildOnboarding() {
    return LayoutBuilder(
      key: const ValueKey('onboarding'),
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) =>
                      _IllustrationPanel(index: index),
                ),
              ),
              SizedBox(height: constraints.maxHeight < 650 ? 18 : 30),
              Text(
                _pages[_page].title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF173A3A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  _pages[_page].description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF718383),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _page ? 14 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? _primary
                          : const Color(0xFFC3D4D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    _page == _pages.length - 1 ? 'Começar' : 'Próximo',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 7),
        const Text(
          'HeartHealth',
          style: TextStyle(
            color: Color(0xFF173A3A),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _skip,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF56706F),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(44, 36),
          ),
          child: const Text('Pular', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D8279).withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              color: Color(0xFF0D8279),
              size: 43,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'HeartHealth',
            style: TextStyle(
              color: Color(0xFF173A3A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Avaliação de risco cardíaco',
            style: TextStyle(color: Color(0xFF718383), fontSize: 12),
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF0D8279),
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'Plataforma homologada para cardiologistas',
                style: TextStyle(color: Color(0xFF718383), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  const _IllustrationPanel({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF1EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: switch (index) {
          0 => const _PatientIllustration(),
          1 => const _RiskIllustration(),
          _ => const _CalendarIllustration(),
        },
      ),
    );
  }
}

class _PatientIllustration extends StatelessWidget {
  const _PatientIllustration();

  @override
  Widget build(BuildContext context) {
    return _IllustrationCard(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _Avatar(initials: 'AC'),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ana Cavalcanti', style: _cardTitle),
                    Text('Feminino, 58 anos', style: _cardMuted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Row(
            children: [
              Expanded(
                child: _Metric(label: 'PRESSÃO', value: '138/88 mmHg'),
              ),
              Expanded(
                child: _Metric(
                  label: 'COLESTEROL',
                  value: '240 mg/dL',
                  warning: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1D5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'Histórico Familiar Ativo',
              style: TextStyle(
                color: Color(0xFFB57A1B),
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskIllustration extends StatelessWidget {
  const _RiskIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 190,
          height: 52,
          child: CustomPaint(painter: _PulsePainter()),
        ),
        const SizedBox(height: 7),
        _IllustrationCard(
          width: 245,
          child: Row(
            children: [
              Container(
                width: 29,
                height: 29,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE2E1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF04444),
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RISCO CALCULADO',
                      style: TextStyle(color: Color(0xFF718383), fontSize: 8),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Alto Risco (78%)',
                      style: TextStyle(
                        color: Color(0xFFD54444),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Predição baseada em 12 fatores',
                      style: TextStyle(color: Color(0xFF718383), fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarIllustration extends StatelessWidget {
  const _CalendarIllustration();

  @override
  Widget build(BuildContext context) {
    return _IllustrationCard(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Expanded(child: Text('Novembro, 2024', style: _cardTitle)),
              Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF56706F),
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarDay(weekday: 'Ter', day: '12'),
              _CalendarDay(weekday: 'Ter', day: '13', selected: true),
              _CalendarDay(weekday: 'Ter', day: '14'),
              _CalendarDay(weekday: 'Ter', day: '15'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(height: 1, color: Color(0xFFE1EBE9)),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F2F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_available, color: Color(0xFF0D8279), size: 13),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consulta: Dr. João',
                        style: TextStyle(
                          color: Color(0xFF173A3A),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Paciente: Ana Cavalcanti — 14:30',
                        style: TextStyle(color: Color(0xFF718383), fontSize: 7),
                      ),
                    ],
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

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173A3A).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF0D8279),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF718383), fontSize: 7),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: warning ? const Color(0xFFD54444) : const Color(0xFF173A3A),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.weekday,
    required this.day,
    this.selected = false,
  });

  final String weekday;
  final String day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0D8279) : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            weekday,
            style: TextStyle(
              color: selected ? Colors.white70 : const Color(0xFF718383),
              fontSize: 7,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF173A3A),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.62)
      ..lineTo(size.width * 0.18, size.height * 0.62)
      ..lineTo(size.width * 0.29, size.height * 0.42)
      ..lineTo(size.width * 0.53, size.height * 0.91)
      ..lineTo(size.width * 0.70, size.height * 0.62)
      ..lineTo(size.width, size.height * 0.62);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0D8279)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) => false;
}

class _OnboardingPageData {
  const _OnboardingPageData({required this.title, required this.description});

  final String title;
  final String description;
}

const _cardTitle = TextStyle(
  color: Color(0xFF173A3A),
  fontSize: 10,
  fontWeight: FontWeight.w700,
);

const _cardMuted = TextStyle(color: Color(0xFF718383), fontSize: 8);
