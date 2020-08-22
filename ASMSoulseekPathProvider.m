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
	CFStringRef ssXBundleId = CFSTR("net.schleifer.chris.ssX");

	// let's read the logfile path from ssX's prefs
	CFPropertyListRef logfileDirectory = CFPreferencesCopyAppValue(CFSTR("ssXLogLogDirectory"), ssXBundleId);

	if (logfileDirectory && CFGetTypeID(logfileDirectory) == CFStringGetTypeID()) {
		// logfile is pretty useless if ssX isn't set up properly, so let's check that
		CFPropertyListRef value1 = CFPreferencesCopyAppValue(CFSTR("ssXLogLogConsole"), ssXBundleId);
		CFPropertyListRef value2 = CFPreferencesCopyAppValue(CFSTR("ssXLogLevelTransfer"), ssXBundleId);

		BOOL ssXLogConsoleMessages = (value1 == kCFBooleanTrue);
		BOOL ssXTransferActicity = (value2 == kCFBooleanTrue);

		if (value1)
			CFRelease(value1);
		if (value2)
			CFRelease(value2);

		if (!ssXLogConsoleMessages || !ssXTransferActicity) {
			// the proper prefs weren't set, so ask the user to do so automatically
			NSAlert *ssXPreferencesAlert = [NSAlert alertWithMessageText:@"Incorrect preferences"
														   defaultButton:@"OK"
														 alternateButton:@"Cancel"
															 otherButton:nil
											   informativeTextWithFormat:@"You need to check the boxes “Log console messages” and “Transfer Activity” in the section “Logs” of the ssX preferences window. Do you want me to do this for you?"];

			if ([ssXPreferencesAlert runModal] == NSAlertDefaultReturn) {
				// make the needed changes to ssX prefs
				CFPreferencesSetAppValue(CFSTR("ssXLogLogConsole"), [NSNumber numberWithBool:YES], ssXBundleId);
				CFPreferencesSetAppValue(CFSTR("ssXLogLevelTransfer"), [NSNumber numberWithBool:YES], ssXBundleId);

				CFPreferencesAppSynchronize(ssXBundleId);

				// TODO: Restart ssX automatically, I haven't devised a clean way to do this yet
				NSAlert *restartAlert = [NSAlert alertWithMessageText:@"Restart"
														defaultButton:@"OK"
													  alternateButton:nil
														  otherButton:nil
											informativeTextWithFormat:@"You need to restart ssX for changes to take effect."];

				[restartAlert runModal];

				// everything should be set up properly now
				ssXLogConsoleMessages = YES;
				ssXTransferActicity = YES;
			}
		}

		// now get to business
		if (ssXLogConsoleMessages && ssXTransferActicity) {
			NSString *logfilePath = [(NSString *)logfileDirectory stringByAppendingPathComponent:@"ssX_Console.log"];
			NSLog(@"Trying logfile at %@", logfilePath);
			BOOL succeeded = [super tailThisForMe:logfilePath];

			if (succeeded) {
				onlyUploadsRegexp = [[AGRegex alloc] initWithPattern:@"Finished uploading (.*) to user"];
			}
			else {
				NSLog(@"Couldn't open logfile at %@", logfilePath);
			}
		}
	}
	else {
		NSLog(@"Couldn't read ssX preferences, you may need to run ssX once before running Altruism");
	}

	if (logfileDirectory)
		CFRelease(logfileDirectory);
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
