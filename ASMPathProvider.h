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

  Markus Amalthea Magnuson
  markus.magnuson@gmail.com
-----------------------------------------------
*/

#import <Cocoa/Cocoa.h>

@class ASMLogController;

@interface ASMPathProvider : NSObject
{
	IBOutlet ASMLogController *logController;
}

@end

// use this path provider if you want to "tail" (watch) a log file for new incoming data.
@interface ASMTailingPathProvider : ASMPathProvider
{
	NSTask *tail;
	NSFileHandle *pipeHandle;
}

// starts listening to the logfile at "path". returns NO on failure.
// NOTE: you also need to implement receivedLogData: below.
- (BOOL)tailThisForMe:(NSString *)path; 

@end

@interface ASMTailingPathProvider (Foo)

// this will be called as new data arrives, from above.
- (void)receivedLogData:(NSData *)newData;

@end
