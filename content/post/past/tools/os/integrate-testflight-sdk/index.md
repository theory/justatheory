--- 
date: 2011-12-18T07:11:07Z
slug: integrate-testflight-sdk
title: How to Integrate the TestFlight SDK into an iOS Project
aliases: [/computers/os/ios/integrate-testflight-sdk.html]
tags: [iOS, TestFlight, SDK, beta, shipping, Xcode, HOWTO]
type: post
---

<p>I've started using <a href="http://testflightapp.com/">TestFlight</a> to release <a href="http://www.designsceneapp.com/">DesignScene</a> betas to testers. The documentation is thin, so I had to futz a bit, but fortunately it's a pretty simple app, so once I figured out that I just needed to stick to one "Team", I was off and running. And let me tell you, TestFlight is a <em>far</em> easier way to distribute betas than the convoluted methods suggested by Apple. Much more beta user-friendly.</p>

<p>For us developers, the <a href="http://testflightapp.com/sdk/">TestFlight SDK</a> is particularly handy. Add it to your TestFlight-distributed project and get crash reports and remote logging, ask your testers for feedback, and other cool stuff. I've only just started using it, but the immediate diagnostic feedback has already proved invaluable.</p>

<p>Getting the TestFlight SDK to work is dead simple, but it's not supported in App Store distributions. So I wanted to set things up so that it would always be included in beta releases and never in production releases. Getting to that point took a couple of days of futzing, as it's not explicitly supposed by Xcode's UI. The solution I came up with, thanks to <a href="http://stackoverflow.com/questions/8027043/objective-c-having-a-testflight-configuration-to-include-testflight-sdk">this StackOverflow post</a>, is to:</p>

<ul>
<li>Add a "Beta" configuration to complement the default "Release" and "Debug" configurations</li>
<li>Add a preprocessor macro to allow conditional use of the TestFlight SDK</li>
<li>Use the <a href="http://lists.apple.com/archives/xcode-users/2009/Jun/msg00153.html"><code>EXCLUDED_SOURCE_FILE_NAMES</code> setting</a> to exclude the TestFlight library from "Release" builds</li>
</ul>

<p>That last step makes me a <em>bit</em> nervous, but <code>EXCLUDED_SOURCE_FILE_NAMES</code>, while undocumented, seems to be <a href="http://www.google.com/?q=EXCLUDED_SOURCE_FILE_NAMES">reasonably well known</a>. At any rate, I could find no better way to tie the inclusion of a library to a specific configuration, so I'm going with it. Better solutions welcome.</p>

<p>At any rate, here's the step-by-step for Xcode 4.2:</p>

<ul>
<li><a href="https://testflightapp.com/sdk/download/">Download the TestFlight SDK</a> and unpack it.</li>
<li>Drag it into your project. Make sure that "Copy items into destination group's folder" is checked, as is "Create groups for any added folders". Include it in all relevant targets.</li>
<li><p>Create a "Beta" configuration:</p>

<ul>
<li>Click on the app name in the navigator, then on the project name and then the info tab.</li>
<li>Under "Configurations", click the plus sign and select "Duplicate "Release" Configuration"</li>
<li>Type "Beta" to name the new configuration.</li>
</ul>

<p>You should end up with something like this:</p>
<p><img style="float:none;" src="/2011/12/integrate-testflight-sdk/configurations.png" alt="Configurations" /></p>
</li>

<li><p>Create configuration macros:</p>

<p><img style="float:none;" src="/2011/12/integrate-testflight-sdk/config_config.png" alt="Configurations" /></p>

<ul>
<li>Still in the project settings, go to the "Build Settings" tab.</li>
<li>Search for "preprocessor macros".</li>
<li>Double-click the value section next to the "Preprocessor Macros" label, hit the <code>+</code> button, and enter <code>CONFIGURATION_$(CONFIGURATION)</code>.</li>
</ul>

<p>You should end up with a window like the above. Once you close it, you should see the macros names for each individual configuration, shown here:</p>

<p><img style="float:none;" src="/2011/12/integrate-testflight-sdk/configs.png" alt="Configurations" /></p></li>
<li><p>Add the <code>EXCLUDED_SOURCE_FILE_NAMES</code> build setting.</p>

<ul>
<li>Still in the "Build Settings" tab, click the "Add Build Setting" button in the lower-left corner and select "Add User-Defined Setting".</li>
<li>Input <code>EXCLUDED_SOURCE_FILE_NAMES</code> as the name of the setting.</li>
<li>Open the reveal triangle next to the setting name.</li>
<li>Double-click to the right of "Release".</li>
<li>Enter <code>*libTestFlight.a</code> as the value.</li>
</ul>

<p>You should end up with the value <code>*libTestFlight.a</code> only for the "Release" configuration, as shown here:</p>

<p><img style="float:none;" src="/2011/12/integrate-testflight-sdk/excluded_source_file_names.png" alt="Configurations" /></p></li>
<li><p>Go ahead and use the TestFlight SDK:</p>

<ul>
<li>In your app delegate, add <code>#include "testFlight.h"</code></li>
<li><p>In <code>-application:didFinishLaunchingWithOptions:</code>, just before returning, add these lines:</p>

<pre>#ifdef CONFIGURATION_Beta
    [TestFlight takeOff:@"Insert your Team Token here"];
#endif</pre></li>
</ul></li>
</ul>

<p>Now, when you build or archive with the "Beta" target, the TestFlight SDK will be included and log sessions. But when you build with the "Release" target, TestFlight will neither be bundled or referenced in the app. You can include it anywhere, though, and use any of its features, as long as you do so only within a <code>#ifdef CONFIGURATION_Beta</code> block. Check out the <a href="https://testflightapp.com/sdk/doc/">complete SDK docs</a> for details. Then, get your beta on!</p>
