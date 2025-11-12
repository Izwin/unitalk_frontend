import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Универсальное модальное окно со списком для выбора
class BottomSheetListPicker<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemTitle;
  final String? Function(T)? itemImageUrl;
  final IconData defaultIcon;
  final void Function(T) onItemSelected;
  final bool showSearch;
  final String searchHint;
  final String emptyMessage;

  const BottomSheetListPicker({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.itemTitle,
    required this.onItemSelected,
    this.itemImageUrl,
    this.defaultIcon = Icons.check_circle,
    this.showSearch = true,
    required this.searchHint,
    required this.emptyMessage,
  }) : super(key: key);

  @override
  State<BottomSheetListPicker<T>> createState() =>
      _BottomSheetListPickerState<T>();
}

class _BottomSheetListPickerState<T> extends State<BottomSheetListPicker<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return widget.itemTitle(item).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.emptyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              itemCount: _filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = _filteredItems[index];
                final isSelected = widget.selectedItem == item;
                final imageUrl = widget.itemImageUrl?.call(item);

                return InkWell(
                  onTap: () {
                    widget.onItemSelected(item);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.08)
                          : theme.cardColor,
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Icon/Image
                        if (imageUrl != null)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Icon(
                                  widget.defaultIcon,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.defaultIcon,
                              color: theme.primaryColor,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.itemTitle(item),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}