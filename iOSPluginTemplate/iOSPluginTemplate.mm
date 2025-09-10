#include "iOSPluginTemplate.h"

#include "core/object/class_db.h"

@import Foundation;

void iOSPluginTemplate::_bind_methods() {
	ClassDB::bind_method(D_METHOD("hello_world"), &iOSPluginTemplate::hello_world);
}

void iOSPluginTemplate::hello_world() {
	print_line("Hello world!");
}
