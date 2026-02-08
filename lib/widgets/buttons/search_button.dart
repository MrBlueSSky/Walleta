import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/search/bloc/search_bloc.dart';
import 'package:walleta/blocs/search/bloc/search_event.dart';
import 'package:walleta/blocs/search/bloc/search_state.dart';
import 'package:walleta/repository/search/search_repository.dart';

class SearchButton extends StatefulWidget {
  final void Function(Map<String, dynamic> user)? onUserSelected;
  final void Function(bool isActive)? onSearchStateChanged; // ← NUEVO
  final Color? iconColor;
  final double size;

  const SearchButton({
    super.key,
    this.iconColor,
    this.size = 26,
    this.onUserSelected,
    this.onSearchStateChanged, // ← NUEVO
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChange); // ← NUEVO: Escuchar cambios de foco
  }

  void _onFocusChange() {
    // Notificar cuando cambie el estado del foco
    final isActive = _focusNode.hasFocus || _isExpanded;
    widget.onSearchStateChanged?.call(isActive);
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // Notificar cambio de estado
    widget.onSearchStateChanged?.call(_isExpanded);

    if (_isExpanded) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    } else {
      _focusNode.unfocus();
      _searchController.clear();
      _removeOverlay();
      // Notificar que se desactivó
      widget.onSearchStateChanged?.call(false);
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Positioned(
          width: MediaQuery.of(context).size.width - 180,
          left: MediaQuery.of(context).size.width - 300,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 56),
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color:
                        isDark
                            ? const Color(0xFF334155).withOpacity(0.3)
                            : const Color(0xFFE5E7EB).withOpacity(0.8),
                    width: 0.5,
                  ),
                ),
                child: BlocProvider(
                  create:
                      (_) =>
                          SearchBloc(SearchRepository())
                            ..add(SearchTextChanged(_searchController.text)),
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      double? height;

                      switch (state.status) {
                        case SearchStatus.success:
                          if (state.users.isNotEmpty) {
                            final itemHeight = 64.0;
                            final padding = 12.0;
                            final calculatedHeight =
                                (state.users.length * itemHeight) + padding;
                            height = calculatedHeight.clamp(130.0, 350.0);
                          } else {
                            height = 130;
                          }
                          break;
                        case SearchStatus.loading:
                          height = 110;
                          break;
                        case SearchStatus.error:
                          height = 150;
                          break;
                        default:
                          height = 130;
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: height,
                        child: _SearchResults(
                          searchController: _searchController,
                          onUserTap: (user) {
                            _toggleSearch();
                            widget.onUserSelected?.call(user);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChange); // ← Limpiar listener
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        widget.iconColor ?? (isDark ? Colors.white : const Color(0xFF1F2937));
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    // Obtener las dimensiones del padre
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0 * 2; // Padding del Column padre
    const otherElementsWidth = 120.0; // Ancho aproximado de otros elementos

    // Calcular ancho disponible
    final availableWidth = screenWidth - padding - otherElementsWidth - 100;

    return CompositedTransformTarget(
      link: _layerLink,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.7, // Máximo 70% del ancho
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isExpanded ? availableWidth.clamp(150, 250) : 0,
              height: 48,
              margin: EdgeInsets.only(right: _isExpanded ? 8 : 0),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  _isExpanded
                      ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: TextStyle(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      )
                      : null,
            ),
            GestureDetector(
              onTap: _toggleSearch,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child:
                    _isExpanded
                        ? Container(
                          key: const ValueKey('close'),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D5BFF),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2D5BFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.close_circle,
                            size: 24,
                            color: Colors.white,
                          ),
                        )
                        : Container(
                          key: const ValueKey('search'),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color:
                                  isDark
                                      ? const Color(0xFF334155).withOpacity(0.3)
                                      : const Color(
                                        0xFFE5E7EB,
                                      ).withOpacity(0.8),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Iconsax.search_normal_1,
                            size: 24,
                            color: iconColor,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final TextEditingController searchController;
  final Function(Map<String, dynamic>) onUserTap;

  const _SearchResults({
    required this.searchController,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SearchBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    searchController.addListener(() {
      bloc.add(SearchTextChanged(searchController.text));
    });

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (SearchStatus.initial == state.status) {
          return _buildInitialState(isDark);
        }

        if (SearchStatus.loading == state.status) {
          return _buildLoadingState(isDark);
        }

        if (SearchStatus.success == state.status) {
          if (state.users.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return _buildResultsList(state, isDark);
        }

        if (SearchStatus.error == state.status) {
          return _buildErrorState(state, isDark);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 36,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe para buscar',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF2D5BFF),
              backgroundColor:
                  isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buscando...',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.user_search,
            size: 36,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron usuarios',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(SearchState state, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Resultados',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    state.users.length.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D5BFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 1),
              physics: const BouncingScrollPhysics(),
              itemCount: state.users.length,
              separatorBuilder:
                  (_, __) => Divider(
                    height: 1,
                    color:
                        isDark
                            ? const Color(0xFF334155).withOpacity(0.5)
                            : const Color(0xFFE5E7EB),
                    indent: 16,
                    endIndent: 16,
                  ),
              itemBuilder: (context, index) {
                final user = state.users[index];
                final hasProfilePicture =
                    user['profilePictureUrl'] != null &&
                    user['profilePictureUrl'].isNotEmpty;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onUserTap(user),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                                  hasProfilePicture
                                      ? null
                                      : const LinearGradient(
                                        colors: [
                                          Color(0xFF2D5BFF),
                                          Color(0xFF00C896),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                            ),
                            child:
                                hasProfilePicture
                                    ? ClipOval(
                                      child: Image.network(
                                        user['profilePictureUrl'],
                                        fit: BoxFit.cover,
                                        width: 36,
                                        height: 36,
                                      ),
                                    )
                                    : Center(
                                      child: Text(
                                        user['name']
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '@${user['username']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user['name']} ${user['surname']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SearchState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 36, color: const Color(0xFFFF6B6B)),
          const SizedBox(height: 8),
          Text(
            'Error de búsqueda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.message ?? 'Ocurrió un error inesperado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
