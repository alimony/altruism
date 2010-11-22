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

#import "ASMShakesPeerPathProvider.h"
#import "ASMLogController.h"

@implementation ASMShakesPeerPathProvider

- (void)awakeFromNib
{
	NSString *shakesPeerLog = [@"~/Library/Logs/shakespeer-aqua.log" stringByExpandingTildeInPath];
	BOOL succeded = [super tailThisForMe:shakesPeerLog];
	
	if (succeded) {
		onlyUploadsRegexp = [[AGRegex alloc] initWithPattern:@"upload-finished\\$(.*.mp3)$"];
	}
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
