#ifndef FLUTTER_PLUGIN_SERVICES_PLUGIN_H_
#define FLUTTER_PLUGIN_SERVICES_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace services {

class ServicesPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ServicesPlugin();

  virtual ~ServicesPlugin();

  // Disallow copy and assign.
  ServicesPlugin(const ServicesPlugin&) = delete;
  ServicesPlugin& operator=(const ServicesPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace services

#endif  // FLUTTER_PLUGIN_SERVICES_PLUGIN_H_
