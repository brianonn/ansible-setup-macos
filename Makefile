
RAMDISKSIZE = 1024  # in MB
RAMDISK := $(shell echo '$(RAMDISKSIZE) * 2048' | bc) 
MOUNT := RAMDisk

DEVICE := $(shell hdiutil attach -nomount ram://$(RAMDISK) )
VOLUME := $(shell diskutil erasevolume HFS+ $(MOUNT) $(DEVICE) )

DOWNLOADDIR = /Volumes/$(MOUNT)/downloads

.PHONY: init install clean cleanup 

all:  init install cleanup 

init:
	ansible-playbook -e download_dir=$(DOWNLOADDIR) playbooks/init.yml

install: 
	ansible-playbook -e download_dir=$(DOWNLOADDIR) playbooks/install.yml

clean: cleanup
cleanup:
	ansible-playbook -e download_dir=$(DOWNLOADDIR) playbooks/cleanup.yml
	hdiutil detach /Volumes/$(MOUNT)
