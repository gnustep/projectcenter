/*
   GNUstep ProjectCenter - http://www.gnustep.org/experience/ProjectCenter.html

   Copyright (C) 2002-2004 Free Software Foundation

   Authors: Philippe C.D. Robert
            Serg Stoyan

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

#import <ProjectCenter/PCDefines.h>
#import <ProjectCenter/PCProjectManager.h>
#import <ProjectCenter/PCProject.h>
#import <ProjectCenter/PCMakefileFactory.h>

#import <Protocols/Preferences.h>
#import "../Modules/Preferences/Build/PCBuildPrefs.h"

#define COMMENT_HEADERS      @"\n\n#\n# Header files\n#\n"
#define COMMENT_RESOURCES    @"\n\n#\n# Resource files\n#\n"
#define COMMENT_CLASSES      @"\n\n#\n# Class files\n#\n"
#define COMMENT_CFILES       @"\n\n#\n# Other sources\n#\n"
#define COMMENT_SUBPROJECTS  @"\n\n#\n# Subprojects\n#\n"
#define COMMENT_APP          @"\n\n#\n# Main application\n#\n"
#define COMMENT_LIBRARIES    @"\n\n#\n# Additional libraries\n#\n"
#define COMMENT_BUNDLE       @"\n\n#\n# Bundle\n#\n"
#define COMMENT_LIBRARY      @"\n\n#\n# Library\n#\n"
#define COMMENT_TOOL         @"\n\n#\n# Tool\n#\n"
#define COMMENT_LOCALIZATION @"\n\n#\n# Localization\n#\n"

@implementation PCMakefileFactory

static PCMakefileFactory *_factory = nil;

+ (PCMakefileFactory *)sharedFactory
{
  static BOOL isInitialised = NO;

  if (isInitialised == NO)
    {
      _factory = [[PCMakefileFactory alloc] init];

      isInitialised = YES;
    }

  return _factory;
}

- (void) createMakefileForProject: (PCProject *)project
{
  id <PCPreferences> prefs = [[project projectManager] prefController];
  NSString       *buildDir = [prefs stringForKey:RootBuildDirectory];
  NSString       *prName = [project projectName];
  NSString       *buildName = [prName stringByAppendingPathExtension: @"build"];
  NSString       *instDir = [[project projectDict] objectForKey:PCInstallDir];

  NSAssert(prName, @"No project name given!");

  AUTORELEASE(mfile);
  mfile = [[NSMutableString alloc] init];

  AUTORELEASE(pnme);
  pnme = [prName copy];

  [mfile appendString: @"#\n"];
  [mfile appendString: @"# GNUmakefile - Generated by ProjectCenter\n"];
  [mfile appendString: @"#\n"];

  [mfile appendString: @"ifeq ($(GNUSTEP_MAKEFILES),)\n"];
  [mfile appendString: @" GNUSTEP_MAKEFILES := $(shell gnustep-config "];
  [mfile appendString: @"--variable=GNUSTEP_MAKEFILES 2>/dev/null)\n"];
  [mfile appendString: @"endif\n"];
  [mfile appendString: @"ifeq ($(GNUSTEP_MAKEFILES),)\n"];
  [mfile appendString: @" $(error You need to set GNUSTEP_MAKEFILES"];
  [mfile appendString: @" before compiling!)\n"];
  [mfile appendString: @"endif\n"];

  if ([instDir isEqualToString: @"LOCAL"]
    || [instDir isEqualToString: @"SYSTEM"]
    || [instDir isEqualToString: @"USER"]
    || [instDir isEqualToString: @"NETWORK"])
    {
      [mfile appendString:
	[NSString stringWithFormat: @"\nGNUSTEP_INSTALLATION_DOMAIN = %@\n",
	  instDir]];
    }

  /* If GNUSTEP_INSTALLATION_DOMAIN was not set explicitly by the
   * user, it shoudl not be specified; gnustep-make will use the
   * default - normally, but not necessarily, LOCAL.
   */
  
  [mfile appendString: @"\ninclude $(GNUSTEP_MAKEFILES)/common.make\n"];

  if (![buildDir isEqualToString: @""] && buildDir != nil)
    {
      [mfile appendString:
        [NSString stringWithFormat: @"\nGNUSTEP_BUILD_DIR = %@\n",
	  [buildDir stringByAppendingPathComponent:buildName]]];
    }
}

