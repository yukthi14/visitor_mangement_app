import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/visitor_card.dart';
import '../../../data/models/visitor_model.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import 'register_visitor_screen.dart';
import 'visitor_details_screen.dart';

class VisitorListScreen extends StatefulWidget {
  final bool showAppBar;

  const VisitorListScreen({super.key, this.showAppBar = true});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProjectFilter;
  String? _selectedStatusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<VisitorBloc>().add(SearchVisitors(query));
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppConstants.filterVisitorsTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedProjectFilter = null;
                            _selectedStatusFilter = null;
                          });
                          setState(() {
                            _selectedProjectFilter = null;
                            _selectedStatusFilter = null;
                          });
                          context.read<VisitorBloc>().add(
                                const FilterVisitors(project: null, status: null),
                              );
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(AppConstants.reset),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Project filter
                  const Text(AppConstants.labelProject, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.projects.map((project) {
                      final isSelected = _selectedProjectFilter == project;
                      return ChoiceChip(
                        label: Text(project),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedProjectFilter = selected ? project : null;
                          });
                          setState(() {
                            _selectedProjectFilter = selected ? project : null;
                          });
                          context.read<VisitorBloc>().add(
                                FilterVisitors(
                                  project: _selectedProjectFilter,
                                  status: _selectedStatusFilter,
                                ),
                              );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Status filter
                  const Text(AppConstants.labelStatus, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      AppConstants.statusRegistered,
                      AppConstants.statusCheckedIn,
                      AppConstants.statusCheckedOut,
                    ].map((status) {
                      final isSelected = _selectedStatusFilter == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedStatusFilter = selected ? status : null;
                          });
                          setState(() {
                            _selectedStatusFilter = selected ? status : null;
                          });
                          context.read<VisitorBloc>().add(
                                FilterVisitors(
                                  project: _selectedProjectFilter,
                                  status: _selectedStatusFilter,
                                ),
                              );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(VisitorModel visitor) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: AppConstants.dialogDeleteTitle,
      message: '${AppConstants.dialogDeletePrompt} ${visitor.name} (${visitor.id})?',
    );

    if (confirmed == true && mounted) {
      context.read<VisitorBloc>().add(DeleteVisitorRequested(visitor.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(AppConstants.titleVisitorList),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: _showFilterModal,
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.person_add_alt_1),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RegisterVisitorScreen()),
          );
        },
      ),
      body: BlocConsumer<VisitorBloc, VisitorState>(
        listener: (context, state) {
          if (state is VisitorLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VisitorLoading) {
            return const LoadingView(message: AppConstants.loadingVisitors);
          }

          if (state is VisitorError) {
            return EmptyStateView(
              icon: Icons.error_outline_rounded,
              title: AppConstants.errorLoadingVisitors,
              message: state.message,
              actionText: AppConstants.retry,
              onAction: () => context.read<VisitorBloc>().add(const LoadVisitors(isRefresh: true)),
            );
          }

          if (state is VisitorLoaded) {
            final visitors = state.filteredVisitors;

            return Column(
              children: [
                // Search Input Field
                Container(
                  color: AppColors.surfaceColor(context),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFillColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderColor(context)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        color: AppColors.textPrimaryColor(context),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: AppConstants.searchHint,
                        hintStyle: TextStyle(
                          color: AppColors.textMutedColor(context),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondaryColor(context),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18, color: AppColors.textSecondaryColor(context)),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Active filter indicator if any
                if (_selectedProjectFilter != null || _selectedStatusFilter != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: AppColors.primaryLight,
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${AppConstants.filteredBy} ${[_selectedProjectFilter, _selectedStatusFilter].where((e) => e != null).join(', ')}',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedProjectFilter = null;
                              _selectedStatusFilter = null;
                            });
                            context.read<VisitorBloc>().add(
                                  const FilterVisitors(project: null, status: null),
                                );
                          },
                          child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                // Visitor List
                Expanded(
                  child: visitors.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            context.read<VisitorBloc>().add(const LoadVisitors(isRefresh: true));
                          },
                          child: ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              EmptyStateView(
                                icon: state.searchQuery.isNotEmpty ? Icons.search_off_rounded : null,
                                title: state.searchQuery.isNotEmpty ? AppConstants.noMatchesFound : AppConstants.noVisitorsRegistered,
                                message: state.searchQuery.isNotEmpty
                                    ? '${AppConstants.noVisitorsFound} "${state.searchQuery}"'
                                    : AppConstants.registerNewVisitorPrompt,
                                actionText: state.searchQuery.isEmpty ? AppConstants.registerVisitor : null,
                                onAction: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterVisitorScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<VisitorBloc>().add(const LoadVisitors(isRefresh: true));
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: visitors.length,
                            itemBuilder: (context, index) {
                              final visitor = visitors[index];
                              return VisitorCard(
                                visitor: visitor,
                                onTap: () {
                                  context.read<VisitorBloc>().add(SelectVisitor(visitor));
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VisitorDetailsScreen(visitor: visitor),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => RegisterVisitorScreen(visitorToEdit: visitor),
                                    ),
                                  );
                                },
                                onDelete: () => _confirmDelete(visitor),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
