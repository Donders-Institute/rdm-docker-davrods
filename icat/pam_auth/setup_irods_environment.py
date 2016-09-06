#!/usr/bin/env python

import json
import os
import shutil

if __name__ == "__main__":

    # backup the original irods_environment.json file
    os.rename('/var/lib/irods/.irods/irods_environment.json', '/var/lib/irods/.irods/irods_environment.json.org')
    
    # load the JSON object from the original irods_environment.json
    f = open('/var/lib/irods/.irods/irods_environment.json.org', 'r')
    c = json.load(f)
    f.close()

    # modify the JSON object and dump it as a new irods_environment.json file
    c['irods_ssl_certificate_chain_file'] = os.environ['IRODS_SSL_CERT_CHAIN']
    c['irods_ssl_certificate_key_file'] = os.environ['IRODS_SSL_CERT_KEY']
    c['irods_ssl_dh_params_file'] = os.environ['IRODS_SSL_DH_PARAMS']
    c['irods_host'] = 'localhost'

    f = open('/var/lib/irods/.irods/irods_environment.json','w')
    json.dump(c, f, indent=4, sort_keys=True)
    f.close()
