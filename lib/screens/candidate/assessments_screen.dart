import 'package:flutter/material.dart';

import '../../components/skill_hub_loading_indicator.dart';
import '../../models/auth_session.dart';
import '../../models/candidate_assessment.dart';
import '../../services/candidate_assessments_service.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _cardBg = Colors.white;

enum _AssessmentFilterTab { all, pending, completed, expired }

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key, required this.token, this.user});

  final String token;
  final CandidateUser? user;

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  late final CandidateAssessmentsService _service = CandidateAssessmentsService(
    token: widget.token,
  );

  List<CandidateAssessmentListItem> _assessments = const [];
  bool _loading = true;
  String? _error;

  _AssessmentFilterTab _activeTab = _AssessmentFilterTab.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAssessments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _fetchAssessments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _service.getMyAssessments(
        candidateId: widget.user?.id,
      );
      if (mounted) {
        setState(() {
          _assessments = list;
        });
      }
    } on CandidateAssessmentsException catch (err) {
      if (mounted) {
        setState(() => _error = err.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Failed to load assigned technical assessments.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<CandidateAssessmentListItem> get _filteredAssessments {
    return _assessments.where((item) {
      final isCompleted = item.checkIsCompleted;
      final isBlocked = item.checkIsBlocked;
      final isExpired = item.checkIsExpired;
      final isPending = item.isActionRequired;

      if (_activeTab == _AssessmentFilterTab.pending && !isPending)
        return false;
      if (_activeTab == _AssessmentFilterTab.completed && !isCompleted)
        return false;
      if (_activeTab == _AssessmentFilterTab.expired &&
          !isExpired &&
          !isBlocked)
        return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchJob = item.jobTitle.toLowerCase().contains(q);
        final matchCompany = item.companyName.toLowerCase().contains(q);
        final matchTrack = item.assessmentTitle.toLowerCase().contains(q);
        if (!matchJob && !matchCompany && !matchTrack) return false;
      }

      return true;
    }).toList();
  }

  int get _pendingCount => _assessments.where((a) => a.isActionRequired).length;
  int get _completedCount =>
      _assessments.where((a) => a.checkIsCompleted).length;
  int get _expiredCount =>
      _assessments.where((a) => a.checkIsExpired || a.checkIsBlocked).length;

  int get _averageScore {
    final graded = _assessments.where((a) => a.isGraded).toList();
    if (graded.isEmpty) return 0;
    final total = graded.fold<double>(0.0, (sum, a) => sum + a.examScore);
    return (total / graded.length).round();
  }

  void _openScorecardModal(CandidateAssessmentListItem assessment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ScorecardBottomSheet(assessment: assessment, service: _service),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Recently';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatDeadline(DateTime? dt) {
    if (dt == null) return 'No deadline';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final displayedList = _filteredAssessments;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _fetchAssessments,
        color: _emerald,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Top Dashboard Header & Performance Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PERFORMANCE OVERVIEW',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: _emeraldDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Assessment Dashboard',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: _emerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Live summary',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _emeraldDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 4 Summary Metrics (2x2 Grid)
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricTile(
                                  label: 'Total',
                                  value: '${_assessments.length}',
                                  subtext: 'Challenges',
                                  icon: Icons.code_rounded,
                                  iconColor: const Color(0xFF2563EB),
                                  iconBg: const Color(0xFFEFF6FF),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMetricTile(
                                  label: 'Action Req.',
                                  value: '$_pendingCount',
                                  subtext: 'Ready to start',
                                  icon: Icons.access_time_rounded,
                                  iconColor: const Color(0xFFD97706),
                                  iconBg: const Color(0xFFFFFBEB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricTile(
                                  label: 'Completed',
                                  value: '$_completedCount',
                                  subtext: 'Submitted',
                                  icon: Icons.check_circle_outline_rounded,
                                  iconColor: const Color(0xFF059669),
                                  iconBg: const Color(0xFFECFDF5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMetricTile(
                                  label: 'Avg. Score',
                                  value: '$_averageScore%',
                                  subtext: 'Graded tests',
                                  icon: Icons.emoji_events_outlined,
                                  iconColor: const Color(0xFF7C3AED),
                                  iconBg: const Color(0xFFF5F3FF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Search Input
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 13, color: _ink),
                        decoration: InputDecoration(
                          hintText: 'Search by job, track, or company...',
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: _muted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: _muted,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                    color: _muted,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Filter Tabs Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All (${_assessments.length})',
                            isSelected: _activeTab == _AssessmentFilterTab.all,
                            onTap: () => setState(
                              () => _activeTab = _AssessmentFilterTab.all,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'Action Required ($_pendingCount)',
                            isSelected:
                                _activeTab == _AssessmentFilterTab.pending,
                            onTap: () => setState(
                              () => _activeTab = _AssessmentFilterTab.pending,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'Completed ($_completedCount)',
                            isSelected:
                                _activeTab == _AssessmentFilterTab.completed,
                            onTap: () => setState(
                              () => _activeTab = _AssessmentFilterTab.completed,
                            ),
                          ),
                          if (_expiredCount > 0) ...[
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              label: 'Expired ($_expiredCount)',
                              isSelected:
                                  _activeTab == _AssessmentFilterTab.expired,
                              onTap: () => setState(
                                () => _activeTab = _AssessmentFilterTab.expired,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Body List / Empty / Loading / Error
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: SkillHubLoadingIndicator(
                    message: 'Loading assigned technical assessments...',
                  ),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFE11D48),
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFBE123C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _fetchAssessments,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (displayedList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 38,
                            color: _emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No Matching Assessments'
                              : _activeTab == _AssessmentFilterTab.pending
                              ? 'No Action Required'
                              : _activeTab == _AssessmentFilterTab.completed
                              ? 'No Completed Assessments Yet'
                              : 'No Technical Assessments Yet',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try adjusting your search criteria to find assigned tests.'
                              : 'When recruiters evaluate your job applications and dispatch coding challenges, they will appear here.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _muted,
                            height: 1.4,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _activeTab != _AssessmentFilterTab.all) ...[
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _activeTab = _AssessmentFilterTab.all;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Reset Filters'),
                            style: TextButton.styleFrom(
                              foregroundColor: _emeraldDark,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = displayedList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildAssessmentCard(item),
                    );
                  }, childCount: displayedList.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _emeraldDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _emeraldDark : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ASSESSMENT CARD (MATCHING WEB SCREENSHOTS)
  // ==========================================
  Widget _buildAssessmentCard(CandidateAssessmentListItem item) {
    final isCompleted = item.checkIsCompleted;
    final isBlocked = item.checkIsBlocked;
    final isExpired = item.checkIsExpired;
    final isUnderReview = item.isUnderReview;
    final isGraded = item.isGraded;
    final isSelected = item.isSelectedForInterview;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF34D399) : _border,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0x1410B981)
                : const Color(0x08000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Company & Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Initials Avatar
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  item.companyInitials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _emeraldDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Company Name & Job Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.companyName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status Pill
              _buildStatusPill(item),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Track Title Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CODING CHALLENGE TRACK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.assessmentTitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. Conditional Status Callout
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: _emeraldDark,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected for Technical Interview!',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _emeraldDark,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'HR evaluated your code and selected you for the interview stage.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (isUnderReview)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code submitted successfully',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Results will be published within 3–4 working days.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (isGraded)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                      children: [
                        const TextSpan(text: 'Technical Score: '),
                        TextSpan(
                          text: '${item.examScore.round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.reviewerFeedback != null &&
                      item.reviewerFeedback!.isNotEmpty)
                    Flexible(
                      child: Text(
                        '"${item.reviewerFeedback}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: _muted,
                        ),
                      ),
                    )
                  else
                    Text(
                      item.isPassed ? 'Passed Benchmark' : 'Below Benchmark',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: item.isPassed
                            ? const Color(0xFF059669)
                            : const Color(0xFFE11D48),
                      ),
                    ),
                ],
              ),
            ),

          // 4. Specs Grid (4 Pills: 2x2)
          Row(
            children: [
              Expanded(
                child: _buildSpecPill(
                  icon: Icons.access_time_rounded,
                  text: '${item.timeLimitMinutes} mins',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecPill(
                  icon: Icons.code_rounded,
                  text:
                      '${item.questionCount} ${item.questionCount == 1 ? 'Problem' : 'Problems'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSpecPill(
                  icon: Icons.shield_outlined,
                  text: 'Pass: ${item.passingThreshold.round()}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecPill(
                  icon: Icons.calendar_today_rounded,
                  text: isExpired
                      ? 'Expired'
                      : 'Deadline: ${_formatDeadline(item.expiresAt)}',
                  isWarning: isExpired,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 5. Card Footer: Date & Actions
          // NOTE: As requested, the "Start Assessment" button is strictly excluded.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected
                        ? 'Interview Selected'
                        : isCompleted
                        ? 'Submitted'
                        : isBlocked
                        ? 'Blocked'
                        : isExpired
                        ? 'Expired'
                        : 'Assigned',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDate(
                      isCompleted || isSelected
                          ? (item.submittedAt ?? item.assignedAt)
                          : item.assignedAt,
                    ),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),

              // Action Buttons / Statuses
              if (isCompleted || isSelected)
                OutlinedButton(
                  onPressed: () => _openScorecardModal(item),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _emeraldDark, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    isUnderReview ? 'Check Status' : 'View Scorecard',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _emeraldDark,
                    ),
                  ),
                )
              else if (isBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 13,
                        color: Color(0xFFB91C1C),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cannot Retake',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Text(
                    'Expired',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                )
              else
                // Action Required without the Start Assessment button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.desktop_windows_outlined,
                        size: 13,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Take on Desktop / Web',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(CandidateAssessmentListItem item) {
    if (item.isSelectedForInterview) {
      return _pillBadge(
        label: item.examScore > 0
            ? 'Interview Selected (${item.examScore.round()}%)'
            : 'Interview Selected',
        icon: Icons.emoji_events_rounded,
        bg: const Color(0xFFECFDF5),
        border: const Color(0xFFA7F3D0),
        color: _emeraldDark,
        isBold: true,
      );
    }
    if (item.checkIsBlocked) {
      return _pillBadge(
        label: 'Cannot Retake',
        icon: Icons.close_rounded,
        bg: const Color(0xFFFEF2F2),
        border: const Color(0xFFFECACA),
        color: const Color(0xFFB91C1C),
      );
    }
    if (item.checkIsExpired) {
      return _pillBadge(
        label: 'Expired',
        icon: Icons.close_rounded,
        bg: const Color(0xFFFEF2F2),
        border: const Color(0xFFFECACA),
        color: const Color(0xFFB91C1C),
      );
    }
    if (item.isUnderReview) {
      return _pillBadge(
        label: 'Under Review',
        icon: Icons.access_time_rounded,
        bg: const Color(0xFFFFFBEB),
        border: const Color(0xFFFDE68A),
        color: const Color(0xFFB45309),
      );
    }
    if (item.isGraded) {
      if (item.isPassed) {
        return _pillBadge(
          label: 'Passed (${item.examScore.round()}%)',
          icon: Icons.emoji_events_rounded,
          bg: const Color(0xFFECFDF5),
          border: const Color(0xFFA7F3D0),
          color: _emeraldDark,
        );
      }
      return _pillBadge(
        label: 'Graded (${item.examScore.round()}%)',
        icon: Icons.check_rounded,
        bg: const Color(0xFFF8FAFC),
        border: const Color(0xFFE2E8F0),
        color: const Color(0xFF334155),
      );
    }
    return _pillBadge(
      label: 'Action Required',
      icon: Icons.access_time_rounded,
      bg: const Color(0xFFEFF6FF),
      border: const Color(0xFFBFDBFE),
      color: const Color(0xFF2563EB),
    );
  }

  Widget _pillBadge({
    required String label,
    required IconData icon,
    required Color bg,
    required Color border,
    required Color color,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String text,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning ? const Color(0xFFFECACA) : _border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isWarning ? const Color(0xFFE11D48) : _muted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isWarning
                    ? const Color(0xFFBE123C)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. SCORECARD BOTTOM SHEET (STATUS DETAILS)
// ==========================================
class _ScorecardBottomSheet extends StatefulWidget {
  const _ScorecardBottomSheet({
    required this.assessment,
    required this.service,
  });

  final CandidateAssessmentListItem assessment;
  final CandidateAssessmentsService service;

  @override
  State<_ScorecardBottomSheet> createState() => _ScorecardBottomSheetState();
}

class _ScorecardBottomSheetState extends State<_ScorecardBottomSheet> {
  AssessmentSubmissionDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final res = await widget.service.getSubmissionDetail(
        widget.assessment.submissionId,
      );
      if (mounted) setState(() => _detail = res);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not load extended evaluation scorecard.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assessment;
    final isUnderReview = a.isUnderReview;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUnderReview
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnderReview
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Icon(
                  isUnderReview
                      ? Icons.access_time_rounded
                      : Icons.emoji_events_rounded,
                  color: isUnderReview ? const Color(0xFFD97706) : _emeraldDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnderReview
                          ? 'ASSESSMENT SUBMISSION • UNDER REVIEW'
                          : 'ASSESSMENT SCORECARD & AUDIT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isUnderReview
                            ? const Color(0xFFB45309)
                            : _emeraldDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.assessmentTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${a.jobTitle} • ${a.companyName}',
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: _muted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: _emerald)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFE11D48), fontSize: 13),
              ),
            )
          else ...[
            // Status notice
            if (isUnderReview)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          color: Color(0xFFD97706),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Manual Evaluation in Progress',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your code submission has been safely recorded and queued for assessment. An HR representative or technical reviewer will examine your algorithmic solutions, implementation efficiency, and code structure.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF78350F),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Score metrics row
              Row(
                children: [
                  Expanded(
                    child: _buildScoreTile(
                      title: 'Technical Score',
                      score: '${(_detail?.examScore ?? a.examScore).round()}%',
                      color: a.isPassed
                          ? _emeraldDark
                          : const Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildScoreTile(
                      title: 'Passing Benchmark',
                      score: '${a.passingThreshold.round()}%',
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Feedback box
              if ((_detail?.reviewerFeedback ?? a.reviewerFeedback) != null &&
                  (_detail?.reviewerFeedback ?? a.reviewerFeedback)!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REVIEWER FEEDBACK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${_detail?.reviewerFeedback ?? a.reviewerFeedback}"',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: _ink,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

              // Interview Selection Banner
              if (a.isSelectedForInterview) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: _emeraldDark,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You have been selected for the technical interview! Please check your Interviews tab.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _emeraldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreTile({
    required String title,
    required String score,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: _muted)),
          const SizedBox(height: 2),
          Text(
            score,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
