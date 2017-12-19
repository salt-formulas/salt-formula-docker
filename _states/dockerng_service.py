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


Enforce the service in container is running
-------------------------------------------

.. code-block:: yaml

    contrail_control_running:
      dockerng_service.running:
        - container: f020d0d3efa8
        - service: contrail-control

or

.. code-block:: yaml

    contrail_control_running:
      dockerng_service.running:
        - container: contrail_controller
        - service: contrail-control


Enforce the service in container is dead
------------------------------------------

.. code-block:: yaml

    contrail_control_dead:
      dockerng_service.dead:
        - container: f020d0d3efa8
        - service: contrail-control

Enforce the service in container will be restarted
--------------------------------------------------

.. code-block:: yaml

    contrail_control_restarted:
      dockerng_service.restarted:
        - container: f020d0d3efa8
        - service: contrail-control

Enforce the service in container is enabled
-------------------------------------------

.. code-block:: yaml

    contrail_control_enabled:
      dockerng_service.enabled:
        - container: f020d0d3efa8
        - service: contrail-control

Enforce the service in container is disabled
--------------------------------------------

.. code-block:: yaml

    contrail_control_disabled:
      dockerng_service.disabled:
        - container: f020d0d3efa8
        - service: contrail-control

'''


def __virtual__():
    '''
    Load Contrail module
    '''
    return 'dockerng_service'


def running(container, service=None, services=None, **kwargs):
    '''
    Ensures that the service in the container is running

    :param container:    ID or name of the container
    :param services:     List of services
    :param service:      Service name
    '''
    ret = {'name': kwargs.get('name', 'dockerng_service.running'),
           'changes': {},
           'result': True,
           'comment': {}
           }

    if service and not services:
        services = [service, ]

    for service in services:
        status = __salt__['dockerng_service.status'](container, service)

        if status['ActiveState'] != "active" and status['SubState'] != "running":
            if __opts__['test']:
                ret['result'] = None
                ret['comment'][service] = " will be started"
            else:
                __salt__['dockerng_service.start'](container, service)
                ret['comment'] = service + " in  " + container + " has been started"
                ret['changes'] = {service:  "started"}

    return ret


def dead(container, service, **kwargs):
    '''
    Ensures that the service in the container is dead

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

        __salt__['dockerng_service.stop'](container, service)
        ret['comment'] = service + " in  " + container + " has been stoped"
        ret['changes'] = {"new": "stoped", "old": "started"}
        return ret

    return ret


def restarted(container, service, **kwargs):
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
    ret['comment'] = service + " in  " + container + " has been restarted"
    ret['changes'] = {"status": "restarted"}
    return ret


def enabled(container, service, **kwargs):
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

        __salt__['dockerng_service.enable'](container, service)
        ret['comment'] = service + " in  " + container + " has been enabled"
        ret['changes'] = {"new": "enabled", "old": "disabled"}
        return ret

    return ret


def disabled(container, service, **kwargs):
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

        __salt__['dockerng_service.disable'](container, service)
        ret['comment'] = service + " in  " + container + " has been disabled"
        ret['changes'] = {"old": "enabled", "new": "disabled"}
        return ret

    return ret


def mod_watch(name,
              contrainer=None,
              sfun=None,
              sig=None,
              reload=False,
              full_restart=False,
              init_delay=None,
              force=False,
              **kwargs):
    '''
    The service watcher, called to invoke the watch command.

    :param name:         The name of the init or rc script used to manage the
                         service
    :param sfun:         The original function which triggered the mod_watch
                         call (`service.running`, for example).
    :param sig:          The string to search for when looking for the service
                         process with ps
    :param reload:       Use reload instead of the default restart (exclusive
                         option with full_restart, defaults to reload if both
                         are used)
    :param full_restart: Use service.full_restart instead of restart
                         (exclusive option with reload)
    :param force:        Use service.force_reload instead of reload
                         (needs reload to be set to True)
    :param  init_delay:  Add a sleep command (in seconds) before the service is
                         restarted/reloaded
    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': {}}

    service = kwargs.get('service')
    services = kwargs.get('services')
    if not services and service:
        services = [service, ]
    elif not services and not service:
        ret['result'] = False
        ret['comment'] = "Service was not defined"
        return ret

    container = kwargs.get('container', None)
    if not container:
        ret['result'] = False
        ret['comment'] = "Container was not defined"
        return ret

    ret['comment'] = {}
    if sfun == 'running':

        for service in services:
            status = __salt__['dockerng_service.status'](container, service)


            if __opts__['test']:
                ret['result'] = None
                ret['comment'][service] = "Services will be restarted"
                ret['changes'][service] = "will be restarted"
            else:
                res = __salt__['dockerng_service.restart'](container, service)
                ret['comment'] = "Services has been restarted"
                ret['changes'][service] = "restarted"
    else:
        ret['comment'] = 'Unable to trigger watch for dockerng_service.{0}'.format(sfun)
        ret['result'] = False
    return ret
