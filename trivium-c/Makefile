SUBDIRS			= examples
TARGET			= subdirs
PHONY			+= $(TARGET) $(SUBDIRS) %.clean

all: $(TARGET)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

%.clean:
	@(cd $(patsubst %.clean, %, $@) && $(MAKE) clean)

clean distclean: $(patsubst %, %.clean, $(SUBDIRS))

.PHONY: $(PHONY) install clean distclean