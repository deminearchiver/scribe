#include "include/services/services_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "services_plugin.h"

void ServicesPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  services::ServicesPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
