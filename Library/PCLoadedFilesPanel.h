/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2003 Free Software Foundation

   Author: Serg Stoyan <stoyan@on.com.ua>

   This file is part of GNUstep.

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#ifndef _PCLoadedFilesPanel_h
#define _PCLoadedFilesPanel_h

#include <AppKit/AppKit.h>

@class PCProjectManager;

@interface PCLoadedFilesPanel : NSPanel
{
  PCProjectManager *projectManager;
  NSBox            *contentBox;
  NSBox            *emptyBox;
}

- (id)initWithProjectManager:(PCProjectManager *)aManager;

@end

#endif
