## vpp log system introduce

### 1. vpp log

1. syslog

    pass msg to kernel syslog system

2. default logger

    default logger by used main core

3. event-log

    [event-log](https://s3-docs.fd.io/vpp/25.02/developer/corefeatures/eventviewer.html)

    Event log may implement pass msg from worker to main core.
    It consists of default, api, cli, barrier and dispatch sub-logger.

### 2. config

1. syslog and default log configure in configure file

    ```bash
    logging {
    default-log-level debug
    default-syslog-log-level debug
    class linux-cp/if { rate-limit 10000 level error syslog-level error }
    class linux-cp/nl { rate-limit 10000 level error syslog-level error }
    }
    ```
2. event log

    event log divides to code and cli.

    [a code implement](https://gerrit.fd.io/r/c/vpp/+/42083/2/src/plugins/af_packet/af_packet.c)

    ```bash
    # show event log [default logger]
    vppctl show event-logger

    # config trace sub-logger
    DBGvpp#   event-logger trace ?
    event-logger trace                       event-logger trace [api][cli][barrier][dispatch]
    [circuit-node <name> e.g. ethernet-input][disable]
    ```

    nat example
    ```bash
        vppctl nat44 plugin enable
        vppctl nat set logging level 5
        vppctl set interface nat44 in host-host1 out host-host2

        # nat event-log use default event-logger, you can use `show event-log` to capture msg when ocurs errors
    ```
