#!/usr/bin/python3
import json
import pipes
import sys

def main():
    config_json = json.load(open("/etc/mozart-fetcher/config.json", "r"))
    key_values = config_json["configuration"]
    noecho_key_values = config_json["secure_configuration"]
    production_environment = {"PRODUCTION_ENVIRONMENT": config_json["environment"]}

    f = open("/etc/systemd/system/mozart-fetcher.service.d/env.conf", "w")
    f.write("[Service]\n")
    for key, value in (list(key_values.items()) + list(production_environment.items())):
        f.write("Environment=%s=%s\n" % (key, pipes.quote(value)))
    f.close()
    return 0

if __name__ == "__main__":
    sys.exit(main())