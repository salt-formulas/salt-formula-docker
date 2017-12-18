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
'''
Management of Contrail resources
================================

:depends:   - vnc_api Python module


Enforce the service in container is started
-------------------------------------------

.. code-block:: yaml

    contrail_control_started:
      dockerng_service.start:
        - container: f020d0d3efa8
        - service: contrail-control

or

.. code-block:: yaml

    contrail_control_started:
      dockerng_service.start:
        - container: contrail_controller
        - service: contrail-control


Enforce the service in container is stoped
------------------------------------------

.. code-block:: yaml

    contrail_control_stoped:
      dockerng_service.stop:
        - container: f020d0d3efa8
        - service: contrail-control

Enforce the service in container will be restarted
--------------------------------------------------

.. code-block:: yaml

    contrail_control_restart:
      dockerng_service.restart:
        - container: f020d0d3efa8
        - service: contrail-control

Enforce the service in container is enabled
-------------------------------------------

.. code-block:: yaml

    contrail_control_enable:
      dockerng_service.enable:
        - container: f020d0d3efa8
        - service: contrail-control

Enforce the service in container is disabled
--------------------------------------------

.. code-block:: yaml

    contrail_control_disable:
      dockerng_service.disable:
        - container: f020d0d3efa8
        - service: contrail-control

'''


def __virtual__():
    '''
    Load Contrail module
    '''
    return 'dockerng_service'


def start(container, service, **kwargs):
    '''
    Ensures that the service in the container is started.

    :param container:    ID or name of the container
    :param service:      Service name
    '''
    ret = {'name': service + " in " + container,
           'changes': {},
           'result': True,
           'comment': ''}

    status = __salt__['dockerng_service.status'](container, service)

    if status['ActiveState'] == "inactive" and status['SubState'] == "dead":
        if __opts__['test']:
            ret['result'] = None
            ret['comment'] = service + " in  " + container + " will be started"
            return ret

        res = __salt__['dockerng_service.start'](container, service)
        ret['comment'] = service + " in  " + container + " has been started"
        ret['changes'] = {"old": "stoped", "new": "started"}
        return ret

    return ret


def stop(container, service, **kwargs):
    '''
    Ensures that the service in the container is stoped

    :param container:    ID or name of the container
    :param service:      Service name
    '''
    ret = {'name': service + " in " + container,
           'changes': {},
           'result': True,
           'comment': ''}

    status = __salt__['dockerng_service.status'](container, service)

    if status['ActiveState'] != "inactive" and status['SubState'] != "dead":
        if __opts__['test']:
            ret['result'] = None
            ret['comment'] = service + " in  " + container + " will be stoped"
            return ret

        res = __salt__['dockerng_service.stop'](container, service)
        ret['comment'] = service + " in  " + container + " has been stoped"
        ret['changes'] = {"new": "stoped", "old": "started"}
        return ret

    return ret


def restart(container, service, **kwargs):
    '''
    Service in the container will be restarted

    :param container:    ID or name of the container
    :param service:      Service name
    '''
    ret = {'name': service + " in " + container,
           'changes': {},
           'result': True,
           'comment': ''}


    if __opts__['test']:
        ret['result'] = None
        ret['comment'] = service + " in  " + container + " will be restarted"
        return ret

    res = __salt__['dockerng_service.restart'](container, service)
    ret['comment'] = service + " in  " + container + " has been stoped"
    ret['changes'] = {"status": "restarted"}
    return ret


def enable(container, service, **kwargs):
    '''
    Ensures that the service in the container is enabled

    :param container:    ID or name of the container
    :param service:      Service name
    '''
    ret = {'name': service + " in " + container,
           'changes': {},
           'result': True,
           'comment': ''}

    status = __salt__['dockerng_service.status'](container, service)

    if status['UnitFileState'] != "enabled":
        if __opts__['test']:
            ret['result'] = None
            ret['comment'] = service + " in  " + container + " will be enabled"
            return ret

        res = __salt__['dockerng_service.enable'](container, service)
        ret['comment'] = service + " in  " + container + " has been enabled"
        ret['changes'] = {"new": "enabled", "old": "disabled"}
        return ret

    return ret


def disable(container, service, **kwargs):
    '''
    Ensures that the service in the container is disabled

    :param container:    ID or name of the container
    :param service:      Service name
    '''
    ret = {'name': service + " in " + container,
           'changes': {},
           'result': True,
           'comment': ''}

    status = __salt__['dockerng_service.status'](container, service)

    if status['UnitFileState'] != "disabled":
        if __opts__['test']:
            ret['result'] = None
            ret['comment'] = service + " in  " + container + " will be disabled"
            return ret

        res = __salt__['dockerng_service.disable'](container, service)
        ret['comment'] = service + " in  " + container + " has been disabled"
        ret['changes'] = {"old": "enabled", "new": "disabled"}
        return ret

    return ret
