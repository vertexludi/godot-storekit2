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

public:
	// Keep in sync with Swiftenum.
	enum TransactionState {
		FAILED,
		REFUNDED,
		PENDING,
		DEFERRED,
		PURCHASED,
		RESTORED,
		EXPIRED,
		CANCELED,
	};

	bool is_product_available(String p_product_id);
	bool is_product_purchased(String p_product_id);
	Signal request_product_info(String p_product_id);
	Signal request_product_price(String p_product_id);
	Signal purchase_product(String p_product_id, int p_quantity = 1);
	Signal sync();
	GodotStoreKit2();
};

VARIANT_ENUM_CAST(GodotStoreKit2::TransactionState)
