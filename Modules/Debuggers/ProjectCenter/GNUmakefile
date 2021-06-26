#
# GNUmakefile - ProjectCenter.debugger
#
PACKAGE_NAME = ProjectCenter
include $(GNUSTEP_MAKEFILES)/common.make

#
# Bundle
#
BUNDLE_NAME = ProjectCenter
BUNDLE_EXTENSION = .debugger
ProjectCenter_PRINCIPAL_CLASS = PCDebugger

#
# Additional libraries
#
ProjectCenter_LIBRARIES_DEPEND_UPON +=

#
# Resource files
#
ProjectCenter_RESOURCE_FILES= \
    Resources/PCDebugger.gorm \
    Resources/Info.table \
    Resources/go_button.png \
    Resources/continue_button.png \
    Resources/pause_button.png \
    Resources/restart_button.png \
    Resources/next_button.png \
    Resources/stepin_button.png \
    Resources/stepout_button.png \
    Resources/up_button.png \
    Resources/down_button.png 

#
# Header files
#
ProjectCenter_HEADERS= \
PCDebugger.h \
PCDebuggerViewDelegateProtocol.h \
PCDebuggerView.h \
PCGDBMIAsyncInfoRecord.h \
PCGDBMIAsyncStatusRecord.h \
PCGDBMIConsoleStreamRecord.h \
PCGDBMIDebugStreamRecord.h \
PCGDBMIParser.h \
PCGDBMIPromptRecord.h \
PCGDBMIRecord.h \
PCGDBMITargetStreamRecord.h \
PipeDelegate.h

#
# Class files
#
ProjectCenter_OBJC_FILES= \
PCDebugger.m \
PCDebuggerView.m \
PCGDBMIAsyncInfoRecord.m \
PCGDBMIAsyncStatusRecord.m \
PCGDBMIConsoleStreamRecord.m \
PCGDBMIDebugStreamRecord.m \
PCGDBMIParser.m \
PCGDBMIPromptRecord.m \
PCGDBMIRecord.m \
PCGDBMITargetStreamRecord.m \
PipeDelegate.m

#ADDITIONAL_OBJC_LIBS=

include ../../GNUmakefile.bundles
include $(GNUSTEP_MAKEFILES)/bundle.make
