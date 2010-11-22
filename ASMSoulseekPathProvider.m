/*
-----------------------------------------------
  ALTRUISM LICENSE
 
  “Do what you want to do,
  and go where you're going to
  Think for yourself,
  'cause I won't be there with you”

  You are completely free to do anything with
  this source code, but if you try to make
  money on it you will be beaten up with a
  large stick. I take no responsibility for
  anything, and this license text must
  always be included.

  Markus Amalthea Magnuson <markus.magnuson@gmail.com>
-----------------------------------------------
*/

#import <AGRegex/AGRegex.h>

#import "ASMSoulseekPathProvider.h"
#import "ASMLogController.h"


@implementation ASMSoulseekPathProvider

- (id)init
{
	onlyUploadsRegexp = nil;
	
	return self;
}

- (void)awakeFromNib
{
	// TODO: Hur låta användaren välja path? Prefsfönster?
	NSString *logfilePath = [@"~/Library/Logs/ssX/ssX_Console.log" stringByExpandingTildeInPath];
	
	// return early (and make this path provider do nothing) if no log file was found.
	if ([[NSFileManager defaultManager] fileExistsAtPath:logfilePath] == NO)
		return;
    
	onlyUploadsRegexp = [[AGRegex alloc] initWithPattern:@"Finished uploading (.*) to user"];
	BOOL succeeded = [super tailThisForMe:logfilePath];
}

- (void)dealloc
{
	[onlyUploadsRegexp release];
	
	[super dealloc];
}

- (void)receivedLogData:(NSData *)newData
{
	// read the available data
	NSString *text = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	
	// parse the data for paths and send them to the log controller
	NSArray *lines = [text componentsSeparatedByString:@"\n"];
	NSEnumerator *lineEnumerator = [lines objectEnumerator];
	NSString *currentLine = nil;
	while ((currentLine = [lineEnumerator nextObject])) {
		AGRegexMatch *matchGroups = [onlyUploadsRegexp findInString:currentLine];
		if (matchGroups && [matchGroups count] > 1) {
			NSString *matchingPath = [matchGroups groupAtIndex:1]; // first match
			[logController addPath:matchingPath];
		}
	}
	
	[text release];
}

@end
