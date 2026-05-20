import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Empty state overlay widget - để lồng vào Stack
class EmptyStateOverlay extends StatelessWidget {
  final String icon;
  final String title;
  final String? description;
  final String? ctaLabel;
  final VoidCallback? onCTA;

  const EmptyStateOverlay({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.ctaLabel,
    this.onCTA,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: GoogleFonts.outfit(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (ctaLabel != null && onCTA != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onCTA,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  ctaLabel!,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full screen empty state widget
class EmptyStateScreen extends StatelessWidget {
  final String icon;
  final String title;
  final String? description;
  final String? ctaLabel;
  final VoidCallback? onCTA;
  final VoidCallback? onBack;

  const EmptyStateScreen({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.ctaLabel,
    this.onCTA,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: onBack != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
              elevation: 0,
            )
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: GoogleFonts.outfit(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 12),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (ctaLabel != null && onCTA != null) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onCTA,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    ctaLabel!,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
