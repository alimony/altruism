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

#import "ASMLogController.h"
#import "ASMPlayerController.h"

@implementation ASMLogController

- (id)init
{
	if ((self = [super init])) {
		uniquePaths = [[NSMutableSet alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[uniquePaths release];
	
	[super dealloc];
}

- (void)addPath:(NSString *)path
{
	if (![uniquePaths member:path]) {
		// we haven't added this song, so send it to our player and remember it
		[playerController addFileToPlayer:path];
		
		[uniquePaths addObject:path];
	}
}

@end
