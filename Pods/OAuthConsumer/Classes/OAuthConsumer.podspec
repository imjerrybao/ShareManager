#
#  Be sure to run `pod spec lint OAuthConsumer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "OAuthConsumer"
  s.version      = "1.0.0"
  s.summary      = "Clone of Jon Crosby's OAuthConsumer http://code.google.com/p/oauthconsumer/ "

  s.description  = <<-DESC
#OAuthConsumer


This is an iPhone ready version of:
http://oauth.googlecode.com/svn/code/obj-c/OAuthConsumer by Jon Crosby.

This version has been updated for iOS 8.0 and to use Automatic Reference Counting (ARC). You will need to add **Security.framework**.

"iPhone ready" simply means you just need to add the files to Xcode, and import "OAuthConsumer.h".

OADataFetcher now also includes the ability to use blocks in addition to delegates as seen in this example:

	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:self.consumerKey secret:self.consumerSecret];
	OAToken *token = [[OAToken alloc] initWithKey:self.accessToken secret:self.accessTokenSecret];
	NSURL* url = [NSURL URLWithString:urlString];
	OAMutableURLRequest* request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:token realm:nil signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	NSMutableArray *params = [[NSMutableArray alloc] init];
	for ( NSString *key in [postParams allKeys] )
	{
		OARequestParameter* param = [[OARequestParameter alloc] initWithName:key value:postParams[key]];
		[params addObject:param];
	}
	if ( [params count] > 0 )
		[request setParameters:params];
	OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
	[dataFetcher performRequest:request
					withHandler:^(OAServiceTicket *ticket, NSData *data, NSError *error) {
				   if ( !error ) {
					   NSLog(@"didPost:=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
					   [self updateStatusCompleteWithStatus:SCUpdateSuccessful data:data error:nil];
				   }
				   else
				   {
					   [self updateStatusCompleteWithStatus:SCUpdateFailed data:data error:error];
				   }
			   }];


This is a work in progress. Please feel free to contact me at larry [at] larryborsato [dot] com.
                   DESC

  s.homepage     = "https://github.com/lborsato/OAuthConsumer"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  #s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "Larry Borsato" => "larry@larryborsato.com" }
  # Or just: s.author    = "Larry Borsato"
  # s.authors            = { "Larry Borsato" => "larry@larryborsato.com" }
  s.social_media_url   = "http://twitter.com/lborsato"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/lborsato/OAuthConsumer.git", :commit => "966ad43327a933492eacab6ca0c1139d532022cf" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any h, m, mm, c & cpp files. For header
  #  files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "**/*.{m,h}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
