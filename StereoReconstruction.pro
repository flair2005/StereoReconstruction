#---------------------------------------------------------------------
#
# Copyright © 2011, Jason Gedge <gedge -at- ualberta -dot- ca>
#
# This file is part of StereoReconstruction.
#
# StereoReconstruction is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# StereoReconstruction is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with StereoReconstruction. If not, see <http:www.gnu.org/licenses/>.
#
#---------------------------------------------------------------------
# StereoReconstruction Project File
#---------------------------------------------------------------------
#
# This library uses C++0x functionality that exists in GCC 4.5 and Visual
# Studio 2010 (or later versions). The following dependencies are required
# when building StereoRecontruction:
#
#   - Qt 4.7.3 SDK
#   - OpenCV 2.2
#   - gsl 1.14
#   - Boost 1.46
#   - Eigen 2.x
#   - GLEW 1.5.8
#
# Additionally, some options (see "Tunable Options" below) will require
# additional libraries:
#
#   - OpenEXR 1.6.1 (when hdr option enabled)
#   - Intel TBB 3.0 (when tbb option enabled)
#   - Point Grey Research FlyCap 2.x SDK (when pgr option enabled)
#   - Point Grey Research Digiclops SDK (when pgr option enabled)
#   - Point Grey Research Triclops SDK (when pgr option enabled)
#   - Middlebury MRF library (when mrf option enabled)
#
# The recommended environment for building StereoReconstruction is
# Qt Creator 2.x.
#
#---------------------------------------------------------------------
# Tunable Options
#---------------------------------------------------------------------
#
# User-specific configuration options should be placed in a file named
# `UserConfig.pri` in the same directory as the project file. Various
# options that can be added to the CONFIG variable:
#
#   - hdr: Enables HDR imaging options
#
#   - tbb: Use Intel Thread Building Blocks library for parallel
#       computation whenever possible.
#
#   - openmp: Use OpenMP for parallel computation whenever possible.
#       If tbb is specified then OpenMP is ignored.
#
#   - mrf: Use MRF optimization for stereo, with the TRW-S method. If
#       not enabled, winner-take-all is used.
#
#   - splats: Use splats when rendering point clouds. If not enabled,
#       basic point rendering is used.
#
#   - pgr: Link against and use the PointGrey FlyCap SDK for image
#       capturing functionality.
#
# Also, be sure to specify any non-standard library/include paths in
# your user config file. To see which libraries are included for each
# of the above options, browse down through this file.
#
#---------------------------------------------------------------------
QT += opengl xml xmlpatterns
TEMPLATE = app
TARGET = StereoReconstruction
DESTDIR = dist
MAIN_CPP =

exists(UserConfig.pri):include(UserConfig.pri)

#---------------------------------------------------------------------
isEmpty(MAIN_CPP):MAIN_CPP = main.cpp

SOURCES += $${MAIN_CPP} \
	gui/*.cpp \
	gui/dialogs/*.cpp \
	gui/scene/*.cpp \
	gui/widgets/*.cpp \
	gui/gvitems/*.cpp \
	project/*.cpp \
	features/*.cpp \
	hdr/*.c* \
	stereo/*.cpp \
	util/*.cpp \
	util/rawimages/*.cpp

HEADERS += gui/*.h* \
	gui/dialogs/*.hpp \
	gui/scene/*.hpp \
	gui/widgets/*.hpp \
	gui/gvitems/*.hpp \
	project/*.hpp \
	features/*.hpp \
	hdr/*.h* \
	stereo/*.hpp \
	util/*.hpp \
	util/rawimages/*.hpp

FORMS += gui/forms/*.ui

OTHER_FILES += shaders/*.* project/project.xsd GPL_HEADER LICENSE

RESOURCES += resources.qrc
INCLUDEPATH += .

#---------------------------------------------------------------------
CONFIG(debug, debug|release) { 
    DEFINES += DEBUG _DEBUG
    BUILD_PREFIX = debug
    TARGET = $${TARGET}_debug
} else {
    DEFINES += NDEBUG _NDEBUG
    BUILD_PREFIX = release
}

OBJECTS_DIR = build/$$BUILD_PREFIX/objects
MOC_DIR = build/$$BUILD_PREFIX/moc
UI_DIR = build/$$BUILD_PREFIX/ui
RCC_DIR = build/$$BUILD_PREFIX/resources

#---------------------------------------------------------------------
win32 { 
    DEFINES += PLATFORM_WIN
	LIBS += -lglew32
}
else:macx { 
    DEFINES += PLATFORM_MAC
    LIBS += -lGLEW
}

#---------------------------------------------------------------------
LIBS += -lopencv_core -lopencv_highgui -lopencv_legacy \
        -lopencv_imgproc -lopencv_features2d -lopencv_calib3d \
        -lopencv_contrib

LIBS += -lgsl

#---------------------------------------------------------------------
mrf {
	LIBS += -lMRF
	DEFINES += USE_MRF
}

#---------------------------------------------------------------------
sba {
	DEFINES += USE_SBA
	LIBS += -lsba
}

#---------------------------------------------------------------------
hdr { 
    LIBS += -llapack
    LIBS += -lIlmImf -lHalf # OpenEXR
	LIBS += -lboost_system-mt -lboost_filesystem-mt
    DEFINES += HAS_HDR
}

#---------------------------------------------------------------------
splats {
	DEFINES += USE_SPLATS
}

#---------------------------------------------------------------------
tbb {
	DEFINES += USE_TBB
	LIBS += -ltbb -ltbbmalloc
} else:openmp {
    QMAKE_CXXFLAGS += -fopenmp
    QMAKE_LFLAGS += -fopenmp
	!msvc:LIBS += -lgomp
    DEFINES += USE_OPENMP
}

#---------------------------------------------------------------------
pgr { 
    DEFINES += USING_PGR
    DEFINES += HAS_IMAGE_CAPTURE
    SOURCES += gui/capture_impl/*.cpp
    LIBS += -lFlyCapture2 -ldigiclops -ltriclops
}

#---------------------------------------------------------------------
