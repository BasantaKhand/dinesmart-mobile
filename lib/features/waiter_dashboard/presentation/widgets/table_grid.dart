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
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          final isSelected = selectedTable?.id == table.id;
          final isOccupied = table.status == TableStatus.OCCUPIED;

          return GestureDetector(
            onTap: () => onTableSelected(table),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.orange : (isOccupied ? Colors.red.withOpacity(0.3) : Colors.grey[200]!),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          'T-${table.number}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isOccupied)
                        const Icon(Icons.close, color: Colors.red, size: 20),
                    ],
                  ),
                  Text(
                    isOccupied ? 'Occupied' : 'Available',
                    style: TextStyle(
                      color: isOccupied ? Colors.red : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Table T-${table.number}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Serving guests',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
