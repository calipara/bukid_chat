import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../home/home_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 6;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Mabuhay! Welcome sa Bukid Buddy',
      description: 'Ang katulong mo sa pagtatanim ng mais at palay sa Pilipinas, dinisenyo para tulungan kang mapataas ang ani at kita.',
      imagePath: "https://pixabay.com/get/gb1849c6bd6166015877e59105625a3d1d57da7bbb98309b6cc936539550d48407526f489117761de2037082320d91078e610dfd19f6525b18b780978216b25c4_1280.jpg",
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Profile ng Bukid at Mapa',
      description: 'Gumawa ng detalyadong profile ng iyong bukid, i-mapa ang mga hangganan ng bukid, at subaybayan ang lahat ng iyong mga gawain sa pagsasaka.',
      imagePath: "https://pixabay.com/get/gb3dfddf5022d978fe3125e0f9d763f68d07ccb149f216e1d77584bdb6bd8072a81993b35cd852b413d778ad9bec5569f5f923c2b9b92123d8a922d874f255904_1280.png",
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Update ng Panahon',
      description: 'Kunin ang tumpak na pagtaya ng panahon sa iyong lokasyon, na may mga rekomendasyon para sa pagsasaka batay sa paparating na kondisyon.',
      imagePath: "https://pixabay.com/get/g6ce3de367e48c7d9823f45c6d639dc382280cf08c61f39a4c92d5e8295661bb4870e9896c009ebbdbe8dfa36f826fca1270920d126ac5b353cc94faaf8804772_1280.jpg",
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Katulong sa Pagsasaka',
      description: 'Ang aming AI chatbot ay nagbibigay ng payo tungkol sa paghahanda ng lupa, mga technique sa pagtatanim, at makakatulong na matukoy ang mga peste mula sa mga larawan ng iyong pananim.',
      imagePath: "https://pixabay.com/get/g0ec1294dadb763a4459401bbe6ef8d7a147c30a6301d399cd04069dbaa0cd8a0474bb8c973b7fabf774d5a9dfe0054dfcca5547bbb66f1fd13c60c783d56e51c_1280.jpg",
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Presyo sa Merkado',
      description: "Manatiling updated sa kasalukuyang presyo ng mais at palay sa iba't ibang rehiyon, para matulungan kang magbenta sa tamang oras at lugar.",
      imagePath: "https://pixabay.com/get/g7b55b8bbbcaee2772becb2f77098f1c9ae926085c51bcc96e6f1fe77d520319d19f6efd18f94e4ad668f888e8e86de60b7db6c7e1349d8c1cd46511691f441dc_1280.jpg",
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Pamamahala ng Pera',
      description: 'Subaybayan ang iyong gastos at kita, suriin ang pagiging profitable, at gumawa ng magandang desisyon para mapataas ang kita sa pagsasaka.',
      imagePath: "https://pixabay.com/get/g8930d048ac6db3ce21bd33ecedef8fb5a2412da2a0b57c0fc9e7e13215f316c965f059f4c4909f782500236a86ba06af986be9b228a6a555919bb8fddca3bedf_1280.jpg",
      color: AppTheme.primaryColor,
    ),
  ];

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingComplete, true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _numPages,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(context, _pages[index]);
            },
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            item.color.withOpacity(0.8),
            item.color.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.network(
                item.imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 50),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              item.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _numPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 10,
                width: _currentPage == index ? 30 : 10,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _currentPage == _numPages - 1
              ? AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.secondaryColor,
                          Color(0xFFFFD180),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Magsimula Na',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Laktawan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.white70],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}