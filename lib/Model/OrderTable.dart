import 'dart:convert';

class Product {
  final int? id;
  final int? transactionId;
  final int? productId;
  final int? variationId;
  final String quantity;
  final String? secondaryUnitQuantity;
  final String? quantityReturned;
  final String? unitPriceBeforeDiscount;
  final String price;
  final String? lineDiscountType;
  final String? lineDiscountAmount;
  final String? unitPriceIncTax;
  final String? itemTax;
  final int? taxId;
  final String? soQuantityInvoiced;
  final int? soLineId;
  final int? resServiceStaffId;
  final int? parentSellLineId;
  final int? subUnitId;
  final int? businessId;
  final int? unitId;
  final int? secondaryUnitId;
  final int? brandId;
  final int? categoryId;
  final int? subCategoryId;
  final int? enableStock;
  final int? discountId;
  final int? lotNoLineId;
  final String? sellLineNote;
  final String? resLineOrderStatus;
  final String? childrenType;
  final String? createdAt;
  final String? updatedAt;
  final String name;
  final String? type;
  final String? subUnitIds;
  final String? tax;
  final String? taxType;
  final String? alertQuantity;
  final String? sku;

  Product({
    this.id,
    this.transactionId,
    this.productId,
    this.variationId,
    required this.quantity,
    this.secondaryUnitQuantity,
    this.quantityReturned,
    this.unitPriceBeforeDiscount,
    required this.price,
    this.lineDiscountType,
    this.lineDiscountAmount,
    this.unitPriceIncTax,
    this.itemTax,
    this.taxId,
    this.discountId,
    this.lotNoLineId,
    this.sellLineNote,
    this.soLineId,
    this.soQuantityInvoiced,
    this.resServiceStaffId,
    this.resLineOrderStatus,
    this.parentSellLineId,
    this.childrenType,
    this.subUnitId,
    this.createdAt,
    this.updatedAt,
    this.businessId,
    required this.name,
    this.type,
    this.unitId,
    this.secondaryUnitId,
    this.subUnitIds,
    this.brandId,
    this.categoryId,
    this.subCategoryId,
    this.tax,
    this.taxType,
    this.enableStock,
    this.alertQuantity,
    this.sku,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var product = json['product'] ?? {};
    return Product(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      variationId: json['variation_id'] ?? 0,
      quantity: json['quantity']?.toString() ?? '0',
      secondaryUnitQuantity: json['secondary_unit_quantity'] ?? '0.0000',
      quantityReturned: json['quantity_returned'] ?? '0.0000',
      unitPriceBeforeDiscount: json['unit_price_before_discount'] ?? '0.0000',
      price: json['unit_price'] ?? '0.0000',
      lineDiscountType: json['line_discount_type'] ?? 'fixed',
      lineDiscountAmount: json['line_discount_amount'] ?? '0.0000',
      unitPriceIncTax: json['unit_price_inc_tax'] ?? '0.0000',
      itemTax: json['item_tax'] ?? '0.0000',
      taxId: json['tax_id'],
      discountId: json['discount_id'],
      lotNoLineId: json['lot_no_line_id'],
      sellLineNote: json['sell_line_note'] ?? '',
      soLineId: json['so_line_id'],
      soQuantityInvoiced: json['so_quantity_invoiced'] ?? '0.0000',
      resServiceStaffId: json['res_service_staff_id'],
      resLineOrderStatus: json['res_line_order_status'],
      parentSellLineId: json['parent_sell_line_id'],
      childrenType: json['children_type'] ?? '',
      subUnitId: json['sub_unit_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      businessId: product['business_id'] ?? 0,
      name: product['name'] ?? 'Unknown Product',

      //
      type: product['type'] ?? 'Unknown Type',
      unitId: product['unit_id'] ?? 0,
      secondaryUnitId: product['secondary_unit_id'],
      subUnitIds: product['sub_unit_ids'],
      brandId: product['brand_id'],
      categoryId: product['category_id'],
      subCategoryId: product['sub_category_id'],
      tax: product['tax'],
      taxType: product['tax_type'] ?? 'exclusive',
      enableStock: product['enable_stock'] ?? 0,
      alertQuantity: product['alert_quantity'] ?? '0.0000',
      sku: product['sku'] ?? 'Unknown SKU',
    );
  }
}

class OrderTableModal {
  final int? id;
  final int? business_id;
  final int? location_id;
  final int? is_kitchen_order;
  final int? res_table_id;
  final int? res_waiter_id;
  final String? type;
  final String? status;
  final int? is_quotation;
  final String? payment_status;
  final int? contact_id;
  final String? invoice_no;
  final String? transaction_date;
  final String? total_before_tax;
  late int? tax_id;
  final String? tax_amount;
  final String? discount_type;
  final String? discount_amount;
  final int? rp_redeemed;
  final String? rp_redeemed_amount;
  final String? shipping_charges;
  final String? finalTotal;
  final int? is_suspend;
  final String? exchange_rate;
  final String? packing_charge;
  final String? packing_charge_type;

  final String? custom_field_1;
  final String? custom_field_2;
  final String? custom_field_3;
  final String? custom_field_4;
  final String? service_custom_field_1;
  final String? service_custom_field_2;
  final String? service_custom_field_3;
  final int? is_created_from_api;
  final int? rp_earned;
  final int? recur_interval;
  final int? recur_repetitions;
  final int? selling_price_group_id;
  final String? created_at;
  final String? updated_at;
  final String? recur_stopped_on;
  final String? recur_parent_id;
  final String? invoice_token;
  final String? pay_term_number;
  final String? pay_term_type;
  final String? typeOfService;
  final List<Product> products;
  final String? jsonData;
  final String? tableName;
  final String? staffName;
  final int? transactionId;
  final String? additionalNotes;
  OrderTableModal({
    this.id,
    this.business_id,
    this.location_id,
    this.is_kitchen_order,
    this.res_table_id,
    this.res_waiter_id,
    this.type,
    this.status,
    this.is_quotation,
    this.payment_status,
    this.contact_id,
    this.invoice_no,
    this.transaction_date,
    this.total_before_tax,
    this.tax_id,
    this.tax_amount,
    this.discount_type,
    this.discount_amount,
    this.rp_redeemed,
    this.rp_redeemed_amount,
    this.shipping_charges,
    this.finalTotal,
    this.is_suspend,
    this.exchange_rate,
    this.packing_charge,
    this.packing_charge_type,
    this.custom_field_1,
    this.custom_field_2,
    this.custom_field_3,
    this.custom_field_4,
    this.service_custom_field_1,
    this.service_custom_field_2,
    this.service_custom_field_3,
    this.is_created_from_api,
    this.rp_earned,
    this.recur_interval,
    this.recur_repetitions,
    this.selling_price_group_id,
    this.created_at,
    this.updated_at,
    this.recur_stopped_on,
    this.recur_parent_id,
    this.invoice_token,
    this.pay_term_number,
    this.pay_term_type,
    this.typeOfService,
    required this.products,
    this.tableName,
    this.staffName,
    this.jsonData,
    this.transactionId,
    this.additionalNotes,
  });

  factory OrderTableModal.fromJson(Map<String, dynamic> json) {
    var sellLines = json['sell_lines'] as List<dynamic>? ?? [];
    List<Product> products = sellLines
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderTableModal(
      id: json['id'] ?? 0,
      //transaction id nahi hai order id hai transaction id uper hai product wali class mai
      //if you want transaction id simple do this simple
      //transactionId: json['transaction_id'] ?? 0,
      transactionId: json['id'] ?? 0,
      business_id: json['business_id'] ?? 0,
      location_id: json['location_id'] ?? 0,
      is_kitchen_order: json['is_kitchen_order'] ?? 0,
      res_table_id: json['res_table_id'],
      tableName: json['table']?['name'] ?? 'X',
      res_waiter_id: json['res_waiter_id'],
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      is_quotation: json['is_quotation'] ?? 0,
      payment_status: json['payment_status'] ?? '',
      contact_id: json['contact_id'] ?? 0,
      invoice_no: json['invoice_no'] ?? '',
      transaction_date: json['transaction_date'] ?? '',
      total_before_tax: json['total_before_tax'] ?? '',
      tax_id: json['tax_id'] ?? 0,
      tax_amount: json['tax_amount'] ?? '',
      discount_type: json['discount_type'] ?? '',
      discount_amount: json['discount_amount'] ?? '',
      rp_redeemed: json['rp_redeemed'] ?? 0,
      rp_redeemed_amount: json['rp_redeemed_amount'] ?? '',
      shipping_charges: json['shipping_charges'] ?? '',
      finalTotal: json['final_total'] ?? '',
      is_suspend: json['is_suspend'] ?? 0,
      exchange_rate: json['exchange_rate'] ?? '',
      packing_charge: json['types_of_service']?['packing_charge'] ?? '',
      packing_charge_type: json['types_of_service']?['packing_charge_type'],

      service_custom_field_1: json['service_custom_field_1'],
      service_custom_field_2: json['service_custom_field_2'],
      service_custom_field_3: json['service_custom_field_3'],
      custom_field_1: json['custom_field_1'],
      custom_field_2: json['custom_field_2'],
      custom_field_3: json['custom_field_3'],
      custom_field_4: json['custom_field_4'],
      pay_term_number: json['pay_term_number'],
      pay_term_type: json['pay_term_type'],

      recur_stopped_on: json['recur_stopped_on'],
      recur_parent_id: json['recur_parent_id'],
      invoice_token: json['invoice_token'],
      selling_price_group_id: json['selling_price_group_id'],
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
      //
      is_created_from_api: json['is_created_from_api'],
      rp_earned: json['rp_earned'],
      recur_interval: json['recur_interval'],
      recur_repetitions: json['recur_repetitions'],

      //
      staffName: json['service_staff']?['first_name'] ?? 'Unknown Staff',
      typeOfService: json['types_of_service']?['name'] ?? 'Unknown',
      jsonData: jsonEncode(json),
      products: products,
    );
  }
}