- (BOOL)createPreambleForProject:(PCProject *)project
{
  NSMutableString *mfp = [[NSMutableString alloc] init];
  NSString        *mfl = nil;
  NSArray         *array = nil;
  NSDictionary    *projectDict = [project projectDict];
  NSString        *projectPath = [project projectPath];
  NSString        *projectType = [project projectTypeName];

  // Create the new file
  [mfp appendString: @"#\n"];
  [mfp appendString: @"# GNUmakefile.preamble - Generated by ProjectCenter\n"];
  [mfp appendString: @"#\n\n"];

  // Preprocessor flags
  [mfp appendString: @"# Additional flags to pass to the preprocessor\n"];
  [mfp appendString:
    [NSString stringWithFormat: @"ADDITIONAL_CPPFLAGS += %@\n\n", 
     [projectDict objectForKey:PCPreprocessorOptions]]];

  // Objective C compiler flags
  [mfp appendString: @"# Additional flags to pass to Objective C compiler\n"];
  [mfp appendString:
    [NSString stringWithFormat: @"ADDITIONAL_OBJCFLAGS += %@\n\n",
     [projectDict objectForKey:PCObjCCompilerOptions]]];
    
  // C compiler flags
  [mfp appendString: @"# Additional flags to pass to C compiler\n"];
  [mfp appendString:
    [NSString stringWithFormat: @"ADDITIONAL_CFLAGS += %@\n\n",
     [projectDict objectForKey:PCCompilerOptions]]];
		     
  // Linker flags
  [mfp appendString: @"# Additional flags to pass to the linker\n"];
  [mfp appendString:
    [NSString stringWithFormat: @"ADDITIONAL_LDFLAGS += %@ ",
     [projectDict objectForKey:PCLinkerOptions]]];
  [mfp appendString: @"\n\n"];

  // Directories where to search headers
  [mfp appendString:
    @"# Additional include directories the compiler should search\n"];
  [mfp appendString: @"ADDITIONAL_INCLUDE_DIRS += "];
  array = [projectDict objectForKey:PCSearchHeaders];
  if (array && [array count])
    {
      NSString     *tmp;
      NSEnumerator *enumerator = [array objectEnumerator];

      while ((tmp = [enumerator nextObject])) 
	{
	  [mfp appendString: [NSString stringWithFormat: @"-I%@ ",tmp]];
	}
    }
  [mfp appendString: @"\n\n"];
  
  // Directories where to search libraries
  [mfp appendString:
    @"# Additional library directories the linker should search\n"];
  [mfp appendString: @"ADDITIONAL_LIB_DIRS += "];
  array = [projectDict objectForKey:PCSearchLibs];
  if (array && [array count])
    {
      NSString     *tmp;
      NSEnumerator *enumerator = [array objectEnumerator];

      while ((tmp = [enumerator nextObject])) 
	{
	  [mfp appendString: [NSString stringWithFormat: @"-L%@ ",tmp]];
	}
    }
  [mfp appendString: @"\n\n"];

  // [mfp appendString: [projectDict objectForKey:PCLibraries]];

  if ([projectType isEqualToString: @"Tool"])
    {
      // Additional TOOL libraries
      [mfp appendString: @"# Additional TOOL libraries to link\n"];
      [mfp appendString: @"ADDITIONAL_TOOL_LIBS += "];
      array = [projectDict objectForKey:PCLibraries];
      if (array && [array count])
        {
          NSString     *tmp;
          NSEnumerator *enumerator = [array objectEnumerator];
          
          while ((tmp = [enumerator nextObject]))
            {
              if (![tmp isEqualToString: @"gnustep-base"])
                {
                  [mfp appendString: [NSString stringWithFormat: @"-l%@ ",tmp]];
                }
            }
        }
    }
  else
    {
      // Additional GUI libraries
      // TODO: Let the user select objc, base, gui libraries/frameworks
      // on the gui - the following works well for GUI stuff only.
      [mfp appendString: @"# Additional GUI libraries to link\n"];
      [mfp appendString: @"ADDITIONAL_GUI_LIBS += "];
      array = [projectDict objectForKey:PCLibraries];
      if (array && [array count])
        {
          NSString     *tmp;
          NSEnumerator *enumerator = [array objectEnumerator];
          
          while ((tmp = [enumerator nextObject]))
            {
              if (![tmp isEqualToString: @"gnustep-base"] &&
                  ![tmp isEqualToString: @"gnustep-gui"])
                {
                  [mfp appendString: [NSString stringWithFormat: @"-l%@ ",tmp]];
                }
            }
        }
    }

  [mfp appendString: @"\n\n"];

  // Write the new file to disc!
  mfl = [projectPath stringByAppendingPathComponent: @"GNUmakefile.preamble"];
  if (![mfp writeToFile:mfl atomically:YES]) 
    {
      NSRunAlertPanel(@"Create Makefile",
		      @"Couldn't create %@",
		      @"Ok",nil,nil, mfl);
      return NO;
    }

  return YES;
}

