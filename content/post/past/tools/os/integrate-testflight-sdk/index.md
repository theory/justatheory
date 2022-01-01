--- 
date: 2011-12-18T07:11:07Z
slug: integrate-testflight-sdk
title: How to Integrate the TestFlight SDK into an iOS Project
aliases: [/computers/os/ios/integrate-testflight-sdk.html]
tags: [iOS, TestFlight, SDK, Beta, Shipping, Xcode, HOWTO]
type: post
---

I've started using [TestFlight] to release [DesignScene] betas to testers. The
documentation is thin, so I had to futz a bit, but fortunately it's a pretty
simple app, so once I figured out that I just needed to stick to one "Team", I
was off and running. And let me tell you, TestFlight is a *far* easier way to
distribute betas than the convoluted methods suggested by Apple. Much more beta
user-friendly.

For us developers, the [TestFlight SDK] is particularly handy. Add it to your
TestFlight-distributed project and get crash reports and remote logging, ask
your testers for feedback, and other cool stuff. I've only just started using
it, but the immediate diagnostic feedback has already proved invaluable.

Getting the TestFlight SDK to work is dead simple, but it's not supported in App
Store distributions. So I wanted to set things up so that it would always be
included in beta releases and never in production releases. Getting to that
point took a couple of days of futzing, as it's not explicitly supposed by
Xcode's UI. The solution I came up with, thanks to [this StackOverflow post], is
to:

-   Add a "Beta" configuration to complement the default "Release" and "Debug"
    configurations
-   Add a preprocessor macro to allow conditional use of the TestFlight SDK
-   Use the [`EXCLUDED_SOURCE_FILE_NAMES` setting] to exclude the TestFlight
    library from "Release" builds

That last step makes me a *bit* nervous, but `EXCLUDED_SOURCE_FILE_NAMES`, while
undocumented, seems to be [reasonably well known]. At any rate, I could find no
better way to tie the inclusion of a library to a specific configuration, so I'm
going with it. Better solutions welcome.

At any rate, here's the step-by-step for Xcode 4.2:

-   [Download the TestFlight SDK] and unpack it.
-   Drag it into your project. Make sure that "Copy items into destination
    group's folder" is checked, as is "Create groups for any added folders".
    Include it in all relevant targets.
-   Create a "Beta" configuration:

    -   Click on the app name in the navigator, then on the project name and
        then the info tab.
    -   Under "Configurations", click the plus sign and select "Duplicate
        "Release" Configuration"
    -   Type "Beta" to name the new configuration.

    You should end up with something like this:

    ![Configurations](/2011/12/integrate-testflight-sdk/configurations.png)

-   Create configuration macros:

    ![Configurations](/2011/12/integrate-testflight-sdk/config_config.png)

    -   Still in the project settings, go to the "Build Settings" tab.
    -   Search for "preprocessor macros".
    -   Double-click the value section next to the "Preprocessor Macros" label,
        hit the `+` button, and enter `CONFIGURATION_$(CONFIGURATION)`.

    You should end up with a window like the above. Once you close it, you
    should see the macros names for each individual configuration, shown here:

    ![Configurations](/2011/12/integrate-testflight-sdk/configs.png)

-   Add the `EXCLUDED_SOURCE_FILE_NAMES` build setting.

    -   Still in the "Build Settings" tab, click the "Add Build Setting" button
        in the lower-left corner and select "Add User-Defined Setting".
    -   Input `EXCLUDED_SOURCE_FILE_NAMES` as the name of the setting.
    -   Open the reveal triangle next to the setting name.
    -   Double-click to the right of "Release".
    -   Enter `*libTestFlight.a` as the value.

    You should end up with the value `*libTestFlight.a` only for the "Release"
    configuration, as shown here:

    ![Configurations](/2011/12/integrate-testflight-sdk/excluded_source_file_names.png)

-   Go ahead and use the TestFlight SDK:

    -   In your app delegate, add `#include "testFlight.h"`
    -   In `-application:didFinishLaunchingWithOptions:`, just before returning,
        add these lines:

            #ifdef CONFIGURATION_Beta
                [TestFlight takeOff:@"Insert your Team Token here"];
            #endif

Now, when you build or archive with the "Beta" target, the TestFlight SDK will
be included and log sessions. But when you build with the "Release" target,
TestFlight will neither be bundled or referenced in the app. You can include it
anywhere, though, and use any of its features, as long as you do so only within
a `#ifdef CONFIGURATION_Beta` block. Check out the [complete SDK docs] for
details. Then, get your beta on!

  [TestFlight]: https://testflight.apple.com/
  [DesignScene]: http://www.designsceneapp.com/
  [TestFlight SDK]: http://testflightapp.com/sdk/
  [this StackOverflow post]: https://stackoverflow.com/q/8027043/79202
  [`EXCLUDED_SOURCE_FILE_NAMES` setting]: http://lists.apple.com/archives/xcode-users/2009/Jun/msg00153.html
  [reasonably well known]: https://www.google.com/search?q=EXCLUDED_SOURCE_FILE_NAMES
  [Download the TestFlight SDK]: https://testflightapp.com/sdk/download/
  [complete SDK docs]: https://testflightapp.com/sdk/doc/
