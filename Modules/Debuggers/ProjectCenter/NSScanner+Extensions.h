/* NSScanner+Extensions.h
 *
 * Copyright (C) 1999 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	1999, 2002
 *
 * This file is part of GNUstep.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


#include <Foundation/Foundation.h>

#ifndef INCLUDED_NSScanner_Extensions_h
#define INCLUDED_NSScanner_Extensions_h

@class NSString, NSCharacterSet;

@interface NSScanner (Extensions)
- (BOOL) scanStringLiteralIntoString: (NSString **)buffer;

- (void) scanUpToAndIncludingString: (NSString *)string 
                         intoString: (NSString **)buffer;

- (void) scanUpToAndIncludingCharactersFromSet: (NSCharacterSet *)set 
                                    intoString: (NSString **)buffer;
@end

#endif
