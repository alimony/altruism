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

#import <AGRegex/AGRegex.h>

#import "ASMShakesPeerPathProvider.h"
#import "ASMLogController.h"

@implementation ASMShakesPeerPathProvider

- (void)awakeFromNib
{
	CFStringRef spBundleId = CFSTR("se.hedenfalk.shakespeer");

	// read the log level from ShakesPeer's prefs
	CFPropertyListRef logLevel = CFPreferencesCopyAppValue(CFSTR("logLevel"), spBundleId);

	if (logLevel && CFGetTypeID(logLevel) == CFStringGetTypeID()) {
		// ask to set the correct log level if not currently at "Debug"
		if (![(NSString *)logLevel isEqualToString:@"Debug"]) {
			NSAlert *spPreferencesAlert = [NSAlert alertWithMessageText:@"Incorrect preferences"
														  defaultButton:@"OK"
														alternateButton:@"Cancel"
															otherButton:nil
											  informativeTextWithFormat:@"You need to set the debug level to “Debug” in the section “Advanced” of the ShakesPeer preferences window. Do you want me to do this for you?"];

			if ([spPreferencesAlert runModal] == NSAlertDefaultReturn) {
				// make the needed changes to ShakesPeer prefs
				CFPreferencesSetAppValue(CFSTR("logLevel"), CFSTR("Debug"), spBundleId);
				CFPreferencesAppSynchronize(spBundleId);

				// TODO: Restart ShakesPeer automatically, I haven't devised a clean way to do this yet
				NSAlert *restartAlert = [NSAlert alertWithMessageText:@"Restart"
														defaultButton:@"OK"
													  alternateButton:nil
														  otherButton:nil
											informativeTextWithFormat:@"You need to restart ShakesPeer for changes to take effect."];

				[restartAlert runModal];
			}
		}

		NSString *logfilePath = [@"~/Library/Logs/shakespeer-aqua.log" stringByExpandingTildeInPath];
		NSLog(@"Trying logfile at %@", logfilePath);
		BOOL succeeded = [super tailThisForMe:logfilePath];

		if (succeeded) {
			onlyUploadsRegexp = [[AGRegex alloc] initWithPattern:@"upload-finished\\$(.*.mp3)$"];
		}
		else {
			NSLog(@"Couldn't open logfile at %@", logfilePath);
		}
	}
	else {
		NSLog(@"Couldn't read ShakesPeer preferences, you may need to run ShakesPeer once before running Altruism");
	}

	if (logLevel)
		CFRelease(logLevel);
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
