#include "godot-storekit2.h"

#include "core/object/class_db.h"

#import "godot_storekit2-Swift.h"

@import StoreKit;

static NSString *fromGodotString(const String &src) {
	return [NSString stringWithUTF8String:src.utf8().get_data()];
}

static String toGodotString(NSString *src) {
	return String(src.UTF8String);
}

void GodotStoreKit2::_bind_methods() {
	ClassDB::bind_method(D_METHOD("initialize"), &GodotStoreKit2::initialize);
	ClassDB::bind_method(D_METHOD("is_initialized"), &GodotStoreKit2::is_initialized);
	ClassDB::bind_method(D_METHOD("is_product_available", "product_id"), &GodotStoreKit2::is_product_available);
	ClassDB::bind_method(D_METHOD("is_product_purchased", "product_id"), &GodotStoreKit2::is_product_purchased);
	ClassDB::bind_method(D_METHOD("request_product_price", "product_id"), &GodotStoreKit2::request_product_price);
	ClassDB::bind_method(D_METHOD("request_product_info", "product_id"), &GodotStoreKit2::request_product_info);
	ClassDB::bind_method(D_METHOD("purchase_product", "product_id", "quantity"), &GodotStoreKit2::purchase_product, DEFVAL(1));
	ClassDB::bind_method(D_METHOD("restore_purchases"), &GodotStoreKit2::restore_purchases);

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "initialized"), "", "is_initialized");

	ADD_SIGNAL(MethodInfo("initialization_state_changed", PropertyInfo(Variant::DICTIONARY, "result")));
	ADD_SIGNAL(MethodInfo("transaction_state_changed", PropertyInfo(Variant::DICTIONARY, "transaction")));
	ADD_SIGNAL(MethodInfo("product_price_received", PropertyInfo(Variant::DICTIONARY, "price")));
	ADD_SIGNAL(MethodInfo("product_info_received", PropertyInfo(Variant::DICTIONARY, "info")));
	ADD_SIGNAL(MethodInfo("purchases_restored", PropertyInfo(Variant::STRING, "error")));

	BIND_ENUM_CONSTANT(FAILED);
	BIND_ENUM_CONSTANT(REFUNDED);
	BIND_ENUM_CONSTANT(PENDING);
	BIND_ENUM_CONSTANT(DEFERRED);
	BIND_ENUM_CONSTANT(PURCHASED);
	BIND_ENUM_CONSTANT(RESTORED);
	BIND_ENUM_CONSTANT(EXPIRED);
	BIND_ENUM_CONSTANT(CANCELED);
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

Signal GodotStoreKit2::request_product_info(String p_product_id) {
	[proxy getProductInfoWithProductId:fromGodotString(p_product_id) completionHandler:^(ProductInfo *info, NSError *error) {
		Dictionary result;
		if (error) {
			result["error"] = toGodotString(error.userInfo[NSLocalizedDescriptionKey]);
		} else {
			result["error"] = String();
			result["product_id"] = toGodotString(info.productId);
			result["display_name"] = toGodotString(info.displayName);
			result["description"] = toGodotString(info.productDescription);
			result["is_purchased"] = info.isPurchased;
			PriceInfo *priceInfo = info.priceInfo;
			result["currency_value"] = priceInfo.currencyValue;
			result["currency_code"] =  toGodotString(priceInfo.currencyCode);
			result["currency_symbol"] = toGodotString(priceInfo.currencySymbol);
			result["localized_display"] = toGodotString(priceInfo.localizedDisplay);
		}

		call_deferred("emit_signal", "product_info_received", result);
	}];

	return Signal(this, "product_info_received");
}

void GodotStoreKit2::request_product_price(String p_product_id) {
	[proxy getProductPriceWithProductId:fromGodotString(p_product_id) completionHandler:^(PriceInfo *info, NSError *error) {
		Dictionary result;
		if (error) {
			result["error"] = toGodotString(error.userInfo[NSLocalizedDescriptionKey]);
		} else {
			result["error"] = String();
			result["currency_value"] = info.currencyValue;
			result["currency_code"] =  toGodotString(info.currencyCode);
			result["currency_symbol"] = toGodotString(info.currencySymbol);
			result["localized_display"] = toGodotString(info.localizedDisplay);
		}

		call_deferred("emit_signal", "product_price_received", result);
	}];
}

void GodotStoreKit2::purchase_product(String p_product_id, int p_quantity) {;
	[proxy purchaseProductWithProductId:fromGodotString(p_product_id) quantity:p_quantity completionHandler:^(TransactionData *data, NSError *error) {
		Dictionary result;
		if (error) {
			result["error"] = toGodotString(error.userInfo[NSLocalizedDescriptionKey]);
		} else{
			result["error"] = toGodotString(data.error);
			result["product_id"] = toGodotString(data.productId);
			result["transaction_state"] = (TransactionState)data.transactionState;
		}

		call_deferred("emit_signal", "transaction_state_changed", result);
	}];
}

void GodotStoreKit2::restore_purchases() {
	[proxy restorePurchasesWithCompletionHandler:^(NSError *error) {
		String result;
		if (error) {
			result = toGodotString(error.localizedDescription);
		}

		call_deferred("emit_signal", "purchases_restored", result);
	}];
}

GodotStoreKit2::GodotStoreKit2() {
	proxy = [[GodotStoreKit2Proxy alloc] initWithTransactionCallback:^(TransactionData *data) {
		_on_transaction_state_changed(data);
	}];
}

void GodotStoreKit2::_on_transaction_state_changed(TransactionData *data) {
	Dictionary result;
	result["error"] = toGodotString(data.error);
	result["product_id"] = toGodotString(data.productId);
	result["transaction_state"] = (TransactionState)data.transactionState;

	call_deferred("emit_signal", "transaction_state_changed", result);
}
