import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../constants/app_constants.dart';

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final bool isFollowing;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onTap;

  const TeamCard({
    Key? key,
    required this.team,
    this.isFollowing = false,
    this.onFollowPressed,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Team Logo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                image: team.logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(team.logoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: team.logoUrl == null
                  ? Center(
                      child: Text(
                        team.name[0].toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            // Team Name
            Text(
              team.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Sport
            Text(
              team.sport,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  context,
                  value: '${(team.winRate * 100).toInt()}%',
                  label: 'Win Rate',
                ),
                _buildStat(
                  context,
                  value: '\$${team.totalEarnings.toStringAsFixed(1)}K',
                  label: 'Earnings',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Follow Button
            if (onFollowPressed != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFollowPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: isFollowing
                        ? theme.colorScheme.surfaceVariant
                        : theme.colorScheme.primary,
                    foregroundColor: isFollowing
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
