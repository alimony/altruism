/*
Copyright (c) 2008 Markus Amalthea Magnuson <markus@polyscopic.works>

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
