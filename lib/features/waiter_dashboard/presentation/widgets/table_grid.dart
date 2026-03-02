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
    return SizedBox(
      height: 130,
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
              width: 140,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isOccupied ? Colors.blue : Colors.purple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ' ${table.number} ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Table T-${table.number}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Serving guests',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOccupied ? Colors.red : Colors.green,
                      ),
                      child: Icon(
                        isOccupied ? Icons.close : Icons.check,
                        size: 14,
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
