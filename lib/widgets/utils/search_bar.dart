import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/search/search_bloc.dart';
import 'package:walleta/blocs/search/search_event.dart';
import 'package:walleta/blocs/search/search_state.dart';
import 'package:walleta/repository/search/search_repository.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(SearchRepository()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SearchBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                bloc.add(SearchTextChanged(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return const Center(child: Text('Escribe un username'));
                }

                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchLoaded) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron usuarios'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user['profilePictureUrl'],
                          ),
                        ),
                        title: Text(user['username']),
                        subtitle: Text('${user['name']} ${user['surname']}'),
                        onTap: () {
                          // navegar al perfil
                        },
                      );
                    },
                  );
                }

                if (state is SearchError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
