import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _slides = [
    OnboardingData(
      title: 'Gas use estimates',
      headline: 'Know when gas is running low',
      description: 'The app learns how quickly you use gas and estimates how many days are left in your bottle.',
      icon: Icons.auto_awesome,
    ),
    OnboardingData(
      title: 'Help when you need it',
      headline: 'Ask the GasX assistant',
      description: "Ask about your gas level, safety, or meals. The assistant uses your latest readings to help.",
      icon: Icons.chat_bubble_outline,
    ),
    OnboardingData(
      title: 'Gas leak and low gas alerts',
      headline: 'Alerts when there is danger',
      description: "If the sensor detects a gas leak, the valve closes and the app shows an alert.",
      icon: Icons.security_rounded,
    ),
    OnboardingData(
      title: 'Automatic gas shutoff',
      headline: 'Gas valve closes when a leak is detected',
      description: "If a gas leak is detected, the device closes the gas valve to help keep you safe.",
      icon: Icons.power_settings_new_rounded,
    ),
    OnboardingData(
      title: 'Find and order gas',
      headline: 'Find a gas supplier nearby',
      description: "Find nearby suppliers, compare prices, choose a bottle, and get directions to the shop.",
      icon: Icons.map_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildSlide(_slides[index]),
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 60,
            left: 32,
            right: 32,
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index 
                          ? AppTheme.accentTeal 
                          : Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Action Button
                CustomButton(
                  text: _currentPage == _slides.length - 1 ? 'GET STARTED' : 'CONTINUE',
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: 400.ms,
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      context.go('/landing');
                    }
                  },
                ),
              ],
            ),
          ),

          // Skip Button
          if (_currentPage < _slides.length - 1)
            Positioned(
              top: 64,
              right: 24,
              child: TextButton(
                onPressed: () => context.go('/landing'),
                child: Text(
                  'SKIP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingData slide) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with Animation
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentTeal.withOpacity(0.05),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.1)),
            ),
            child: Icon(slide.icon, size: 64, color: AppTheme.accentTeal),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
          
          const SizedBox(height: 64),
          
          Text(
            slide.title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.accentTeal, letterSpacing: 4),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            slide.headline,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
          
          const SizedBox(height: 24),
          
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),
          
          const SizedBox(height: 120), // Spacer for bottom controls
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String headline;
  final String description;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.headline,
    required this.description,
    required this.icon,
  });
}
