import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/visitor_model.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import 'qr_display_screen.dart';

class RegisterVisitorScreen extends StatefulWidget {
  final VisitorModel? visitorToEdit;

  const RegisterVisitorScreen({super.key, this.visitorToEdit});

  @override
  State<RegisterVisitorScreen> createState() => _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _purposeController;

  String? _selectedVisitorType;
  String? _selectedProject;

  bool get isEditMode => widget.visitorToEdit != null;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitorToEdit;
    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');
    _selectedVisitorType = visitor?.visitorType;
    _selectedProject = visitor?.project;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVisitorType == null || _selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select visitor type and project')),
      );
      return;
    }

    final bloc = context.read<VisitorBloc>();

    if (isEditMode) {
      final updated = widget.visitorToEdit!.copyWith(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        visitorType: _selectedVisitorType!,
        project: _selectedProject!,
        purpose: _purposeController.text.trim(),
      );
      bloc.add(UpdateVisitorSubmitted(updated));
    } else {
      bloc.add(
        RegisterVisitorSubmitted(
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          visitorType: _selectedVisitorType!,
          project: _selectedProject!,
          purpose: _purposeController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit Visitor' : 'Register Visitor';
    final buttonText = isEditMode ? 'Update' : 'Save';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<VisitorBloc, VisitorState>(
        listener: (context, state) {
          if (state is VisitorLoaded) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.danger,
                ),
              );
            } else if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success,
                ),
              );

              if (isEditMode) {
                Navigator.of(context).pop();
              } else if (state.selectedVisitor != null) {
                // Navigate to QR Code generation screen (Wireframe 9)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => QRDisplayScreen(visitor: state.selectedVisitor!),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            }
          }
        },
        builder: (context, state) {
          final isSubmitting = state is VisitorLoaded && state.isSubmitting;

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Visitor Name
                          CustomTextField(
                            label: 'Visitor Name',
                            hintText: 'Enter visitor name',
                            controller: _nameController,
                            isRequired: true,
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: 18),

                          // Mobile Number
                          CustomTextField(
                            label: 'Mobile Number',
                            hintText: 'Enter 10 digit mobile number',
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                            validator: Validators.validateMobile,
                          ),
                          const SizedBox(height: 18),

                          // Email
                          CustomTextField(
                            label: 'Email (Optional)',
                            hintText: 'Enter email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 18),

                          // Visitor Type
                          CustomDropdown<String>(
                            label: 'Visitor Type',
                            hintText: 'Select visitor type',
                            value: _selectedVisitorType,
                            items: AppConstants.visitorTypes,
                            itemLabelBuilder: (item) => item,
                            isRequired: true,
                            onChanged: (val) {
                              setState(() {
                                _selectedVisitorType = val;
                              });
                            },
                          ),
                          const SizedBox(height: 18),

                          // Project
                          CustomDropdown<String>(
                            label: 'Project',
                            hintText: 'Select project',
                            value: _selectedProject,
                            items: AppConstants.projects,
                            itemLabelBuilder: (item) => item,
                            isRequired: true,
                            onChanged: (val) {
                              setState(() {
                                _selectedProject = val;
                              });
                            },
                          ),
                          const SizedBox(height: 18),

                          // Purpose of Visit
                          CustomTextField(
                            label: 'Purpose of Visit',
                            hintText: 'Enter purpose of visit',
                            controller: _purposeController,
                            isRequired: true,
                            maxLines: 2,
                            validator: (val) => Validators.validateRequired(val, 'Purpose of visit'),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Save / Update button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: buttonText,
                      isLoading: isSubmitting,
                      onPressed: _onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
