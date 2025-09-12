#include "godot-storekit2.h"

#include "core/object/class_db.h"

#import "godot_storekit2-Swift.h"

static NSString *fromGodotString(const String &src) {
	return [NSString stringWithUTF8String:src.utf8().get_data()];
}

static String toGodotString(NSString *src) {
	return String([src cStringUsingEncoding:NSUTF8StringEncoding]);
}

void GodotStoreKit2::_bind_methods() {
	ClassDB::bind_method(D_METHOD("initialize"), &GodotStoreKit2::initialize);
	ClassDB::bind_method(D_METHOD("is_initialized"), &GodotStoreKit2::is_initialized);
	ClassDB::bind_method(D_METHOD("is_product_available", "product_id"), &GodotStoreKit2::is_product_available);
	ClassDB::bind_method(D_METHOD("is_product_purchased", "product_id"), &GodotStoreKit2::is_product_purchased);
	ClassDB::bind_method(D_METHOD("get_product_price", "product_id"), &GodotStoreKit2::get_product_price);
	ClassDB::bind_method(D_METHOD("purchase_product", "product_id", "quantity"), &GodotStoreKit2::purchase_product, DEFVAL(1));

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "initialized"), "", "is_initialized");

	ADD_SIGNAL(MethodInfo("initialization_state_changed", PropertyInfo(Variant::DICTIONARY, "result")));
	ADD_SIGNAL(MethodInfo("transaction_state_changed", PropertyInfo(Variant::DICTIONARY, "transaction")));

	BIND_ENUM_CONSTANT(FAILED);
	BIND_ENUM_CONSTANT(REFUNDED);
	BIND_ENUM_CONSTANT(PURCHASING);
	BIND_ENUM_CONSTANT(DEFERRED);
	BIND_ENUM_CONSTANT(PURCHASED);
	BIND_ENUM_CONSTANT(RESTORED);
}

void GodotStoreKit2::initialize() {
	[proxy initialize];
}

bool GodotStoreKit2::is_initialized() const {
	return [proxy isInitialized];
}

bool GodotStoreKit2::is_product_available(String p_product_id) {
	return [proxy isProductAvailableWithProductId:fromGodotString(p_product_id)];
}

bool GodotStoreKit2::is_product_purchased(String p_product_id) {
	return [proxy isProductPurchasedWithProductId:fromGodotString(p_product_id)];
}

Dictionary GodotStoreKit2::get_product_price(String p_product_id) {
	PriceInfo *info = [proxy getProductPricesWithProductId:fromGodotString(p_product_id)];
	Dictionary result;
	result["currency_value"] = info.currencyValue;
	result["currency_code"] =  toGodotString(info.currencyCode);
	result["currency_symbol"] = toGodotString(info.currencySymbol);
	result["localized_displa"] = toGodotString(info.localizedDisplay);
	return result;
}

void GodotStoreKit2::purchase_product(String p_product_id, int p_quantity) {;
	[proxy purchaseProductWithProductId:fromGodotString(p_product_id) quantity:p_quantity callback:^(TransactionData*)
	 {
		print_line("callback called");
	}];
}

void GodotStoreKit2::restore_purchases() {}

GodotStoreKit2::GodotStoreKit2() {
	proxy = [[GodotStoreKit2Proxy alloc] init];
}

GodotStoreKit2::~GodotStoreKit2() {
}
