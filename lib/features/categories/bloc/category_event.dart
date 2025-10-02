import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {}

class LoadCategories extends CategoryEvent {
  @override
  List<Object?> get props => [];
}
