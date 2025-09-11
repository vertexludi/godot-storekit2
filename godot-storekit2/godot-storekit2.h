#pragma once

#include "core/object/ref_counted.h"

#include "core/string/ustring.h"
#include "core/variant/dictionary.h"

class GodotStoreKit2 : public RefCounted {
	GDCLASS(GodotStoreKit2, RefCounted)

	bool initialized = false;

	static void _bind_methods();

public:
	void initialize();
	bool is_initialized() const;
	bool is_product_available(String p_product_id);
	bool is_product_purchased(String p_product_id);
	Dictionary get_product_price(String p_product_id);
	void purchase_product(String p_product_id, int p_quantity = 1);
	void restore_purchases();
};
