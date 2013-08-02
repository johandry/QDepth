VERSION_NUMBER := 1.0

include configure/configure.mk

# Java tools
JAVA       := $(JAVA_HOME)/bin/java
JAVAC      := $(JAVA_HOME)/bin/javac
JFLAGS     := -sourcepath $(SOURCE_DIR) \
              -d $(OUTPUT_DIR) \
              -source 1.4

JVMFLAGS   := -ea \
              -esa \
              -Xfuture

JVM        := $(JAVA) $(JVMFLAGS)
JAVADOC    := $(JAVA_HOME)/bin/javadoc
JDFLAGS    := -sourcepath $(SOURCE_DIR) \
              -d $(OUTPUT_DIR) \
              -link http://java.sun.com/products/jdk/1.4/docs/api

# Jars

MQ_JAR           := $(MQ_HOME)/lib/com.ibm.mq.jar
MQ_JMS_JAR       := $(MQ_HOME)/lib/com.ibm.mqjms.jar
MQ_CONNECTOR_JAR := $(MQ_HOME)/lib/connector.jar
MQ_JMQI_JAR      := $(MQ_HOME)/lib/com.ibm.mq.jmqi.jar

# Set the Java classpath
class_path       := OUTPUT_DIR \
                    MQ_JAR \
                    MQ_JMS_JAR \
                    MQ_CONNECTOR_JAR \
                    MQ_JMQI_JAR

# space - A blank space
space := $(empty) $(empty)

# $(call build-classpath, variable-list)
define build-classpath
  $(strip \
    $(patsubst :%,%, \
      $(subst : ,:, \
        $(strip \
          $(foreach j,$1,$(call get-file,$j):)))))
endef

# $(call get-file, variable-name)
define get-file
  $(strip \
    $($1) \
      $(if $(call file-exists-eval,$1),, \
      $(warning The file referenced by variable \
                 '$1' ($($1)) cannot be found)))
endef

# $(call file-exists-eval, variable-name)
define file-exists-eval
  $(strip \
    $(if $($1),,$(warning '$1' has no value)) \
    $(wildcard $($1)))
endef

# $(call brief-help, makefile)
define brief-help
  $(AWK) '$$1 ~ /^[^.][-A-Za-z0-9]*:/ \
         { print substr($$1, 1, length($$1)-1) }' $1 | \
  sort | \
  pr -w 80 -4
#  pr -T -w 80 -4
endef

# $(call file-exists, wildcard-pattern)
file-exists = $(wildcard $1)

# $(call check-file, file-list)
define check-file
  $(foreach f, $1,
    $(if $(call file-exists, $($f)),, \
      $(warning $f ($($f)) is missing)))
endef

# Set the CLASSPATH
export CLASSPATH := $(call build-classpath, $(class_path))

# make-directories - Ensure output directory exists.
make-directories := $(shell $(MKDIR) $(OUTPUT_DIR))

# help - The default goal
.PHONY: help
help:
	@$(call brief-help, $(CURDIR)/Makefile)

# all - Perform all tasks for a complete build
.PHONY: all
all: compile javadoc

# all_javas - Temp file for holding source file list
all_javas := $(OUTPUT_DIR)/all.javas

# compile - Compile the source
.PHONY: compile
compile: $(all_javas)
	$(JAVAC) $(JFLAGS) @$<

# all_javas - Gather source file list
.INTERMEDIATE: $(all_javas)
$(all_javas):
	$(FIND) $(SOURCE_DIR) -name '*.java' > $@

# javadoc - Generate the Java doc from sources
.PHONY: javadoc
javadoc: $(all_javas)
	$(JAVADOC) $(JDFLAGS) @$<

.PHONY: clean
clean:
	$(RM) $(OUTPUT_DIR)

.PHONY: classpath
classpath:
	@echo CLASSPATH='$(CLASSPATH)'

.PHONY: check-config
check-config:
	@echo Checking configuration...
	$(call check-file, $(class_path) JAVA_HOME)

.PHONY: print
print:
	$(foreach v, $(V), \
	$(warning $v = $($v)))

.PHONY: install
install: 
	[ -e $(INSTALL_DIR) ] || $(MKDIR) $(INSTALL_DIR)
	cp bin/* $(INSTALL_DIR)
	@echo "Add this line to the cron:"
	@echo "*/5 * * * * $(INSTALL_DIR)/autorestart.sh >> $(INSTALL_DIR)/crontab.log 2>&1"

#================================================================

# JFLAGS = -g -d ../bin/ -cp $(CLASSPATH)
# 
# VPATH = src
# 
# .SUFFIXES: .java .class
# 
# .java.class:
# 	cd src; $(JAVAC) $(JFLAGS) $*.java
# 
# CLASSES = \
# 	QDepth.java
# 
# .PHONY: default
# default: classes 
# 
# .PHONY: classes
# classes: $(CLASSES:.java=.class)
# 
# .PHONY: clean
# clean:
# 	$(RM) bin/*.class
# 
# .PHONY: test
# test: classes
# 	./bin/QDepth.sh