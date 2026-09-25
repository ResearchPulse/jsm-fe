import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme/app_theme.dart';
import 'auth_gate.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/home/presentation/cubit/home_cubit.dart';
import '../features/home/domain/usecases/get_featured_journals_usecase.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/users/presentation/pages/user_info_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection for Home feature.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepositoryImpl>(
          create: (_) => HomeRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(
              getFeaturedJournalsUseCase: GetFeaturedJournalsUseCase(
                context.read<HomeRepositoryImpl>(),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'journal system miner - HyperDataLab',
          theme: AppTheme.lightTheme,

          // Authentication is now the entry point of the application.
          home: const AuthGate(),

          routes: {
            '/home': (context) => const HomePage(),
            '/admin': (context) => const AdminDashboardPage(),
            '/admin/pipeline': (context) =>
                const AdminDashboardPage(initialIndex: 8),
            '/user-info': (context) => const UserInfoPage(),
          },

          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}