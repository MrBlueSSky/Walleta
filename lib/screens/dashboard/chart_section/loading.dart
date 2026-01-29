import 'package:flutter/material.dart';

class ChartLoadingState extends StatelessWidget {
  final bool isSmall;

  const ChartLoadingState({Key? key, this.isSmall = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          if (!isSmall) ...[
            const SizedBox(height: 16),
            Text(
              'Cargando datos...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
