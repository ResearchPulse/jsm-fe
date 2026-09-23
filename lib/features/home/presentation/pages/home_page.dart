import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';

import '../../../admin/presentation/pages/admin_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch data initially
    context.read<HomeCubit>().fetchFeaturedJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
              label: const Text('Admin dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0071BC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const LoadingView(message: 'Tải danh sách tạp chí...');
          } else if (state is HomeError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<HomeCubit>().fetchFeaturedJournals(),
            );
          } else if (state is HomeLoaded) {
            final journals = state.journals;
            if (journals.isEmpty) {
              return const Center(child: Text('Không có tạp chí nào.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final item = journals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.category),
                    trailing: Chip(
                      label: Text(
                        'IF: ${item.impactFactor}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
