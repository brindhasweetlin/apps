import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  Future<List<TeamModel?>> _fetchTeams(BuildContext context) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final teams = <TeamModel?>[];
    
    for (final teamId in event.teamIds.take(2)) {
      try {
        final team = await firestoreService.getTeam(teamId);
        teams.add(team);
      } catch (e) {
        teams.add(null);
      }
    }
    
    return teams;
  }

  @override
  Widget build(BuildContext context) {
    final isLive = event.status == EventStatus.ongoing;
    final teams = event.teamIds.take(2).toList();

    return FutureBuilder<List<TeamModel?>>(
      future: _fetchTeams(context),
      builder: (context, snapshot) {
        final teamData = snapshot.data ?? [];
        final team1 = teamData.isNotEmpty ? teamData[0] : null;
        final team2 = teamData.length > 1 ? teamData[1] : null;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // League and Time
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.sport.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: AppTheme.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          DateFormat('MMM d, h:mm a').format(event.startTime),
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                // Teams
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTeamRow(
                        teamName: team1?.name ??
                            (teams.isNotEmpty ? teams[0] : 'Team 1'),
                        teamLogo: team1?.logoUrl,
                        odds: event.odds[teams.isNotEmpty ? teams[0] : ''] ??
                            1.5,
                        isSelected: false,
                        onTap: onTap,
                        isLoading: snapshot.connectionState ==
                            ConnectionState.waiting,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Colors.white10),
                      const SizedBox(height: 12),
                      _buildTeamRow(
                        teamName: team2?.name ??
                            (teams.length > 1 ? teams[1] : 'Team 2'),
                        teamLogo: team2?.logoUrl,
                        odds: event.odds[teams.length > 1 ? teams[1] : ''] ??
                            2.1,
                        isSelected: false,
                        onTap: onTap,
                        isLoading: snapshot.connectionState ==
                            ConnectionState.waiting,
                      ),
                    ],
                  ),
                ),

                // Bet Now Button
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentColor, Color(0xFF0095E0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'BET NOW',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTeamInitial(String teamName, bool isSelected) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : 'T',
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.accentColor : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow({
    required String teamName,
    String? teamLogo,
    required double odds,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor.withOpacity(0.1) : Colors
              .transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
              color: AppTheme.accentColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Team logo/initial
            teamLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      teamLogo,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildTeamInitial(teamName, isSelected),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildTeamInitial(teamName, isSelected);
                      },
                    ),
                  )
                : _buildTeamInitial(teamName, isSelected),
            const SizedBox(width: 12),
            // Team name
            Expanded(
              child: Text(
                teamName,
                style: GoogleFonts.inter(
                  color: isSelected ? AppTheme.accentColor : Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Odds
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                odds.toStringAsFixed(2),
                style: GoogleFonts.inter(
                  color: isSelected ? AppTheme.primaryColor : AppTheme
                      .accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStat(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        ),
      ],
    );
  }
}
