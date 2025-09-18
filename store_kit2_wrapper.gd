extends RefCounted
class_name GDScriptStoreKit2

# Unavoidable here, ignore in all cases.
@warning_ignore_start("unsafe_method_access", "unsafe_property_access", "inferred_declaration")


var _store_kit: RefCounted


enum TransactionState {
	FAILED,
	REFUNDED,
	PENDING,
	DEFERRED,
	PURCHASED,
	RESTORED,
	EXPIRED,
	CANCELED,
}


signal transaction_state_changed(transaction: TransactionData)
signal product_info_received(product_info: ProductInfo)
signal synchronized


func _init() -> void:
	if not ClassDB.class_exists("GodotStoreKit2"):
		return
	_store_kit = ClassDB.instantiate("GodotStoreKit2")

	_store_kit.transaction_state_changed.connect(func(transaction: Dictionary) -> void:
		var data := TransactionData.new()
		data.error = transaction.error
		if data.error.is_empty():
			data.product_id = transaction.product_id
			data.transaction_state = transaction.transaction_state

		transaction_state_changed.emit(data)
	)

	_store_kit.product_info_received.connect(func(product_info: Dictionary) -> void:
		var info := ProductInfo.new()
		info.error = product_info.error
		if info.error.is_empty():
			info.product_id = product_info.product_id
			info.display_name = product_info.display_name
			info.description = product_info.description
			info.is_purchased = product_info.is_purchased
			info.currency_value = product_info.currency_value
			info.currency_code = product_info.currency_code
			info.currency_symbol = product_info.currency_symbol
			info.localized_price = product_info.localized_price
		product_info_received.emit(info)
	)

	_store_kit.synchronized.connect(func() -> void: synchronized.emit())


func request_product_info(product_id: String) -> Signal:
	if not _store_kit:
		return product_info_received
	return _store_kit.request_product_info(product_id)


func purchase_product(product_id: String, quantity: int = 1) -> Signal:
	if not _store_kit:
		return transaction_state_changed
	return _store_kit.purchase_product(product_id, quantity)


func sync() -> Signal:
	if not _store_kit:
		return synchronized
	return _store_kit.transaction_state_changed


class ProductInfo:
	var error: String
	var product_id: String
	var display_name: String
	var description: String
	var is_purchased: bool = false
	var currency_value: float = 0.0
	var currency_code: String
	var currency_symbol: String
	var localized_price: String

	func _to_string() -> String:
		var props := {}

		for prop in get_property_list():
			if (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
				continue
			props[prop.name] = self[prop.name]

		return str(props)


class TransactionData:
	var error: String
	var product_id: String
	var transaction_state: TransactionState = TransactionState.FAILED

	func _to_string() -> String:
		var props := {}

		for prop in get_property_list():
			if (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
				continue
			props[prop.name] = self[prop.name]

		return str(props)
