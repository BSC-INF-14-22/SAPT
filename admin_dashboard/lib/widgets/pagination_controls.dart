import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPages = (totalItems / rowsPerPage).ceil();
    final int startItem = totalItems == 0 ? 0 : (currentPage * rowsPerPage) + 1;
    final int endItem = (currentPage + 1) * rowsPerPage > totalItems 
        ? totalItems 
        : (currentPage + 1) * rowsPerPage;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rows per page: ', style: TextStyle(color: Colors.black54)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                onChanged: onRowsPerPageChanged,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 24),
              Text(
                '$startItem-$endItem of $totalItems',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                tooltip: 'Previous Page',
              ),
              const SizedBox(width: 8),
              ...List.generate(totalPages, (index) {
                // Showing a maximum of 5 page numbers for simplicity, or just show current/total
                if (totalPages > 5) {
                   if (index == 0 || index == totalPages -1 || (index >= currentPage - 1 && index <= currentPage + 1)) {
                     return _buildPageButton(index);
                   } else if (index == 1 || index == totalPages - 2) {
                     return const Text('...');
                   }
                   return const SizedBox.shrink();
                }
                return _buildPageButton(index);
              }),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                tooltip: 'Next Page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int index) {
    final bool isSelected = index == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () => onPageChanged(index),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black87 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
