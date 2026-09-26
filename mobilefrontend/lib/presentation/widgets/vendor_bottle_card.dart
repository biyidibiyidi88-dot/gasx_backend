import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/vendor_models.dart';

class VendorBottleCard extends StatelessWidget {
  final GasBottle bottle;
  final VoidCallback onManage;

  const VendorBottleCard({
    super.key,
    required this.bottle,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bottle.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bottle.size.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                bottle.stock > 0
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: bottle.stock > 0
                    ? AppTheme.accentTeal
                    : AppTheme.criticalRed,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${bottle.price.toStringAsFixed(0)} FCFA',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${bottle.stock} UNITS IN STOCK',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onManage,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'MANAGE STOCK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
