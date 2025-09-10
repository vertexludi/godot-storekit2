#pragma once

#include "core/object/ref_counted.h"

class iOSPluginTemplate : public RefCounted {
	GDCLASS(iOSPluginTemplate, RefCounted)

	static void _bind_methods();

public:
	void hello_world();
};
