#CXX = g++
#RM = rm
#AR = ar
LN = ln
INSTALL = install
MKDIR = mkdir
CP = cp
FMT = clang-format

DIR_BUILD = .build
DIR_INCLUDES = include
prefix = /usr/local

PPFLAGS = -MT $@ -MMD -MP -MF $(patsubst %.o, %.d, $@) -I$(DIR_INCLUDES)

CFLAGS_LOCAL = -Wall -g -std=c++11 -coverage
CFLAGS_LOCAL += $(CFLAGS)

VALGRIND = valgrind --leak-check=full --show-leak-kinds=all

APP_SOURCES = sample.cc
APP_OBJECTS = $(patsubst %.cc, %.o, $(APP_SOURCES))
APP = test

LIB_INCLUDES = include/lib/test1.h
LIB_SOURCES = private/test.cc \
        private/test1.cc
LIB_OBJECTS = $(patsubst %.cc, %.o, $(LIB_SOURCES))
LIB_VERSION = 0.0.1
LIB_NAME = test
LIB_SO = lib$(LIB_NAME).so.$(LIB_VERSION)
LIB_A = lib$(LIB_NAME).a.$(LIB_VERSION)

DEPFILES = $(patsubst %.o, %.d, $(addprefix $(DIR_BUILD)/, $(APP_OBJECTS)) $(addprefix $(DIR_BUILD)/, $(LIB_OBJECTS)))

.PHONY : all clean install uninstall test fmt

all : $(DIR_BUILD)/$(APP)

$(DIR_BUILD)/$(APP) : $(addprefix $(DIR_BUILD)/, $(APP_OBJECTS)) $(DIR_BUILD)/$(LIB_SO) $(DIR_BUILD)/$(LIB_A) Makefile | $(DIR_BUILD)
	$(CXX) $(CFLAGS_LOCAL) -o $@ ${addprefix $(DIR_BUILD)/, $(APP_OBJECTS)} -L$(shell pwd)/$(DIR_BUILD) -l$(LIB_NAME)

$(DIR_BUILD)/lib$(LIB_NAME).so : $(DIR_BUILD)/$(LIB_SO)
	$(LN) -sf $(shell pwd)/$< $@

$(DIR_BUILD)/$(LIB_SO) : $(addprefix $(DIR_BUILD)/, $(LIB_OBJECTS)) Makefile | $(DIR_BUILD)
	$(CXX) $(CFLAGS_LOCAL) -shared -o $@ $(filter %.o, $^)

$(DIR_BUILD)/lib$(LIB_NAME).a : $(DIR_BUILD)/$(LIB_A)
	$(LN) -sf $(shell pwd)/$< $@

$(DIR_BUILD)/$(LIB_A) : $(addprefix $(DIR_BUILD)/, $(LIB_OBJECTS)) Makefile | $(DIR_BUILD)
	$(AR) $(ARFLAGS) $@ $(filter %.o, $^)

$(addprefix $(DIR_BUILD)/, $(APP_OBJECTS)) : $(DIR_BUILD)/%.o : %.cc Makefile | $(DIR_BUILD)
	$(MKDIR) -p $(@D)
	$(CXX) $(PPFLAGS) $(CFLAGS_LOCAL) -c $< -o $@

$(addprefix $(DIR_BUILD)/, $(LIB_OBJECTS)) : $(DIR_BUILD)/%.o : %.cc Makefile | $(DIR_BUILD)
	$(MKDIR) -p $(@D)
	$(CXX) $(PPFLAGS) $(CFLAGS_LOCAL) -fPIC -c $< -o $@

$(DIR_BUILD)/%.d : ;
.PRECIOUS : $(DIR_BUILD)/%.d

$(DIR_BUILD) : 
	$(MKDIR) -p $@

install : all
	$(INSTALL) -d "$(prefix)/lib"
	$(INSTALL) "$(DIR_BUILD)/$(LIB_SO)" "$(prefix)/lib"
	$(LN) -sf "$(prefix)/lib/$(LIB_SO)" "$(prefix)/lib/lib$(LIB_NAME).so"
	$(INSTALL) "$(DIR_BUILD)/$(LIB_A)" "$(prefix)/lib"
	$(LN) -sf "$(prefix)/lib/$(LIB_A)" "$(prefix)/lib/lib$(LIB_NAME).a"
	$(INSTALL) -d "$(prefix)/bin"
	$(INSTALL) "$(DIR_BUILD)/$(APP)" "$(prefix)/bin"
	$(INSTALL) -d "$(prefix)/include"
	$(CP) -r $(DIR_INCLUDES)/* "$(prefix)/include/"

uninstall :
	$(RM) -f  "$(prefix)/lib/$(LIB_SO)"
	$(RM) -f  "$(prefix)/lib/lib$(LIB_NAME).so"
	$(RM) -f  "$(prefix)/lib/$(LIB_A)"
	$(RM) -f  "$(prefix)/lib/lib$(LIB_NAME).a"
	$(RM) -f  "$(prefix)/bin/$(APP)"
	$(RM) -rf "$(prefix)/include/$(LIB_NAME)"

test :
	$(VALGRIND) $(APP)

clean :
	$(RM) -rf $(DIR_BUILD)

fmt :
	$(FMT) -i --style=file $$(find . -type f \( -name '*.c' -o -name '*.h' \))

include $(DEPFILES)