- (BOOL)createPostambleForProject:(PCProject *)project
{
  NSBundle      *bundle = nil;
  NSString      *template = nil;
  NSString      *postamble = nil;
  NSFileManager *fm = [NSFileManager defaultManager];
  
  bundle = [NSBundle bundleForClass: [self class]];
  template = [bundle pathForResource: @"postamble" ofType: @"template"];
  postamble = [[project projectPath] 
    stringByAppendingPathComponent: @"GNUmakefile.postamble"];

  if (![fm copyPath:template toPath:postamble handler:nil])
    {
      NSRunAlertPanel(@"Create Makefile",
		      @"Couldn't create %@",
		      @"Ok",nil,nil, postamble);
      return NO;
    }

  return YES;
}

- (void)appendString:(NSString *)aString
{
  NSAssert(mfile, @"No valid makefile available!");
  NSAssert(aString, @"No valid string!");

  [mfile appendString:aString];
}

- (void)appendLibraries:(NSArray *)array
{
  NSMutableArray *libs = [NSMutableArray arrayWithArray:array];
  NSString       *lib = nil;
  NSEnumerator   *enumerator = nil;

  [libs removeObject: @"gnustep-base"];
  [libs removeObject: @"gnustep-gui"];

  if (libs == nil || [libs count] == 0)
    {
      return;
    }

  [self appendString: @"\n\n#\n# Libraries\n#\n"];
  [self appendString:
    [NSString stringWithFormat: @"%@_LIBRARIES_DEPEND_UPON += ",pnme]];

  enumerator = [libs objectEnumerator];
  while ((lib = [enumerator nextObject])) 
    {
      [self appendString: [NSString stringWithFormat: @"-l%@ ",lib]];
    }
}

- (void)appendHeaders:(NSArray *)array
{
  if (array == nil || [array count] == 0)
    return;

  [self appendHeaders:array forTarget:pnme];
}

- (void)appendHeaders:(NSArray *)array forTarget:(NSString *)target
{
  if (array == nil || [array count] == 0)
    return;

  [self appendString:COMMENT_HEADERS];
  [self appendString:
    [NSString stringWithFormat: @"%@_HEADER_FILES = \\\n", target]];

  [self appendString: [array componentsJoinedByString: @" \\\n"]];
}

- (void)appendClasses:(NSArray *)array
{
  if (array == nil || [array count] == 0)
    {
      return;
    }

  [self appendClasses:array forTarget:pnme];
}

- (void)appendClasses:(NSArray *)array forTarget:(NSString *)target
{
  if (array == nil || [array count] == 0)
    {
      return;
    }

  [self appendString:COMMENT_CLASSES];
  [self appendString:
    [NSString stringWithFormat: @"%@_OBJC_FILES = \\\n",target]];

  [self appendString: [array componentsJoinedByString: @" \\\n"]];
}

- (void)appendOtherSources:(NSArray *)array
{
  if (array == nil || [array count] == 0)
    {
      return;
    }

  [self appendOtherSources: array forTarget: pnme];
}

