/* Implementation of class PCGDBMIKeyValueParser
   Copyright (C) 2021 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: 28-06-2021

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
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSScanner.h>

#import "NSScanner+Extensions.h"
#import "PCGDBMIArrayParser.h"
#import "PCGDBMIDictionaryParser.h"
#import "PCGDBMIKeyValueParser.h"
#import "PCGDBMIRecord.h"

@implementation PCGDBMIKeyValueParser

- (id) parse
{
  NSString *key = nil;
  
  [_scanner scanUpToString: @"=" intoString: &key];
  [_scanner scanString: @"=" intoString: NULL]; // consume equals to get past it...

  BOOL flag = NO;

  // Parse a dictionary...
  flag = [_scanner scanString: @"{" intoString: NULL];
  if (flag == YES)
    {
      NSString *r = [_scanner remainingString];
      NSString *s = [r substringToIndex: [r length] - 1]; // get rid of the closing brace
      PCGDBMIRecord *p = [[PCGDBMIDictionaryParser alloc] initWithString: s];
      NSDictionary *dict = [p parse];

      return dict;
    }

  // Parse a string literal...  this is the base case of this recursive parser...
  flag = [_scanner scanString: @"\"" intoString: NULL];
  if (flag == YES)
    {
      NSUInteger loc = [_scanner scanLocation];
      NSString *s = nil;
      
      [_scanner setScanLocation: loc - 1]; // reset to previous character...
      [_scanner scanStringLiteralIntoString: &s];
      return s;
    }
  
  // Parse an array...
  flag = [_scanner scanString: @"[" intoString: NULL];
  if (flag == YES)
    {
      NSString *r = [_scanner remainingString];
      NSString *s = [r substringToIndex: [r length] - 1];
      PCGDBMIRecord *p = [[PCGDBMIArrayParser alloc] initWithString: s];
      NSArray *a = [p parse];

      return a;
    }
  
  return nil;
}

@end
