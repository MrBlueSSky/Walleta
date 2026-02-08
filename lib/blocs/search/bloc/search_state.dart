import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, success, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Map<String, dynamic>> users;
  final String? message;

  const SearchState({
    this.status = SearchStatus.initial,
    this.users = const [],
    this.message,
  });

  const SearchState.initial() : this(status: SearchStatus.initial);

  const SearchState.loading() : this(status: SearchStatus.loading);

  const SearchState.success(List<Map<String, dynamic>> users)
    : this(status: SearchStatus.success, users: users);

  const SearchState.error(String message)
    : this(status: SearchStatus.error, message: message);

  @override
  List<Object?> get props => [status, users, message];
}
