import 'package:flutter/material.dart';

class TreeSelect extends StatelessWidget {
  const TreeSelect({
    super.key,
    required this.title,
    required this.searchHintText,
    required this.groups,
    required this.selectedIds,
    required this.enabled,
    required this.onChanged,
    this.multiple = true,
    this.fieldKey,
    this.sheetKey,
    this.searchFieldKey,
    this.clearButtonKey,
    this.loading = false,
    this.emptyText = 'Không tìm thấy dữ liệu phù hợp.',
    this.cancelLabel = 'Hủy bỏ',
    this.confirmLabel = 'Xác nhận',
    this.clearTooltip = 'Xóa lựa chọn',
    this.groupKeyBuilder,
    this.itemKeyBuilder,
  });

  final String title;
  final String searchHintText;
  final List<TreeSelectGroup> groups;
  final Set<String> selectedIds;
  final bool enabled;
  final ValueChanged<Set<String>> onChanged;
  final bool multiple;
  final Key? fieldKey;
  final Key? sheetKey;
  final Key? searchFieldKey;
  final Key? clearButtonKey;
  final bool loading;
  final String emptyText;
  final String cancelLabel;
  final String confirmLabel;
  final String clearTooltip;
  final Key Function(TreeSelectGroup group)? groupKeyBuilder;
  final Key Function(TreeSelectGroup group, TreeSelectItem item)?
  itemKeyBuilder;

