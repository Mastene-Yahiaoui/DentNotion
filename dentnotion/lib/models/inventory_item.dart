class InventoryItem {
  final String item;
  final int quantity;
  final String status;

  InventoryItem({
    required this.item,
    required this.quantity,
    required this.status,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      item: (json['item'] ?? json['name'] ?? '') as String,
      quantity: (json['quantity'] ?? json['qty'] ?? 0) is int ? (json['quantity'] ?? json['qty']) as int : int.tryParse((json['quantity'] ?? json['qty']).toString()) ?? 0,
      status: (json['status'] ?? '') as String,
    );
  }
}
