#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
  void (*require_ssid_list)(int64_t);
  void (*require_connect_wifi)(int64_t, const char*, const char*);
  void (*require_network_info)(int64_t, int32_t);
  void (*on_config_progress)(int64_t, int8_t, int8_t);
  void (*on_config_ok)(int64_t, const char*);
  void (*on_config_fail)(int64_t, int32_t, const char*);
  void (*free_callback)(int64_t);
  int64_t index;
} sky_config_contract_SkyConfigCallback_Model;

int32_t sky_config_contract_do_init(const char *uid,
                                    const char *ak,
                                    const char *app_key,
                                    const char *app_secret,
                                    sky_config_contract_SkyConfigCallback_Model config_callback);

int32_t sky_config_contract_do_release(void);

int32_t sky_config_contract_is_config(void);

int32_t sky_config_contract_is_init(void);

void sky_config_contract_on_network_change(int32_t is_connect, const char *ssid);

void sky_config_contract_on_ssid_list(const char *ssid_list);

int32_t sky_config_contract_start_config(const char *router_ssid,
                                         const char *router_password,
                                         const char *device_ap);

int32_t sky_config_contract_stop_config(void);

void skylink_free_rust(uint8_t *ptr, uint32_t length);

void skylink_free_str(char *ptr);
