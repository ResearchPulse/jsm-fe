import 'package:equatable/equatable.dart';

import '../../domain/entities/journal_item_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<JournalItemEntity> journals;

  const HomeLoaded({required this.journals});

  @override
  List<Object?> get props => [journals];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
