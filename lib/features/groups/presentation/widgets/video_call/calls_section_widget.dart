import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../auth/application/auth_service.dart';
import '../../../services/video_call/call_service.dart';
import '../../views/video_call/video_call_screen.dart';

class CallsSectionWidget extends StatefulWidget {
  final int groupId;
  final String groupName;

  const CallsSectionWidget({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<CallsSectionWidget> createState() => _CallsSectionWidgetState();
}

class _CallsSectionWidgetState extends State<CallsSectionWidget> {
  final List<Map<String, dynamic>> _callHistory = [];
  Map<String, dynamic> _callStats = {};
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadCallData();
  }

  Future<void> _loadCallData() async {
    try {
      setState(() => _isLoading = true);

      final token = await AuthService.getAuthToken();
      if (token == null) return;

      await _loadCallHistory(token);
      await _loadCallStats(token);
      await _loadUserStats(token);

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading call data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCallHistory(String token) async {
    try {
      final history = await CallService.getCallHistory(widget.groupId, token);
      setState(() {
        _callHistory.clear();
        if (history is List) {
          for (var item in history) {
            if (item is Map<String, dynamic>) {
              _callHistory.add(item);
            }
          }
        }
      });
    } catch (e) {
      print('Error loading call history: $e');
    }
  }

  Future<void> _loadCallStats(String token) async {
    try {
      final stats = await CallService.getCallStats(widget.groupId, token);
      setState(() {
        if (stats is Map<String, dynamic>) {
          _callStats = stats;
        } else {
          _callStats = {};
        }
      });
    } catch (e) {
      print('Error loading call stats: $e');
      setState(() => _callStats = {});
    }
  }

  Future<void> _loadUserStats(String token) async {
    try {
      final userStats = await CallService.getUserCallStats(token);
      setState(() {
        if (userStats is Map<String, dynamic>) {
          _userStats = userStats;
        } else {
          _userStats = {};
        }
      });
    } catch (e) {
      print('Error loading user stats: $e');
      setState(() => _userStats = {});
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadCallData();
    setState(() => _isRefreshing = false);
  }

  Widget _buildStatsCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Widget _buildStatisticsSection() {
    final totalCalls = _callStats['totalCalls'] as int? ?? 0;
    final totalParticipants = _callStats['totalParticipants'] as int? ?? 0;
    final averageDuration = _callStats['averageDuration'] as int? ?? 0;
    final userTotalCalls = _userStats['totalCalls'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Estadísticas del Grupo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF324779),
            ),
          ),
        ),
        GridView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          children: [
            _buildStatsCard(
              Icons.video_call_rounded,
              'Total de Llamadas',
              '$totalCalls',
              const Color(0xFF9B59B6),
            ),
            _buildStatsCard(
              Icons.people_rounded,
              'Participantes Totales',
              '$totalParticipants',
              const Color(0xFF3498DB),
            ),
            _buildStatsCard(
              Icons.timer_rounded,
              'Duración Promedio',
              _formatDuration(averageDuration),
              const Color(0xFF2ECC71),
            ),
            _buildStatsCard(
              Icons.emoji_people_rounded,
              'Llamadas Unidas',
              '$userTotalCalls',
              const Color(0xFFE74C3C),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    if (_callHistory.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.videocam_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No hay historial de llamadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las llamadas realizadas en este grupo aparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Historial de Llamadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF324779),
            ),
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _callHistory.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final call = _callHistory[index];
            final startedAt = call['startedAt'] != null
                ? DateTime.parse(call['startedAt'].toString())
                : DateTime.now();
            final endedAt = call['endedAt'] != null
                ? DateTime.parse(call['endedAt'].toString())
                : null;
            final duration = endedAt != null
                ? endedAt.difference(startedAt)
                : null;
            final isActive = call['isActive'] == true;
            final participantCount = call['participantCount'] as int? ?? 0;

            return Card(
              elevation: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isActive ? Colors.green : const Color(0xFF9B59B6),
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : const Color(0xFF9B59B6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        color: isActive
                            ? Colors.green
                            : const Color(0xFF9B59B6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isActive ? 'En curso' : 'Finalizada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.green
                                  : const Color(0xFF324779),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy - HH:mm').format(startedAt),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          if (duration != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Duración: ${_formatDuration(duration.inSeconds)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$participantCount',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ACTIVA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B59B6).withOpacity(0.1),
            const Color(0xFF3498DB).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Iniciar Videollamada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conéctate con los miembros del grupo',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                  ),
                ),
              );
            },
            backgroundColor: const Color(0xFF9B59B6),
            child: const Icon(Icons.video_call_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF9B59B6)),
                  SizedBox(height: 16),
                  Text(
                    'Cargando estadísticas...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF9B59B6),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickActions(),
                        _buildStatisticsSection(),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHistorySection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
    );
  }
}
