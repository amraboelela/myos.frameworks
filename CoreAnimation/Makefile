#
# Copyright © 2014-2015 myOS Group.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# Contributor(s):
# Amr Aboelela <amraboelela@gmail.com>
#

LDLIBS=-lCoreFoundation -lFoundation

ifeq ($(TARGET),NativeApp)
    LIB_NAME=NACoreAnimation
    LDLIBS+=-lEGL -lNAIOKit -lNAOpenGLES -lNACoreGraphics -lNACoreText
else
    LIB_NAME=CoreAnimation
    LDLIBS+=-lIOKit -lOpenGLES -lCoreGraphics -lCoreText
endif

ifeq ($(BASE_OS),android)
    ifeq ($(TARGET),NativeApp)
        LDLIBS+=-lGLESv1_CM
    endif
endif

OBJECTS = \
    CAAnimation.o \
    CAGradientLayer.o \
    CAReplicatorLayer.o \
    CATiledLayer.o \
    CAValueFunction.o \
    CALayer.o \
    CALayer-CFunctions.o \
    CALayer+PresentationLayer.o \
    CARenderLayer.o \
    CALayerObserver.o \
    CAScrollLayer.o \
    CATransaction.o \
    CARenderer.o \
    CADisplayLink.o \
    CAMediaTiming.o \
    CAShapeLayer.o \
    CATransform3D.o \
    CAEAGLLayer.o \
    CAMediaTimingFunction.o \
    CATextLayer.o \
    CATransformLayer.o \
    CABackingStore.o \
    CAAnimator.o \
    CATransactionGroup.o \
    CACompositor.o \
    CAGeometry.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
