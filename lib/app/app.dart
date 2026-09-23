import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/cubit/home_cubit.dart';
import '../features/home/domain/usecases/get_featured_journals_usecase.dart';
import '../features/home/data/repositories/home_repository_impl.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would use get_it or similar for Dependency Injection.
    // For this boilerplate, we're providing it locally at the top level.
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (_) => HomeRepositoryImpl())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeCubit(
              getFeaturedJournalsUseCase: GetFeaturedJournalsUseCase(
                context.read<HomeRepositoryImpl>(),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Journal Publication Trend',
          theme: AppTheme.lightTheme,
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
