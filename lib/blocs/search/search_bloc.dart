import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:walleta/repository/search/search_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;
  StreamSubscription? _subscription;

  SearchBloc(this.repository) : super(SearchInitial()) {
    /// 🔹 Evento cuando el texto cambia (con debounce)
    on<SearchTextChanged>(
      _onSearchTextChanged,
      transformer:
          (events, mapper) => events
              .debounceTime(const Duration(milliseconds: 300))
              .switchMap(mapper),
    );

    /// 🔹 Evento INTERNO para emitir resultados
    on<_EmitResults>((event, emit) {
      emit(SearchLoaded(event.users));
    });

    /// 🔹 Limpiar búsqueda
    on<ClearSearch>((event, emit) {
      _subscription?.cancel();
      emit(SearchInitial());
    });
  }

  Future<void> _onSearchTextChanged(
    SearchTextChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    await _subscription?.cancel();

    _subscription = repository
        .searchUsers(event.query.toLowerCase())
        .listen(
          (users) {
            /// 👇 Aquí NO se hace emit directo
            /// Se manda un evento interno
            add(_EmitResults(users));
          },
          onError: (_) {
            emit(const SearchError('Error al buscar usuarios'));
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

/// ⚠️ EVENTO INTERNO (va en ESTE archivo)
class _EmitResults extends SearchEvent {
  final List<Map<String, dynamic>> users;

  const _EmitResults(this.users);
}
