// File: lib/screens/examples/example_state_management_screen.dart
// Purpose: Demo tất cả state widgets & best practices

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/state/state_widgets.dart';

/// Example screen showing all state management patterns
/// This file demonstrates best practices for the refactored UI architecture
class ExampleStateManagementScreen extends StatefulWidget {
  const ExampleStateManagementScreen({super.key});

  @override
  State<ExampleStateManagementScreen> createState() =>
      _ExampleStateManagementScreenState();
}

class _ExampleStateManagementScreenState
    extends State<ExampleStateManagementScreen> {
  // State management
  UIState _currentState = UIState.idle;
  UIError? _currentError;
  List<String> _exampleItems = [];

  // For demo purposes
  int _selectedDemo = 0;

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  // Simulate API call with delay
  Future<void> _loadDemoData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _exampleItems = ['Item 1', 'Item 2', 'Item 3'];
        _currentState = UIState.success;
      });
    }
  }

  // Demo: Simulate loading state
  void _demoLoading() {
    setState(() {
      _currentState = UIState.loading;
      _currentError = null;
      _exampleItems = [];
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentState = UIState.success;
          _exampleItems = ['Demo Item 1', 'Demo Item 2'];
        });
      }
    });
  }

  // Demo: Simulate error state
  void _demoError() {
    setState(() {
      _currentState = UIState.error;
      _currentError = UIError(
        title: 'Failed to load items',
        message: 'Network connection error. Please check your internet.',
        code: 'NETWORK_ERROR',
      );
      _exampleItems = [];
    });
  }

  // Demo: Simulate empty state
  void _demoEmpty() {
    setState(() {
      _currentState = UIState.empty;
      _currentError = null;
      _exampleItems = [];
    });
  }

  // Demo: Simulate success with data
  void _demoSuccess() {
    setState(() {
      _currentState = UIState.success;
      _currentError = null;
      _exampleItems = ['Item A', 'Item B', 'Item C', 'Item D'];
    });
  }

  // Show success dialog demo
  void _showSuccessDialogDemo() {
    showDialog(
      context: context,
      builder: (_) => SuccessDialog(
        title: 'Action Completed',
        message: 'Your changes have been saved successfully!',
        actionLabel: 'Great',
        onAction: () => print('Success action'),
        autoClose: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UI State Management Examples',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Demo selector buttons
            _buildDemoSelector(),
            const Divider(thickness: 2),

            // Current state display
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current State: ${_currentState.toString().split('.').last.toUpperCase()}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (_currentError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${_currentError!.title}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Main content area showing current state
            Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildStateContent(),
            ),

            // State-specific info
            _buildStateInfo(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Demo selector buttons
  Widget _buildDemoSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Demo State',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DemoButton(
                label: 'Loading',
                icon: '⏳',
                onTap: _demoLoading,
              ),
              _DemoButton(
                label: 'Error',
                icon: '⚠️',
                onTap: _demoError,
              ),
              _DemoButton(
                label: 'Empty',
                icon: '📭',
                onTap: _demoEmpty,
              ),
              _DemoButton(
                label: 'Success',
                icon: '✅',
                onTap: _demoSuccess,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build state-specific content
  Widget _buildStateContent() {
    switch (_currentState) {
      case UIState.loading:
        return SkeletonLoader(
          itemCount: 3,
          itemHeight: 80,
        );

      case UIState.error:
        return ErrorOverlay(
          title: _currentError?.title ?? 'Error occurred',
          message: _currentError?.message,
          onRetry: _demoLoading,
          onDismiss: _demoEmpty,
        );

      case UIState.empty:
        return EmptyStateOverlay(
          icon: '📭',
          title: 'No Data Available',
          description: 'There are no items to display',
          ctaLabel: 'Load Demo Data',
          onCTA: _demoSuccess,
        );

      case UIState.success:
      case UIState.idle:
        return _buildSuccessContent();
    }
  }

  // Build success content with list
  Widget _buildSuccessContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Items (${_exampleItems.length})',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ..._exampleItems.asMap().entries.map((e) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(e.key.toString()),
              ),
              title: Text(
                e.value,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Demo item #${e.key + 1}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _showSuccessDialogDemo,
          child: Text(
            'Show Success Dialog',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Build info about current state
  Widget _buildStateInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'State Information',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 12),
          _StateInfoTile(
            label: 'Current State',
            value: _currentState.toString().split('.').last.toUpperCase(),
          ),
          _StateInfoTile(
            label: 'Items Count',
            value: _exampleItems.length.toString(),
          ),
          if (_currentError != null)
            _StateInfoTile(
              label: 'Error Code',
              value: _currentError!.code ?? 'UNKNOWN',
            ),
          const SizedBox(height: 12),
          Text(
            'How to use in your screen:',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '1. Declare: UIState _state = UIState.loading;\n'
              '2. Set before API: setState(() => _state = UIState.loading);\n'
              '3. Switch in build: switch(_state) { ... }\n'
              '4. Use widgets: SkeletonLoader, ErrorOverlay, EmptyStateOverlay',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Demo button widget
class _DemoButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _DemoButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Text(icon, style: const TextStyle(fontSize: 18)),
      label: Text(
        label,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// State info tile
class _StateInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _StateInfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}

/*
USAGE EXAMPLE - How to refactor your screen:

BEFORE:
------
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No items'))
              : ListView(children: ...),
    );
  }
}


AFTER:
-----
import 'package:myapp/widgets/state/state_widgets.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<dynamic> _items = [];
  UIState _state = UIState.loading;       // ← New!
  UIError? _error;                         // ← New!

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _state = UIState.loading;            // ← New!
      _error = null;                        // ← New!
    });
    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _state = items.isEmpty            // ← New!
            ? UIState.empty
            : UIState.success;
      });
    } catch (e) {
      setState(() {
        _state = UIState.error;             // ← New!
        _error = UIError.genericError(      // ← New!
          message: e.toString(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),                  // ← New!
    );
  }

  Widget _buildBody() {                    // ← New!
    switch (_state) {
      case UIState.loading:
        return const SkeletonLoader(itemCount: 4);

      case UIState.error:
        return ErrorOverlay(
          title: _error?.title ?? 'Error',
          message: _error?.message,
          onRetry: _loadItems,
          onDismiss: () => Navigator.pop(context),
        );

      case UIState.empty:
        return EmptyStateOverlay(
          icon: '📭',
          title: 'No items',
          ctaLabel: 'Retry',
          onCTA: _loadItems,
        );

      case UIState.success:
      case UIState.idle:
        return ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(_items[i]['title']),
          ),
        );
    }
  }
}
*/
