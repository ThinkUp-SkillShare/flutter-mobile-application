import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/video_call/call_service.dart';
import '../../../../auth/application/auth_service.dart';
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
  bool _isLoadingHistory = true;
  bool _isLoadingStats = true;
  List<dynamic> _callHistory = [];
  Map<String, dynamic>? _callStats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCallData();
  }

  Future<void> _loadCallData() async {
    await Future.wait([
      _loadCallHistory(),
      _loadCallStats(),
    ]);
  }

  Future<void> _loadCallHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) throw Exception('No auth token');

      // TODO: Implementar endpoint de historial en CallService
      // final history = await CallService.getCallHistory(widget.groupId, token);

      setState(() {
        // _callHistory = history;
        _callHistory = []; // Placeholder
        _isLoadingHistory = false;
      });
    } catch (e) {
      print('Error loading call history: $e');
      setState(() {
        _error = 'Failed to load call history';
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadCallStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) throw Exception('No auth token');

      final stats = await CallService.getCallStats(widget.groupId, token);

      setState(() {
        _callStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading call stats: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _startCall() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    );

    // Recargar datos después de la llamada
    if (result != null) {
      _loadCallData();
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0m';

    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header y botón de iniciar llamada
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Video Calls',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                    fontFamily: 'Sarabun',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start a video call with your group members for real-time collaboration',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                    fontFamily: 'Sarabun',
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de inicio de llamada
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startCall,
                    icon: const Icon(Icons.video_call_rounded, size: 24),
                    label: const Text(
                      'Start Video Call',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B59B6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                // Estadísticas de llamadas
                if (_callStats != null && !_isLoadingStats) ...[
                  const SizedBox(height: 20),
                  _buildStatsCard(),
                ],
              ],
            ),
          ),

          // Historial de llamadas
          Expanded(
            child: _buildCallHistorySection(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final summary = _callStats?['summary'];
    if (summary == null) return const SizedBox.shrink();

    final totalCalls = summary['totalCalls'] ?? 0;
    final avgDuration = summary['averageDuration'] ?? 0;
    final maxParticipants = summary['maxParticipants'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF9B59B6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9B59B6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.call_rounded,
            value: totalCalls.toString(),
            label: 'Total Calls',
          ),
          _buildStatItem(
            icon: Icons.access_time_rounded,
            value: _formatDuration(avgDuration),
            label: 'Avg Duration',
          ),
          _buildStatItem(
            icon: Icons.people_rounded,
            value: maxParticipants.toString(),
            label: 'Max Users',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF9B59B6), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
            fontFamily: 'Sarabun',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF777777),
            fontFamily: 'Sarabun',
          ),
        ),
      ],
    );
  }

  Widget _buildCallHistorySection() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCallData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_callHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_call_rounded,
                size: 64,
                color: Color(0xFF9B59B6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No call history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                fontFamily: 'Sarabun',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start your first video call to collaborate with your group',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
                fontFamily: 'Sarabun',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _callHistory.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final call = _callHistory[index];
        return _buildCallHistoryItem(call);
      },
    );
  }

  Widget _buildCallHistoryItem(Map<String, dynamic> call) {
    final startedAt = DateTime.parse(call['startedAt']);
    final duration = call['duration'];
    final participantCount = call['participantCount'] ?? 0;
    final isActive = call['isActive'] ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.1)
              : const Color(0xFF9B59B6).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? Icons.videocam_rounded : Icons.videocam_off_rounded,
          color: isActive ? Colors.green : const Color(0xFF9B59B6),
        ),
      ),
      title: Text(
        DateFormat('MMM dd, yyyy - hh:mm a').format(startedAt),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Sarabun',
        ),
      ),
      subtitle: Text(
        '${_formatDuration(duration)} • $participantCount participant${participantCount != 1 ? 's' : ''}',
        style: const TextStyle(
          color: Color(0xFF777777),
          fontFamily: 'Sarabun',
        ),
      ),
      trailing: isActive
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Active',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : null,
    );
  }
}