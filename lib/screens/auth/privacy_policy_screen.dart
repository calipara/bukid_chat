import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patakaran sa Privacy'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pangako namin sa Iyong Privacy',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pinapahalagahan ng Bukid Chat ang iyong privacy. '
                'Kinokolekta lang namin ang ilang personal na impormasyon na kailangan. '
                'Ligtas naming iniingatan ang iyong impormasyon at hindi ito ipapasa sa iba nang walang pahintulot mo. '
                'Kung nais mong burahin ang iyong account, maaari mo kaming kontakin.',
              ),
              const SizedBox(height: 24),
              const Text(
                'Ano ang mga Kinokolekta Naming Impormasyon:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Pangalan\n- Mobile Number\n- Address\n- Larawan\n- Kasarian\n- Araw ng Kapanganakan\n- Impormasyon tungkol sa iyong Bukid (optional)',
              ),
              const SizedBox(height: 24),
              const Text(
                'Paano Ginagamit ang Iyong Impormasyon:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Para maging personalized ang iyong karanasan sa pagsasaka\n'
                '- Para mapaganda pa ang aming serbisyo\n'
                '- Para makapagpadala ng mahahalagang update at impormasyon',
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Huling update: Abril 2025',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
