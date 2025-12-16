import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboardStats()
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final data = dashboard.data;

    if (dashboard.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboard.error != null) {
      return Center(child: Text('Error: ${dashboard.error}'));
    }

    if (data == null) return const SizedBox();

    final kpi = data['kpi'];
    final charts = data['charts'];
    final lists = data['lists'];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Welcome back, ${user?['username'] ?? 'User'}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(user?['username']?[0].toUpperCase() ?? 'A', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // KPI Grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildModernStatCard(
                  context, 
                  title: 'Total News', 
                  value: kpi['totalNews'].toString(), 
                  icon: Icons.article_outlined, 
                  startColor: const Color(0xFF4F46E5), 
                  endColor: const Color(0xFF818CF8)
                ),
                _buildModernStatCard(
                  context, 
                  title: 'Total Views', 
                  value: kpi['totalViews'].toString(), 
                  icon: Icons.remove_red_eye_outlined, 
                  startColor: const Color(0xFF0EA5E9), 
                  endColor: const Color(0xFF38BDF8)
                ),
                _buildModernStatCard(
                  context, 
                  title: 'Categories', 
                  value: kpi['totalCategories'].toString(), 
                  icon: Icons.category_outlined, 
                  startColor: const Color(0xFFF59E0B), 
                  endColor: const Color(0xFFFBBF24)
                ),
                _buildModernStatCard(
                  context, 
                  title: 'Users', 
                  value: kpi['totalUsers'].toString(), 
                  icon: Icons.people_outline, 
                  startColor: const Color(0xFF10B981), 
                  endColor: const Color(0xFF34D399)
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Chart (Trends)
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('News Posting Activity (Last 7 Days)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 250,
                            child: _buildLineChart(charts['newsTrend']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Pie Chart (Categories)
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Top Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 250,
                            child: _buildPieChart(charts['newsByCategory']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Lists
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                     elevation: 1,
                     child: Padding(
                       padding: const EdgeInsets.all(20),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text('Most Viewed News', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: lists['topNews'].length,
                              itemBuilder: (ctx, i) {
                                final item = lists['topNews'][i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Text('${i+1}')),
                                  title: Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: Text('${item['views']} views', style: const TextStyle(fontWeight: FontWeight.bold)),
                                );
                              },
                            ),
                         ],
                       ),
                     ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                     elevation: 1,
                     child: Padding(
                       padding: const EdgeInsets.all(20),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: lists['recentNews'].length,
                              itemBuilder: (ctx, i) {
                                final item = lists['recentNews'][i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.new_releases_outlined, size: 20),
                                  title: Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text('${item['status']} • ${item['author']['username']}'),
                                );
                              },
                            ),
                         ],
                       ),
                     ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color startColor, required Color endColor}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: startColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> data) {
    if (data.isEmpty) return const Center(child: Text('No Data'));
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((entry) {
           final index = entry.key;
           final item = entry.value;
           final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
           return PieChartSectionData(
             color: colors[index % colors.length],
             value: (item['count'] as num).toDouble(),
             title: '${item['_id']}\n${item['count']}',
             radius: 50,
             titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
           );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(List<dynamic> data) {
    if (data.isEmpty) return const Center(child: Text('No Activity Yet'));

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), (data[i]['count'] as num).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
           show: true, 
           drawVerticalLine: false, 
           getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
             sideTitles: SideTitles(
               showTitles: true,
               getTitlesWidget: (val, meta) {
                 if (val.toInt() >= 0 && val.toInt() < data.length) {
                   String date = data[val.toInt()]['_id']; // YYYY-MM-DD
                   return Padding(padding: const EdgeInsets.only(top: 8), child: Text(date.substring(5), style: TextStyle(color: Colors.grey[600], fontSize: 10)));
                 }
                 return const Text('');
               },
             ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide left labels for simplicity
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4F46E5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF4F46E5).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}
