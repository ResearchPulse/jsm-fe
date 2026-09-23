import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';
import '../../domain/usecases/get_featured_journals_usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetFeaturedJournalsUseCase getFeaturedJournalsUseCase;

  HomeCubit({required this.getFeaturedJournalsUseCase}) : super(HomeInitial());

  Future<void> fetchFeaturedJournals() async {
    emit(HomeLoading());
    try {
      final journals = await getFeaturedJournalsUseCase();
      emit(HomeLoaded(journals: journals));
    } catch (e) {
      // In a real app, parse specific failures and messages from exceptions
      emit(HomeError(message: 'Failed to fetch featured journals: $e'));
    }
  }
}
