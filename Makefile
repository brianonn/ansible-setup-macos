
RAMDISKSIZE = 1024  # in MB
RAMDISK := $(shell echo '$(RAMDISKSIZE) * 2048' | bc)
MOUNT := RAMDisk

DEVICE := $(shell hdiutil attach -nomount ram://$(RAMDISK) )
VOLUME := $(shell diskutil erasevolume HFS+ $(MOUNT) $(DEVICE) )

VAULTFILE := group_vars/all/crypted.yml

DOWNLOADDIR = /Volumes/$(MOUNT)/downloads

.PHONY: sudo init install clean cleanup

all:  sudo init install cleanup

$(VAULTFILE):
	@ $(RM) $(VAULTFILE)
	@ echo 'Creating the encrypted vault.' && \
	echo 'We will need the local sudo password for storage in the vault.' && \
	read -s -p '   Sudo Password: ' password && echo && \
	read -s -p '   Confirm Sudo Password: ' password2 && echo && \
	if test "$$password" -ne "$$password2" ; then echo "Passwords don't match"; exit 1 ; fi && \
	ansible-vault encrypt_string "$$password" --name 'ansible_become_pass' > $(VAULTFILE)

sudo: $(VAULTFILE)

init:
	ansible-playbook -e download_dir=$(DOWNLOADDIR) playbooks/init.yml

install:
	ansible-playbook -e download_dir=$(DOWNLOADDIR) playbooks/install.yml

clean: cleanup
cleanup:
	ansible-playbook -e download_dir=$(DOWNLOADDIR) playbooks/cleanup.yml
	hdiutil detach /Volumes/$(MOUNT)
	$(RM) $(VAULTFILE)
