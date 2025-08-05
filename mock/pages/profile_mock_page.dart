import 'package:flutter/material.dart';

import '../data/mock_user.dart';
import 'package:hoot/models/user.dart';

class ProfileMockPage extends StatelessWidget {
  const ProfileMockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, mockUser),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, U user) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (user.bannerPictureUrl != null &&
              user.bannerPictureUrl!.isNotEmpty)
            Image.network(
              user.bannerPictureUrl!,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: double.infinity,
              height: 500,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32).copyWith(
                top: 150,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withAlpha(0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name ?? '',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 64,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@${user.username ?? ''}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      if (user.verified ?? false)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Image.asset(
                            'assets/images/verified.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.bio!,
                        textAlign: TextAlign.center,
                      ),
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
