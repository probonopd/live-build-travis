#!/bin/sh

# https://www.bustawin.com/create-a-custom-live-debian-9-the-pro-way/#Speed-up_the_building_optional
# https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html

set -e

which lb >/dev/null 2>&1 || ( sudo apt-get update && sudo apt-get install -y live-build)

# Build documentation PDF
# man -t lb config | ps2pdf - lb_config.pdf
# man -t live-build | ps2pdf - live-build.pdf

# Note that you cannot crossbuild for another architecture
# if your host system is not able to execute binaries
# for the target architecture natively. For example, building amd64
# images on i386 and vice versa is possile if you have a 64bit
# capable i386 processor and the right kernel. But building powerpc
# images on an i386 system is not possible.

# Desperate try
# Workaround for:
# E: Release signed by unknown key (key id DCC9EFBF77E11517)
# wget https://ftp-master.debian.org/keys/release-10.asc -qO- | gpg --import # DOES NOT WORK!
# https://serverfault.com/a/975274
# sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/debian-archive-buster-automatic.gpg --keyserver keyserver.ubuntu.com --recv 648ACFD622F3D138
# sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/debian-archive-buster-stable.gpg --keyserver keyserver.ubuntu.com --recv DCC9EFBF77E11517
# DOES NOT WORK EITHER:
# gpg: WARNING: unsafe ownership on configuration file `/home/travis/.gnupg/gpg.conf'
# gpg: keyring `/home/travis/.gnupg/secring.gpg' created
# gpg: keyring `/etc/apt/trusted.gpg.d/debian-archive-buster-automatic.gpg' created
# gpg: external program calls are disabled due to unsafe options file permissions
# gpg: keyserver communications error: general error
# Just let me do with without gpg altogether! After all, I am downloading the keys from "random" keyservers,
# build on a "random" Travis CI machine which probably "random" Intel CPUs... it's all pseudo "security" anyway
# not worth the hassle. Correct me if I'm wong.
# For now, using stretch which doesn't seem to have this issue.

lb config noauto \
    --mode debian \
    --architectures amd64 \
    --distribution stretch \
    −−ignore−system−defaults \
    --debian-installer false \
    --archive-areas "main contrib non-free" \
    --apt-indices false \
    --memtest none \
    −−apt−recommends false \
    −−bootloader grub \
    −−bootstrap−flavour minimal \
    −−debconf−frontend noninteractive \
    −−debconf−nowarnings true \
    −−debian−installer false \
    −−distribution CODENAME \
    −−system live \
    −−source false \
    −−source−images iso \
    −−firmware−chroot true \
    −−verbose
    
# −−source true|false
# defines if a corresponding source image to the binary image
# should be build. By default this is false
# because most people do not require this and would require
#  to download quite a few source packages.
# However, once you start distributing your live image,
# you should make sure you build it with a source
# image alongside.


# The folder config/includes.chroot contains the file structure
# of the new ISO. If you create a folder called opt inside,
# it will be the /opt folder inside the ISO.
#
# The default user of the image is called user.
# The image automatically performs login with this user after booting.
# The home directory of the user  is config/includes.chroot/home/user,
# which translates to just /home/user in the live-cd.

find config/includes.chroot

# debian-live executes script files inside config/hooks/live in
# different moments of the building process. We call them hooks.
# Use them to execute code that modifies the ISO while it is being built.
# See https://www.bustawin.com/create-a-custom-live-debian-9-the-pro-way/
# and https://github.com/eReuse/workbench-live
# for examples.

find config/hooks

# Use package-lists to install packages inside the live-cd. 

cat > config/package-lists/my.list.chroot <<\EOF
live-boot
live-config
EOF

cat config/package-lists/my.list.chroot

# Build the image

lb config
sudo lb clean
sudo lb build

ls -lh
