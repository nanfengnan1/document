## vpp unittest tutorials

### 1. introduce

The goal of the VPP Test Framework is to ease writing, running and debugging unit tests for the VPP. For this, python was chosen as a high level language allowing rapid development with scapy providing the necessary tool for creating and dissecting packets.

### 2. write unittest

It implemnts the most of unittest function for vpp by using vnet/pg.

```bash
# compile and run a unittest case
make test TEST=test_dns

# unittest debugging for [release和debug]
# release
make test-start-vpp-in-gdb DEBUG=core TEST=test_dns
make test DEBUG=attach TEST=test_dns

# debug
make test-start-vpp-debug-in-gdb DEBUG=core TEST=test_dns
make test DEBUG=attach TEST=test_dns

# more details, please refer to `make test-help`
```

### 3. reference

[offical introduce](https://s3-docs.fd.io/vpp/25.02/developer/tests/overview.html)