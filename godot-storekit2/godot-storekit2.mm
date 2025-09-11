#include "godot-storekit2.h"

#include "core/object/class_db.h"

@import Foundation;

void GodotStoreKit2::_bind_methods() {
	ClassDB::bind_method(D_METHOD("hello_world"), &GodotStoreKit2::hello_world);
}

void GodotStoreKit2::hello_world() {
	print_line("Hello world!");
}
