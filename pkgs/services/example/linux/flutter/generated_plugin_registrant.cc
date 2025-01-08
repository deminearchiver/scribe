//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <services/services_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) services_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ServicesPlugin");
  services_plugin_register_with_registrar(services_registrar);
}
