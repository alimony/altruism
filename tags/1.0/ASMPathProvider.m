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

#import "ASMPathProvider.h"

@implementation ASMPathProvider

@end

@implementation ASMTailingPathProvider

- (BOOL)tailThisForMe:(NSString *)path
{
	NSPipe *pipe = [NSPipe pipe];
	pipeHandle = [[pipe fileHandleForReading] retain];
	[pipeHandle readInBackgroundAndNotify];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newData:)
												 name:NSFileHandleReadCompletionNotification
											   object:pipeHandle];
	
	tail = [[NSTask alloc] init];
	
	[tail setLaunchPath:@"/usr/bin/tail"];
	[tail setStandardOutput:pipe];
	[tail setArguments:[NSArray arrayWithObjects:@"-f", path, nil]];
	
	[tail launch];
	
	// TODO: return NO on error above
	
	return YES;
}

- (void)newData:(NSNotification *)dataNotification
{
	NSData *data = [[dataNotification userInfo] objectForKey:NSFileHandleNotificationDataItem]; 
	
	// call subclass with new data
	if ([self respondsToSelector:@selector(newData:)])
		[self receivedLogData:data]; 
    
	[pipeHandle readInBackgroundAndNotify];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[pipeHandle release];
	[super dealloc];
}

@end