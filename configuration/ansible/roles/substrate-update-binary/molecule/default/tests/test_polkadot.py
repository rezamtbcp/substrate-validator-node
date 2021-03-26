def test_substrate_user(host):
    user = host.user('substrate')
    assert user.exists

    group = host.group('substrate')
    assert group.exists

    assert user.gid == group.gid


def test_substrate_binary(host):
    binary = host.file('/usr/local/bin/substrate')
    assert binary.exists
    assert binary.user == 'substrate'
    assert binary.group == 'substrate'
    assert binary.mode == 0o755


def test_substrate_service_file(host):
    if host.ansible.get_variables()['inventory_hostname'] == 'validator':
        svc = host.file('/etc/systemd/system/substrate.service')
        assert svc.exists


def test_substrate_running_and_enabled(host):
    if host.ansible.get_variables()['inventory_hostname'] == 'validator':
        substrate = host.service("substrate.service")
        assert substrate.is_running
