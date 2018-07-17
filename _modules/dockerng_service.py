#!/usr/bin/python
# Copyright 2017 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


try:
    import docker
    HAS_DOCKER = True
except ImportError:
    HAS_DOCKER = False

__opts__ = {}
__virtualname__ = 'dockerng_service'


def __virtual__():
    '''
    Only load this module if docker library is installed.
    '''
    if HAS_DOCKER:
        return __virtualname__
    return (False, 'dockerio execution module not loaded: docker python library not available.')

def _docker_module():
    salt_version = __salt__['grains.get']('saltversioninfo', default=[2017,7,6])
    if salt_version < [2017,7]:
      return 'dockerng'
    else:
      return 'docker'

def status(container, service):
    cmd = "systemctl show " + service + " -p ActiveState,SubState,UnitFileState"
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    data = data.splitlines()
    result = dict(s.split('=') for s in data)
    return result


def status_retcode(container, service):
    cmd = "systemctl show " + service + " -p ActiveState,SubState,UnitFileState"
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    data = data.splitlines()
    result = dict(s.split('=') for s in data)
    if result['ActiveState'] == "active" and result['SubState'] == "running":
        return True
    return False


def restart(container, service):
    cmd = "systemctl restart " + service
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    if len(data) > 0:
        return False
    return True


def stop(container, service):
    cmd = "systemctl stop " + service
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    if len(data) > 0:
        return False
    return True


def start(container, service):
    cmd = "systemctl start " + service
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    if len(data) > 0:
        return False
    return True


def enable(container, service):
    cmd = "systemctl enable " + service
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    if len(data) > 0:
        return False
    return True


def reload(container, service):
    cmd = "systemctl reload " + service
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    if len(data) > 0:
        return False
    return True


def disable(container, service):
    cmd = "systemctl disable " + service
    data =  __salt__[_docker_module() + '.run'](container, cmd)
    if len(data) > 0:
        return False
    return True
