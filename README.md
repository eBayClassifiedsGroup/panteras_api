# PanterasApi

A convenient api for getting information from consul, mesos, marathon, and docker in the Panteras PaaS infrastructure.
ex

## Installation

    $ gem install panteras_api

## mesos_marathon_consistency_check (in Extras directory)

This is a program that checks services consistencies in a mesos/marathon/consul/docker PaaS infrastructure.

It is intended for use together with the [Panteras](https://github.com/eBayClassifiedsGroup/PanteraS) project.

**It will not work on other systems without tweaking the main program.**

	Usage: mesos_marathon_consistency_check [options]
    -m MESOS_MASTER_HOSTNAME,        Default: localhost
        --mesos-master-hostname
    -p MESOS_MASTER_PORT,            Default: 5050
        --mesos-master-port
    -d, --debug                      Default: false
    -f FULLY_QUALIFIED_HOSTNAME,     Default: autodiscovery via gethostbyname
        --fqdn

## Notes

* Exits with error code 1 when problems seen
* Exits with code 0 when everything is OK
* outputs a short text summary
* intended for use as a nagios-style check
* this script should be run on all mesos slaves (docker hosts)
