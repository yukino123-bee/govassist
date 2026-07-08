import 'package:flutter/material.dart';
import 'notifications_screen.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/service_card.dart';
import 'service_detail_screen.dart';
import '../../core/user_session.dart';
import '../services/application_tracking_screen.dart';
import '../../core/translations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GovernmentService> _services = [];
  List<dynamic> _applications = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (mounted && _services.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    final userId = UserSession().currentUser?['id']?.toString();
    
    // Create futures for parallel execution
    final servicesFuture = ServiceData.fetchServices(query: _searchQuery, forceRefresh: forceRefresh);
    final notifsFuture = userId != null ? ServiceData.fetchNotifications(userId) : Future.value({});
    final appsFuture = userId != null ? ServiceData.fetchApplications(userId) : Future.value({});

    // Wait for all futures simultaneously to dramatically speed up loading
    final results = await Future.wait([servicesFuture, notifsFuture, appsFuture]);
    
    final services = results[0] as List<GovernmentService>;
    final notifs = results[1] as Map<String, dynamic>;
    final appsData = results[2] as Map<String, dynamic>;

    int unread = 0;
    List<dynamic> applications = [];
    
    if (notifs['unreadCount'] != null) {
      unread = int.tryParse(notifs['unreadCount'].toString()) ?? 0;
    }
    if (appsData['applications'] != null) {
      applications = appsData['applications'];
    }

    if (mounted) {
      setState(() {
        _services = services;
        _applications = applications;
        _unreadCount = unread;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset('assets/images/logo.png', width: 28, height: 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      'GovAssist',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                                          ).then((_) => _loadData());
                                        },
                                      ),
                                      if (_unreadCount > 0)
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                            child: Text(
                                              _unreadCount > 10 ? '10+' : '$_unreadCount',
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Welcome back,'.tr(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UserSession().currentUser?['full_name'] ?? 'Citizen',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  _searchQuery = value;
                                  _loadData();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search for government services...'.tr(),
                                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade400),
                                  prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Recent Applications'.tr()),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _applications.isEmpty
                            ? Text('You haven\'t submitted any applications yet.'.tr())
                            : Column(
                                children: _applications.take(2).map((app) {
                                  final status = app['status'] ?? 'Submitted';
                                  Color color = Colors.blue;
                                  if (status.toLowerCase() == 'approved') color = Colors.green;
                                  if (status.toLowerCase() == 'rejected') color = Colors.red;
                                  if (status.toLowerCase() == 'under review') color = Colors.orange;

                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: color.withValues(alpha: 0.1),
                                        child: Icon(Icons.description, color: color),
                                      ),
                                      title: Text(app['service_title'] ?? 'Service Application'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${'Status: '.tr()} $status\n${'Submitted on: '.tr()} ${app['submitted_at'] ?? ''}'),
                                      isThreeLine: true,
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ApplicationTrackingScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.campaign, color: Theme.of(context).colorScheme.secondary, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Provincial Announcement'.tr(),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stay updated on the latest government programs.'.tr(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SectionHeader(title: 'All Services'.tr()),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _services.isEmpty
                            ? Text('No services found.'.tr())
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _services.length,
                                itemBuilder: (context, index) {
                                  final service = _services[index];
                                  return ServiceCard(
                                    service: service,
                                    onViewDetails: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ServiceDetailScreen(service: service),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                    const SizedBox(height: 32),
                    
                    SectionHeader(title: 'Emergency Hotlines'.tr()),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildHotlineCard(context, Icons.local_police, 'Police'.tr(), '117', Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildHotlineCard(context, Icons.local_fire_department, 'Fire'.tr(), '911', Colors.orange)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildHotlineCard(context, Icons.medical_services, 'Hospital'.tr(), '143', Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHotlineCard(BuildContext context, IconData icon, String title, String number, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade800)),
          const SizedBox(height: 4),
          Text(number, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
