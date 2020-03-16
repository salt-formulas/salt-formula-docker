#!/usr/bin/env python

import os
import yaml
import json
import subprocess


def main():
    output = {}

    if os.path.exists('/var/lib/docker/swarm'):
        try:
            inspect = json.loads(
                subprocess.check_output(
                    ["docker", "node", "inspect", "self"],
                    stderr=subprocess.STDOUT,
                ).decode("utf-8").strip()
            )[0]
        except subprocess.CalledProcessError:
            return None

        output['docker_swarm_role'] = inspect["Spec"]["Role"]
        try:
            output['docker_swarm_leader'] = inspect["ManagerStatus"]["Leader"]
        except KeyError:
            pass

        if output['docker_swarm_role'] == 'manager':
            output["docker_swarm_tokens"] = {
                'worker': (
                    subprocess.check_output(
                        ["docker", "swarm", "join-token", "-q", "worker"],
                    ).decode("utf-8").strip()
                ),
                'manager': subprocess.check_output(
                    ["docker", "swarm", "join-token", "-q", "manager"],
                ).decode("utf-8").strip()
            }

        if os.path.exists('/var/lib/docker/swarm/state.json'):
            with open('/var/lib/docker/swarm/state.json') as fh:
                state = yaml.load(fh)
                for key, value in state[0].items():
                    output["docker_swarm_%s" % key] = value

        if os.path.exists('/var/lib/docker/swarm/docker-state.json'):
            with open('/var/lib/docker/swarm/docker-state.json') as fh:
                state = yaml.load(fh)
                for key, value in state.items():
                    output["docker_swarm_%s" % key] = value

    if output:
        return output
    else:
        return None
