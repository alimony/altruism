/*
Copyright (c) 2008 Markus Amalthea Magnuson <markus.magnuson@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#import "ASMPathProvider.h"

@implementation ASMPathProvider

@end

@implementation ASMTailingPathProvider

- (BOOL)tailThisForMe:(NSString *)path
{
	if (path) {
		// return early if no log file was found.
		if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
			NSLog(@"No log file at %@", path);
			return NO;
		}
		
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
	
	return NO;
}

- (void)newData:(NSNotification *)dataNotification
{
	// TODO: We should only notify with whole lines instead of chunks
	// of bytes, as these may be cut off in the middle
	
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
