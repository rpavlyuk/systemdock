# Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "bento/fedora-latest"

  # Provider selection (VirtualBox or Parallels); Vagrant auto-picks if only one installed.
  config.vm.provider "virtualbox" do |vb|
    vb.name = "systemdock-dev"
    vb.memory = 4096
    vb.cpus = 2
  end
  config.vm.provider "parallels" do |prl|
    prl.name = "systemdock-dev"
    prl.memory = 4096
    prl.cpus = 2
  end

  # Networking (optional): forwarded SSH is enough; uncomment if you want a static private IP
  # config.vm.network "private_network", ip: "192.168.56.75"

  # Fast code sync: rsync. Use `make dev-sync` to push changes.
  config.vm.synced_folder ".", "/srv/systemdock",
  type: "rsync",
  owner: "vagrant", group: "vagrant",
  rsync__auto: true,
  rsync__args: ["--verbose", "--archive", "--delete", "-z"],
  rsync__ssh_args: ["-o", "ControlMaster=no"],   # <— key line
  rsync__exclude: [".git/", ".venv/", ".rpmbuild/", "__pycache__/"]

  # If plugin installed, stop it from messing with GA
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

  # Provision: install Docker, Python deps, create docker group, enable services
  config.vm.provision "shell", inline: <<'SH'
set -euxo pipefail

if command -v dnf >/dev/null 2>&1; then
  PKG="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG="yum"
else
  echo "Neither dnf nor yum found" >&2
  exit 1
fi

# Basic tooling
sudo $PKG -y install python3 python3-pip git make which rpm-build

# Docker engine
if ! command -v docker >/dev/null 2>&1; then
  # Fedora/RHEL family package name often 'docker' or 'moby-engine' depending on repos.
  # Try moby-engine first (Fedora), then docker.
  if sudo $PKG -y install moby-engine docker 2>/dev/null; then :; else
    sudo $PKG -y install moby-engine || sudo $PKG -y install docker
  fi
fi

# Enable & start Docker
sudo systemctl enable --now docker || true

# Add vagrant user to docker group
if getent group docker >/dev/null; then
  sudo usermod -aG docker vagrant
fi

# Python packages needed by SystemDock
sudo python3 -m pip install --upgrade pip setuptools wheel
sudo python3 -m pip install docker PyYAML

# Handy: ensure systemd is PID1 (most boxes already are)
systemctl is-system-running || true

echo "Provisioning done."
SH
end