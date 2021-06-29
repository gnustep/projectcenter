/* Implementation of class PCGDBMIAsyncInfoRecord
   Copyright (C) 2021 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: 26-06-2021

   This file is part of GNUstep.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#import <Foundation/NSScanner.h>

#import "NSScanner+Extensions.h"
#import "PCGDBMIAsyncInfoRecord.h"
#import "PCGDBMIKeyValueParser.h"

@implementation PCGDBMIAsyncInfoRecord

- (id) parse
{
  NSString *event;

  [_scanner scanUpToString: @"," intoString: &event];
  [_scanner scanString: @"," intoString: NULL];
  
  PCGDBMIKeyValueParser *p = [[PCGDBMIKeyValueParser alloc] initWithString: [_scanner remainingString]];
  return [p parse];
}

@end

