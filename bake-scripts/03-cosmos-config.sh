#! /usr/bin/env python
import json
import pipes
import sys

def main(argv):
    config_json = json.load(open(argv[1], "r"))
    key_values = config_json["configuration"]
    noecho_key_values = config_json["secure_configuration"]

    f = open("/etc/systemd/system/mozart-fetcher.service.d/env.conf", "w")
    f.write("[Service]\n")
    for key, value in key_values.items():
        f.write("Environment=%s=%s\n" % (key, pipes.quote(value)))
    f.close()
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))