FLAGS = -g -A../../InterfaceORB $(IMPORT_LIBRARY_FLAGS)

all:: $(CORBA_LIB_DEPEND) $(ADABROKER_LIB_DEPEND) sema.ads
	gnatmake -I.. -gnatf -gnata -m -i client.adb $(FLAGS)
	gnatmake -I.. -gnatf -gnata -m -i server.adb $(FLAGS)

IDL_INTERFACE = sema

GENERATED_FILES = $(IDL_INTERFACE).ad*
GENERATED_FILES += $(IDL_INTERFACE)-proxy.ad*
GENERATED_FILES += $(IDL_INTERFACE)-stream.ad*
GENERATED_FILES += $(IDL_INTERFACE)-skel.ad*
GENERATED_FILES += $(IDL_INTERFACE)_idl_file.ad*
GENERATED_FILES += $(IDL_INTERFACE)_idl_file-stream.ad*

clean::
	-rm -f *.o *.ali *~ server client b_*.c $(GENERATED_FILES)

sema.ads: sema.idl
	omniidl2 -bada sema.idl

ada::
	omniidl2 -bada sema.idl
