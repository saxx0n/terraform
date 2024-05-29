#!/usr/bin/env python3

import argparse
import json
import requests
import sys

from requests.auth import HTTPBasicAuth
from time import sleep


DEBUG = False


def call_api(server, username, password, data=None, timeout=30) -> json:
    headers = {'Content-Type': 'application/json'}
    auth = HTTPBasicAuth(username, password)

    debug(f"Remote URL: {server}")

    try:
        # If data is provided, make a POST request. Otherwise, make a GET request.
        if data:
            debug('Running Post', 2)
            if data == 'no_limits':
                r = requests.post(server, headers=headers, auth=auth, timeout=timeout)
            else:
                r = requests.post(server, data=json.dumps(data), headers=headers, auth=auth, timeout=timeout)
        else:
            debug('Running Get', 2)
            r = requests.get(server, auth=auth, timeout=timeout)

        # Check if the HTTP request was successful (response code 200)
        r.raise_for_status()

    except requests.RequestException as e:
        print(str(e))
        exit(2)

    debug(f"API returned, {r.json()}", 3)
    return r.json()  # Return JSON data.


def debug(msg='', debug_msg_level=1, out=sys.stdout):
    if DEBUG and debug_msg_level <= debug_level:
        if msg != '':
            if debug_level > 1:
                out.write(f"DEBUG[{debug_msg_level}]: {msg}")
            else:
                out.write(f"DEBUG: {msg}")
        out.write('\n')


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--debug_level', type=int, choices=[1, 2, 3], help='Set debug level (enabled debugging)')
    parser.add_argument('-u', '--username', type=str, required=True, help='Username for AAP')
    parser.add_argument('-p', '--password', type=str, required=True, help='Password for AAP')
    parser.add_argument('-s', '--server', type=str, required=True, help='AAP server to run against')
    parser.add_argument('-j', '--job_name', type=str, required=False, default='Run Communication Test',
                        help='AAP Job to run')
    parser.add_argument('-t', '--test_host', type=str, required=False, default='dns-node2',
                        help='Host to run playbook against')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()

    if args.debug_level:
        DEBUG = True
        debug_level = args.debug_level
        debug(f"Set debug level to: {debug_level}")

    remote_url = f"https://{args.server}/api/v2/job_templates/{args.job_name.replace(' ', '%20')}"

    template = call_api(remote_url, args.username, args.password)
    debug(f"Template: {template['id']}")

    remote_url = f"https://{args.server}/api/v2/job_templates/{template['id']}/launch/"

    if args.test_host != "none":
        test_job = call_api(remote_url, args.username, args.password, data={'limit': args.test_host})
    else:
        test_job = call_api(remote_url, args.username, args.password, data='no_limits')
    debug(f"Job ID: {test_job['id']}")

    status = 'running'

    while status != 'successful':
        debug('Sleeping for 5 seconds')
        sleep(5)
        remote_url = f"https://{args.server}/api/v2/jobs/{test_job['id']}"
        job_out = call_api(remote_url, args.username, args.password)
        status = job_out['status']
        debug(f"Status: {status}")
        if status in ['canceled', 'failed']:
            print('Job did not finish successfully!')
            exit(1)

    print('Job Completed!')
    exit(0)
