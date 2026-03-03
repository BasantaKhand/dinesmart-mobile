import 'package:flutter/material.dart';
import '../../domain/entities/table_entity.dart';

class TableGrid extends StatelessWidget {
  final List<TableEntity> tables;
  final TableEntity? selectedTable;
  final Function(TableEntity) onTableSelected;

  const TableGrid({
    super.key,
    required this.tables,
    this.selectedTable,
    required this.onTableSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double cardWidth = isTablet ? 200.0 : 140.0;
    final double listHeight = isTablet ? 170.0 : 130.0;

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          final isSelected = selectedTable?.id == table.id;
          final isOccupied = table.status == TableStatus.occupied;

          return GestureDetector(
            onTap: () => onTableSelected(table),
            child: SizedBox(
              width: cardWidth,
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.orange
                            : (isOccupied ? Colors.red : Colors.green),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 12 : 8),
                              decoration: BoxDecoration(
                                color: isOccupied ? Colors.blue : Colors.purple,
                                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                              ),
                              child: Text(
                                'T-${table.number}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 10 : 6),
                        Text(
                          'Table T-${table.number}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Serving guests',
                          style: TextStyle(color: Colors.grey, fontSize: isTablet ? 13 : 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 6,
                        vertical: isTablet ? 4 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOccupied ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(isTablet ? 10 : 6),
                        border: Border.all(
                          color: isOccupied ? Colors.red[200]! : Colors.green[200]!,
                        ),
                      ),
                      child: Text(
                        isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                        style: TextStyle(
                          color: isOccupied ? Colors.red : Colors.green,
                          fontSize: isTablet ? 11 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Close/check icon below the badge
                  Positioned(
                    bottom: isTablet ? 50 : 40,
                    left: isTablet ? 12 : 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOccupied ? Colors.red : Colors.green,
                      ),
                      child: Icon(
                        isOccupied ? Icons.close : Icons.check,
                        size: isTablet ? 16 : 14,
                        color: Colors.white,
                      ),
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
