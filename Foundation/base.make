#
#   base.make
#
#   Makefile flags and configs to build with the base library.
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
#   Based on code originally in the gnustep make package
#
#   This file is part of the GNUstep Base Library.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

ifeq ($(BASE_MAKE_LOADED),)
  BASE_MAKE_LOADED=yes

  ifeq ($(FOUNDATION_LIB),gnu)
    #
    # FIXME - macro names
    #
    AUXILIARY_OBJCFLAGS += 
    ifeq ($(shared),no)
      CONFIG_SYSTEM_LIBS +=    -lc -lz
      CONFIG_SYSTEM_LIB_DIR +=  -L/usr/local/lib -L/usr/local/lib -L/usr/local/lib -L/usr/local/lib/gnu-gnu-gnu -L/usr/local/lib
    endif

    GNUSTEP_BASE_VERSION = 1.24.5
    GNUSTEP_BASE_MAJOR_VERSION = 1
    GNUSTEP_BASE_MINOR_VERSION = 24
    GNUSTEP_BASE_SUBMINOR_VERSION = 5

    FND_LDFLAGS =
    FND_LIBS = -lgnustep-base
    FND_DEFINE = -DGNUSTEP_BASE_LIBRARY=1
    GNUSTEP_DEFINE = -DGNUSTEP
  else
    #
    # Not using the GNUstep foundation ... must be Apple's
    # So we need to use the base additions library.
    #
    FND_LIBS = -lgnustep-baseadd -framework Foundation
  endif

  # Is the ObjC2 runtime real or emulated?
  # If it's not real, we need to use the emulation ObjectiveC2 headers.
  OBJC2RUNTIME=0
  ifeq ($(OBJC2RUNTIME),0)
    AUXILIARY_OBJCFLAGS += -I$(GNUSTEP_HEADERS)/ObjectiveC2
    AUXILIARY_CFLAGS += -I$(GNUSTEP_HEADERS)/ObjectiveC2
  endif

  # For literal string handling, base requires the compiler to store the
  # string as UTF-8
  AUXILIARY_OBJCFLAGS += 


  # Now we have definitions to show whether important dependencies have
  # been met ... if thse are 0 then some core functi0nailyt is missing.

  # Has GNUTLS been found (for TLS/SSL support throughout)?
  GNUSTEP_BASE_HAVE_GNUTLS=0

  # Has libxml2 been found (for NSXMLNode and related classes)?
  GNUSTEP_BASE_HAVE_LIBXML=0

  # Has ICU been found (for NSCalendar, NSLocale, and other locale related)?
  GNUSTEP_BASE_HAVE_ICU=0


  # The next two are a special case ... we should have either one defined
  # for netservices.  FIXME ... shouldn't these be combined?

  # Has MDNS been found (one of two options for NSNetServices)?
  GNUSTEP_BASE_HAVE_MDNS=0

  # Has Avahi been found (one of two options for NSNetServices)?
  GNUSTEP_BASE_HAVE_AVAHI=0

  # If we determined that the Objective-C runtime does not support
  # native Objective-C exceptions, turn them off.  This overrides
  # the USE_OBJC_EXCEPTIONS setting in gnustep-make's config.make.
  ifeq (0, 0)
    USE_OBJC_EXCEPTIONS = no
  endif

endif # BASE_MAKE_LOADED
