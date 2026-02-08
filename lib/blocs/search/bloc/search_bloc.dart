import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:walleta/repository/search/search_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;
  StreamSubscription? _subscription;

  SearchBloc(this.repository) : super(const SearchState.initial()) {
    /// 🔹 Evento cuando cambia el texto (con debounce)
    on<SearchTextChanged>(
      _onSearchTextChanged,
      transformer:
          (events, mapper) => events
              .debounceTime(const Duration(milliseconds: 300))
              .switchMap(mapper),
    );

    /// 🔹 Evento interno para emitir resultados
    on<_EmitResults>((event, emit) {
      emit(SearchState.success(event.users));
    });

    /// 🔹 Limpiar búsqueda
    on<ClearSearch>((event, emit) {
      _subscription?.cancel();
      emit(const SearchState.initial());
    });
  }

  Future<void> _onSearchTextChanged(
    SearchTextChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchState.loading());

    await _subscription?.cancel();

    _subscription = repository
        .searchUsers(event.query.toLowerCase())
        .listen(
          (users) {
            add(_EmitResults(users));
          },
          onError: (_) {
            emit(const SearchState.error('Error al buscar usuarios'));
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

/// ⚠️ Evento interno (solo para este bloc)
class _EmitResults extends SearchEvent {
  final List<Map<String, dynamic>> users;

  const _EmitResults(this.users);
}
