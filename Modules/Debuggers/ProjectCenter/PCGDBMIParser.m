/*
**  PCGDBMIParser.m
**
**  Copyright (c) 2020 Free Software Foundation
**
**  Author: Gregory Casamento <greg.casamento@gmail.com>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program; if not, write to the Free Software
**  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import <Foundation/NSScanner.h>
#import <Foundation/NSString.h>

#import "PCGDBMIParser.h"
#import "PCGDBMIRecord.h"

@implementation PCGDBMIParser

- (instancetype) initWithString: (NSString *)string
{
  self = [super init];
  if (self != nil)
    {
      [self setString: string];
    }
  return self;
}

- (instancetype) init
{
  return [self initWithString: nil];
}

- (void) setString: (NSString *)string
{
  ASSIGN(_string, string);
}

- (PCGDBMIRecord *) parse
{
  PCGDBMIRecord *record = [[PCGDBMIRecord alloc] initWithString: _string];
  [record parse];
  return record;
}

@end
