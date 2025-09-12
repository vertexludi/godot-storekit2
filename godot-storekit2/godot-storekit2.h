#pragma once

#include "core/object/ref_counted.h"

#include "core/string/ustring.h"
#include "core/variant/dictionary.h"

@class GodotStoreKit2Proxy;
@class TransactionData;
@class InitializationData;

class GodotStoreKit2 : public RefCounted {
	GDCLASS(GodotStoreKit2, RefCounted)

	GodotStoreKit2Proxy *proxy;

	static void _bind_methods();

	void _on_transaction_state_changed(TransactionData *data);
	void _on_initialization_state_changed(InitializationData *data);

public:
	enum TransactionState {
		FAILED,
		REFUNDED,
		PURCHASING,
		DEFERRED,
		PURCHASED,
		RESTORED,
	};


	void initialize();
	bool is_initialized() const;
	bool is_product_available(String p_product_id);
	bool is_product_purchased(String p_product_id);
	Dictionary get_product_price(String p_product_id);
	void purchase_product(String p_product_id, int p_quantity = 1);
	void restore_purchases();
	GodotStoreKit2();
	~GodotStoreKit2();
};

VARIANT_ENUM_CAST(GodotStoreKit2::TransactionState)
