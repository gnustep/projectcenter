/* Implementation of class PCGDBMIRecord
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

#import <Foundation/NSString.h>
#import <Foundation/NSScanner.h>

#import "PCGDBMIRecord.h"

@implementation PCGDBMIRecord

- (instancetype) initWithString: (NSString *)string
{
  self = [super init];
  if (self != nil)
    {
      [self setString: [self cleanupString: string]];
      _scanner = [[NSScanner alloc] initWithString: _string];
    }
  return self;
}

- (instancetype) init
{
  return [self initWithString: nil];
}

- (void) dealloc
{
  RELEASE(_string);
  RELEASE(_scanner);
  [super dealloc];
}

- (NSString *) cleanupString: (NSString *)aString
{
  NSString *str = [aString stringByReplacingOccurrencesOfString: @"\\\""
						     withString: @"\""];
  return str;
}

- (void) setString: (NSString *)string
{
  ASSIGN(_string, string);
}

- (BOOL) lookAheadExpecting: (NSString *)expectString
{
  return [_scanner scanString: expectString intoString: NULL];
}

- (id) parse
{
  NSArray *classes = GSObjCAllSubclassesOfClass([self class]);
  NSEnumerator *en = [classes objectEnumerator];
  Class cls = nil;

  while ((cls = [en nextObject]) != nil)
    {
      PCGDBMIRecord *parser = AUTORELEASE([[cls alloc]
					    initWithString: _string]);
      if ([parser canParse])
	{
	  return [parser parse];
	}
    }
  
  return nil;
}

- (BOOL) canParse
{
  return NO;
}

@end
