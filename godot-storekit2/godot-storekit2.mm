#include "godot-storekit2.h"

#include "core/object/class_db.h"

@import Foundation;

void GodotStoreKit2::_bind_methods() {
	ClassDB::bind_method(D_METHOD("initialize"), &GodotStoreKit2::initialize);
	ClassDB::bind_method(D_METHOD("is_initialized"), &GodotStoreKit2::is_initialized);
	ClassDB::bind_method(D_METHOD("is_product_available", "product_id"), &GodotStoreKit2::is_product_available);
	ClassDB::bind_method(D_METHOD("is_product_purchased", "product_id"), &GodotStoreKit2::is_product_purchased);
	ClassDB::bind_method(D_METHOD("get_product_price", "product_id"), &GodotStoreKit2::get_product_price);
	ClassDB::bind_method(D_METHOD("purchase_product", "product_id", "quantity"), &GodotStoreKit2::purchase_product, DEFVAL(1));

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "initialized"), "", "is_initialized");

}

void GodotStoreKit2::initialize() {
	initialized = true;
}

bool GodotStoreKit2::is_initialized() const {
	return initialized;
}

bool GodotStoreKit2::is_product_available(String p_product_id) {
	return false;
}

bool GodotStoreKit2::is_product_purchased(String p_product_id) {
	return false;
}

Dictionary GodotStoreKit2::get_product_price(String p_product_id) {
	Dictionary result;

	return result;
}

void GodotStoreKit2::purchase_product(String p_product_id, int p_quantity) {}

void GodotStoreKit2::restore_purchases() {}

