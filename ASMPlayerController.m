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

#import "ASMPlayerController.h"
#import "ID3/TagAPI.h"

@implementation ASMPlayerController

- (void)addFileToPlayer:(NSString *)path
{
	// check if the file exists
	if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
		// gather the id3 info
		TagAPI *tag = [[TagAPI alloc] initWithGenreList:nil];
		[tag examineFile:path];
		NSString *theArtist = [tag getArtist];
		NSString *theTitle = [tag getTitle];
		NSString *theAlbum = [tag getAlbum];
		[tag release];
		
		// run a simple applescript
		NSDictionary *errorDict;
		NSAppleEventDescriptor *returnDescriptor = NULL;
		NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:
																			 @"\
																			 property playlistName : \"Altruism\"\n\
																			 property theTitle : \"%@\"\n\
																			 property theArtist : \"%@\"\n\
																			 property theAlbum : \"%@\"\n\
																			 \
																			 tell application \"iTunes\"\n\
																			 if not (exists playlist playlistName) then\n\
																			 make new playlist with properties {name:playlistName}\n\
																			 end if\n\
																			 duplicate (every track of library playlist 1 whose artist is theArtist and name is theTitle and album is theAlbum) to playlist playlistName\n\
																			 end tell", theTitle, theArtist, theAlbum]];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		[scriptObject release];
		
		if (returnDescriptor != NULL) {
			// successful execution
			NSLog(@"Added %@ by %@ to iTunes", theTitle, theArtist);
		}
		else {
			// something went wrong
			NSLog(@"Couldn't add song to iTunes ; debug info = %@", errorDict);
		}
	}
}

@end