  static Future<Set<String>?> showSheet({
    required BuildContext context,
    required String title,
    required String searchHintText,
    required List<TreeSelectGroup> groups,
    required Set<String> initialSelection,
    bool multiple = true,
    String emptyText = 'Không tìm thấy dữ liệu phù hợp.',
    String cancelLabel = 'Hủy bỏ',
    String confirmLabel = 'Xác nhận',
    Key? sheetKey,
    Key? searchFieldKey,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _TreeSelectSheet(
          sheetKey: sheetKey,
          searchFieldKey: searchFieldKey,
          title: title,
          searchHintText: searchHintText,
          groups: groups,
          initialSelection: initialSelection,
          multiple: multiple,
          emptyText: emptyText,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    final itemLabels = <String, String>{};
    for (final group in groups) {
      for (final item in group.allItems) {
        itemLabels[item.id] = item.label;
      }
    }

    final selectedLabels = selectedIds
        .where(itemLabels.containsKey)
        .map((id) => itemLabels[id]!)
        .toList(growable: false);

    return InkWell(
      key: fieldKey,
      onTap: enabled
          ? () async {
              final nextSelection = await showModalBottomSheet<Set<String>>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) {
                  return _TreeSelectSheet(
                    sheetKey: sheetKey,
                    searchFieldKey: searchFieldKey,
                    title: title,
                    searchHintText: searchHintText,
                    groups: groups,
                    initialSelection: selectedIds,
                    multiple: multiple,
                    emptyText: emptyText,
                    cancelLabel: cancelLabel,
                    confirmLabel: confirmLabel,
                    groupKeyBuilder: groupKeyBuilder,
                    itemKeyBuilder: itemKeyBuilder,
                  );
                },
              );

              if (nextSelection == null) {
                return;
              }

              onChanged(nextSelection);
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: selectedLabels.isEmpty,
        isFocused: false,
        expands: false,
        decoration: InputDecoration(
          labelText: title,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: clearButtonKey,
                onPressed: enabled && selectedLabels.isNotEmpty
                    ? () => onChanged(const <String>{})
                    : null,
                tooltip: clearTooltip,
                icon: selectedLabels.isNotEmpty
                    ? Icon(Icons.close, color: colorScheme.onSurfaceVariant)
                    : Icon(
                        Icons.account_tree_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
        ),
        child: selectedLabels.isEmpty
            ? null
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final label in selectedLabels.take(3))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  if (selectedLabels.length > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '+${selectedLabels.length - 3}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class TreeSelectGroup {
  const TreeSelectGroup({
    required this.id,
    required this.label,
    this.items = const <TreeSelectItem>[],
    this.childGroups = const <TreeSelectGroup>[],
  });

  final String id;
  final String label;
  final List<TreeSelectItem> items;
  final List<TreeSelectGroup> childGroups;

  List<TreeSelectItem> get allItems {
    return [
      ...items,
      for (final childGroup in childGroups) ...childGroup.allItems,
    ];
  }

  int selectedCount(Set<String> selectedIds) {
    return allItems.where((item) => selectedIds.contains(item.id)).length;
  }

  bool allSelected(Set<String> selectedIds) {
    final items = allItems;

    return items.isNotEmpty && selectedCount(selectedIds) == items.length;
  }

  bool partiallySelected(Set<String> selectedIds) {
    final count = selectedCount(selectedIds);
    final itemCount = allItems.length;

    return count > 0 && count < itemCount;
  }
}

class TreeSelectItem {
  const TreeSelectItem({required this.id, required this.label, this.subtitle});

  final String id;
  final String label;
  final String? subtitle;
}

class _TreeSelectSheet extends StatefulWidget {
  const _TreeSelectSheet({
    required this.title,
    required this.searchHintText,
    required this.groups,
    required this.initialSelection,
    this.multiple = true,
    required this.emptyText,
    required this.cancelLabel,
    required this.confirmLabel,
    this.sheetKey,
    this.searchFieldKey,
    this.groupKeyBuilder,
    this.itemKeyBuilder,
  });

  final String title;
  final String searchHintText;
  final List<TreeSelectGroup> groups;
  final Set<String> initialSelection;
  final bool multiple;
  final String emptyText;
  final String cancelLabel;
  final String confirmLabel;
  final Key? sheetKey;
  final Key? searchFieldKey;
  final Key Function(TreeSelectGroup group)? groupKeyBuilder;
  final Key Function(TreeSelectGroup group, TreeSelectItem item)?
  itemKeyBuilder;

  @override
  State<_TreeSelectSheet> createState() => _TreeSelectSheetState();
}

final class _TreeSelectSheetState extends State<_TreeSelectSheet> {
  static const _treeIndentWidth = 8.0;

  late final TextEditingController _searchController;
  late Set<String> _selectedIds;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIds = Set<String>.from(widget.initialSelection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TreeSelectGroup> _filteredGroups() {
    if (_query.isEmpty) {
      return widget.groups;
    }

    final normalizedQuery = _query.toLowerCase();

    return widget.groups
        .map((group) => _filterGroup(group, normalizedQuery))
        .whereType<TreeSelectGroup>()
        .toList(growable: false);
  }

  TreeSelectGroup? _filterGroup(TreeSelectGroup group, String normalizedQuery) {
    final filteredItems = group.items
        .where((item) => item.label.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
    final filteredChildGroups = group.childGroups
        .map((childGroup) => _filterGroup(childGroup, normalizedQuery))
        .whereType<TreeSelectGroup>()
        .toList(growable: false);

    if (filteredItems.isEmpty && filteredChildGroups.isEmpty) {
      return null;
    }

    return TreeSelectGroup(
      id: group.id,
      label: group.label,
      items: filteredItems,
      childGroups: filteredChildGroups,
    );
  }

  void _toggleGroup(TreeSelectGroup group) {
    setState(() {
      if (group.allSelected(_selectedIds)) {
        for (final item in group.allItems) {
          _selectedIds.remove(item.id);
        }

        return;
      }

      for (final item in group.allItems) {
        _selectedIds.add(item.id);
      }
    });
  }

  Widget _buildGroupTile(TreeSelectGroup group, {int depth = 0}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSearching = _query.trim().isNotEmpty;
    final groupKey = widget.groupKeyBuilder?.call(group);

    return Padding(
      key: groupKey,
      padding: EdgeInsets.only(left: depth == 0 ? 0.0 : _treeIndentWidth),
      child: ExpansionTile(
        key: isSearching
            ? PageStorageKey('tree_tile_${group.id}_$_query')
            : null,
        initiallyExpanded: isSearching,
        shape: const Border(),
        collapsedShape: const Border(),
        dense: true,
        visualDensity: VisualDensity.compact,
        tilePadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        childrenPadding: EdgeInsets.zero,
        leading: widget.multiple
            ? SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  value: group.allSelected(_selectedIds)
                      ? true
                      : group.partiallySelected(_selectedIds)
                      ? null
                      : false,
                  tristate: true,
                  onChanged: (_) => _toggleGroup(group),
                ),
              )
            : Icon(
                Icons.corporate_fare_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
        title: Text(
          group.label,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        subtitle: widget.multiple
            ? Text(
                '${group.selectedCount(_selectedIds)} đã chọn',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : (group.selectedCount(_selectedIds) > 0
                  ? Text(
                      '1 đã chọn',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                      ),
                    )
                  : null),
        children: [
          for (final childGroup in group.childGroups)
            _buildGroupTile(childGroup, depth: depth + 1),
          for (final item in group.items)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 2.0),
              child: widget.multiple
                  ? CheckboxListTile(
                      key: widget.itemKeyBuilder?.call(group, item),
                      dense: true,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _selectedIds.contains(item.id),
                      title: Text(
                        item.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: item.subtitle == null
                          ? null
                          : Text(
                              item.subtitle!,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (_) {
                        setState(() {
                          if (_selectedIds.contains(item.id)) {
                            _selectedIds.remove(item.id);
                          } else {
                            _selectedIds.add(item.id);
                          }
                        });
                      },
                    )
                  : InkWell(
                      key: widget.itemKeyBuilder?.call(group, item),
                      onTap: () {
                        setState(() {
                          if (_selectedIds.contains(item.id)) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds = {item.id};
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 7,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedIds.contains(item.id)
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: _selectedIds.contains(item.id)
                                      ? 5.5
                                      : 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      item.subtitle!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = _filteredGroups();
    final colorScheme = Theme.of(context).colorScheme;

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: SafeArea(
        child: Padding(
          key: widget.sheetKey,
          padding: EdgeInsets.only(
            left: 10,
            top: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 64),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: _selectedIds.isNotEmpty
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedIds.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text(
                              'Đặt lại',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: widget.searchFieldKey,
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: widget.searchHintText,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredGroups.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(widget.emptyText),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final group in filteredGroups)
                            _buildGroupTile(group),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_selectedIds.isNotEmpty) ...[
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedIds.clear();
                            });
                            Navigator.of(context).pop(const <String>{});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text('Bỏ chọn'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: Text(widget.cancelLabel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: _selectedIds.isNotEmpty ? 1 : 1,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_selectedIds),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: Text(widget.confirmLabel),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
