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