- (void)appendOtherSources:(NSArray *)array forTarget: (NSString *)target
{
  NSMutableArray *marray = nil;
  NSMutableArray *oarray = nil;
  NSEnumerator   *oenum;
  NSString       *file;
  
  if (array == nil || [array count] == 0)
    {
      return;
    }

  // Other Sources can have both .m files and non .m files
  oenum = [array objectEnumerator];
  while ((file = [oenum nextObject]))
    {
      if ([file hasSuffix: @".m"])
	{
	  if (marray == nil)
	    {
	      marray = [NSMutableArray array];
	    }
	  [marray addObject: file];
	}
      else // non .m file
	{
	  if (oarray == nil)
	    {
	      oarray = [NSMutableArray array];
	    }
	  [oarray addObject: file];
	}
    }

  [self appendString:COMMENT_CFILES];

  // Add other sources if any
  if (oarray && [oarray count] != 0)
    {
      oenum = [oarray objectEnumerator];
	
      [self appendString: [NSString stringWithFormat: @"%@_C_FILES = ", target]];
  
      while ((file = [oenum nextObject])) 
	{
	  [self appendString: [NSString stringWithFormat: @"\\\n%@ ",file]];
	}
      [self appendString: @"\n\n"];
    }

  // Add .m files if any
  if (marray && [marray count] != 0)
    {
      oenum = [marray objectEnumerator];
	
      [self appendString: [NSString stringWithFormat: @"%@_OBJC_FILES += ",pnme]];

      while ((file = [oenum nextObject])) 
	{
	  [self appendString: [NSString stringWithFormat: @"\\\n%@ ", file]];
	}
    }
}

- (void)appendResources:(NSArray *)array inDir:(NSString *)dir
{
  int      i = 0;
  int      count = [array count];
  NSString *string = nil;
  NSString *item = nil;
  NSString *eol = [NSString stringWithString: @"\\\n"];

  if (array == nil || count <= 0)
    {
      return;
    }

  // Header
  [self appendString:COMMENT_RESOURCES];
  [self appendString:
    [NSString stringWithFormat: @"%@_RESOURCE_FILES = \\\n",pnme]];

  // Items
  for (i = 0; i < count; i++)
    {
      item = [array objectAtIndex:i];
      string = [NSString stringWithFormat: @"%@/%@ %@", dir, item, eol];
      [self appendString:string];
      if (i == (count-2))
	{
	  eol = [NSString stringWithString: @"\n"];
	}
    }
}

- (void)appendResourceItems:(NSArray *)array
{
  if (array == nil || [array count] <= 0)
    {
      return;
    }

  [self appendString: @"\\\n"];
  [self appendString: [array componentsJoinedByString: @" \\\n"]];
}

- (void)appendLocalizedResources:(NSArray *)resources 
		    forLanguages:(NSArray *)languages
{
  NSString *langs = [languages componentsJoinedByString: @" "];
  NSString *string = nil;
  NSString *item = nil;
  NSString *eol = [NSString stringWithString: @"\\\n"];
  int      i = 0;
  int      count = [resources count];

  if (resources == nil || count <= 0)
    {
      return;
    }

  // Header
  [self appendString:COMMENT_LOCALIZATION];
  
  // Languages
  string = [NSString stringWithFormat: @"%@_LANGUAGES = %@\n", pnme, langs];
  [self appendString:string];

  // Items
  [self appendString:
    [NSString stringWithFormat: @"%@_LOCALIZED_RESOURCE_FILES = \\\n",pnme]];
  for (i = 0; i < count; i++)
    {
      if (i == (count-1))
	{
	  eol = [NSString stringWithString: @"\n"];
	}
      item = [resources objectAtIndex:i];
      string = [NSString stringWithFormat: @"%@ %@", item, eol];
      [self appendString:string];
    }
}

- (void)appendSubprojects:(NSArray*)array
{
  NSString     *tmp = nil;
  NSEnumerator *enumerator = nil;

  if (array == nil || [array count] == 0)
    {
      return;
    }

  [self appendString:COMMENT_SUBPROJECTS];
  [self appendString: @"SUBPROJECTS = "];

  enumerator = [array objectEnumerator];
  while ((tmp = [enumerator nextObject]))
    {
      tmp = [tmp stringByAppendingPathExtension: @"subproj"];
      [self appendString: [NSString stringWithFormat: @"\\\n%@ ",tmp]];
    }
}

- (NSData *)encodedMakefile
{
  NSAssert(mfile, @"No valid makefile available!");

  return [mfile dataUsingEncoding: [NSString defaultCStringEncoding]];
}

@end

