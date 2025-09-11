#pragma once

#include "core/object/ref_counted.h"

class GodotStoreKit2 : public RefCounted {
	GDCLASS(GodotStoreKit2, RefCounted)

	static void _bind_methods();

public:
	void hello_world();
};
