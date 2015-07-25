--
--  AppDelegate.applescript
--  Spotify Quick Controller
--  A simple and nice window to control Spotify easily.
--  Created by Antonio Frighetto on 11/06/15.
--  Copyright (c) 2015 Antonio Frighetto. All rights reserved.
--

script AppDelegate
    property parent : class "NSObject"
    property NSImage : class "NSImage"

    -- IBOutlets
    property theWindow : missing value
    property imageView : missing value
    property theLabel : missing value
    property theSlider : missing value
    property firstSegment: missing value
    property secondSegment: missing value
    property pullDownButton : missing value
    property secondsDelay : 0.3
    global getTimer, theList
    
    on openWindow()
        set theList to {"Commercial 2014", "Top Track Italy 2015", "Today's Top Hits", "Global Hits"}
        tell pullDownButton
            addItemsWithTitles_(theList)
            synchronizeTitleAndSelectedItem()
        end tell
        tell theWindow
            makeKeyAndOrderFront_(me)
            setAllowsConcurrentViewDrawing_(true)
        end tell
    end openWindow
    
    on isPlaying()
        using terms from application "Spotify"
            if player state of application "Spotify" is playing
                return true
            else
                return false
            end if
        end using terms from
    end isPlaying
    
    on initializeSpotify(action)
        if application "Spotify" is not running then
            tell application "Spotify" to run
            secondSegment's setEnabled_(true)
        end if
        run script "tell application \"Spotify\" to " & action
        if action contains "play track \"spotify:" then delay 0.2 --necessary for playlists
        if not (action contains "playpause") then imageView's setImage_(missing value)
        displayInfoTrack()
    end initializeSpotify
    
    on playPausePreviousNextTrack_(sender)
        if (firstSegment's selectedSegment()) is equal to 0 then
            initializeSpotify("previous track")
        else if (firstSegment's selectedSegment()) is equal to 1 then
            initializeSpotify("playpause")
        else
            initializeSpotify("next track")
        end if
    end playPausePreviousNextTrack_
    
    on changePlaylist_(sender)
        -- modify tracks according to your preferences
        local track1, track2, track3, track4
        set track1 to "\"spotify:user:1192646653:playlist:1vIk4xJ60IVtLrsHHCdOIG\"" --Commercial
        set track2 to "\"spotify:user:sonymusicitaly:playlist:0njnvMkgsTb0wL8BFDwAGS\"" --Top's Italy
        set track3 to "\"spotify:user:spotify:playlist:5FJXhjdILmRA2z5bvz4nzf\"" --Top 50 Hits
        set track4 to "\"spotify:user:filtr:playlist:4JkkvMpVl4lSioqQjeAL0q\"" --Global Hits
        -- set track4 to "\"example\""

        if (pullDownButton's indexOfSelectedItem()) is equal to 1 then
            initializeSpotify("play track " & track1)
        else if (pullDownButton's indexOfSelectedItem()) is equal to 2 then
            initializeSpotify("play track " & track2)
        else if (pullDownButton's indexOfSelectedItem()) is equal to 3 then
            initializeSpotify("play track " & track3)
        else if (pullDownButton's indexOfSelectedItem()) is equal to 4 then
            initializeSpotify("play track " & track4)
        -- else if (pullDownButton's indexOfSelectedItem()) is equal to 5 then
            -- initializeSpotify("play track " & track5)
        end if
    end changePlaylist_
    
    on displayInfoTrack()
        if isPlaying()
            tell application "Spotify" to set {trackName, artistName, albumName} to get {name, artist, album} of current track
            if contents of albumName is in trackName then
                set theString to "You are now listening to " & "«" & trackName & "»" & " from the homonymous album by " & artistName & "."
            else
                set theString to "You are now listening to " & "«" & trackName & "»" & " from the album «" & albumName & "»" & " by " & artistName & "."
            end if
        else
            set theString to "No songs playing."
        end if
        theLabel's setStringValue_(theString)
    end displayInfoTrack

    on displayCoverTrack()
        -- Note: Since spotify artwork seems not working properly, it gets covers from the Internet, so depend on the connection it might be slow.
        if isPlaying() then
            tell application "Spotify" to set spotifyID to get id of current track
            set embedSP to "https://embed.spotify.com/oembed/?url=" & spotifyID
            try
                repeat
                    set getData to do shell script "curl " & embedSP
                    set AppleScript's text item delimiters to {"cover\\/", "\",\"provider"}
                    set returnedURL to middle text item of getData
                    if not (returnedURL contains "404 Not Found") then exit repeat
                end repeat
                set theURL to current application's NSURL's URLWithString_("https://d3rt1990lpmkn.cloudfront.net/640/" & returnedURL)
                set albumImage to current application's NSImage's alloc()'s initWithContentsOfURL_(theURL)
                imageView's setImage_(albumImage)
            on error errMsg number errNum
                log errMsg
                error errMsg number errNum
            end try
        end if
    end displayCoverTrack
    
    on setVolume_(sender)
        tell current application to set volume output volume theSlider's integerValue()
    end setVolume_
    
    on shuffleRepeat_(sender)
        if application "Spotify" is running then
            tell application "Spotify"
                if (secondSegment's selectedSegment()) is equal to 0 then
                    set shuffling to (not shuffling)
                else
                    set repeating to (not repeating)
                end if
            end tell
        end if
    end shuffleRepeat_

    on checkIfShuffleAndRepeatAreEnabled()
        tell application "Spotify"
            if (shuffling and repeating)
                secondSegment's setSelected_forSegment_(true, 0)
                secondSegment's setSelected_forSegment_(true, 1)
            else if (shuffling and not repeating)
                secondSegment's setSelected_forSegment_(true, 0)
                secondSegment's setSelected_forSegment_(false, 1)
            else if (not shuffling and repeating)
                secondSegment's setSelected_forSegment_(false, 0)
                secondSegment's setSelected_forSegment_(true, 1)
            else if not (shuffling and repeating)
                secondSegment's setSelected_forSegment_(false, 0)
                secondSegment's setSelected_forSegment_(false, 1)
            end if
        end tell
    end checkIfShuffleAndRepeatAreEnabled

    on refreshWindow_(theTimer)
        if application "Spotify" is running
            secondSegment's setEnabled_(true)
            displayInfoTrack()
            checkIfShuffleAndRepeatAreEnabled()
            if isPlaying() then
                firstSegment's setLabel_forSegment_("", 1)
            else
                firstSegment's setLabel_forSegment_("", 1)
            end if
            displayCoverTrack()
        else
            theLabel's setStringValue_("Spotify is currently not running.")
            firstSegment's setLabel_forSegment_("", 1)
            secondSegment's setEnabled_(false)
        end if
        if (output volume of (get volume settings)) is not equal to (theSlider's integerValue()) then theSlider's setIntegerValue_(output volume of (get volume settings))
    end refreshWindow_

    on applicationWillFinishLaunching_(aNotification)
        -- Insert code here to initialize your application before any files are opened
        performSelectorOnMainThread_withObject_waitUntilDone_("refreshWindow:", missing value, 0)
        openWindow()
    end applicationWillFinishLaunching_

    on applicationDidFinishLaunching_(aNotification)
        set getTimer to current application's NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(secondsDelay, me, "refreshWindow:", missing value, true)
    end applicationDidFinishLaunching_

    on applicationShouldTerminateAfterLastWindowClosed_(aNotification)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_

    on applicationShouldTerminate_(sender)
        -- Insert code here to do any housekeeping before your application quits
        getTimer's invalidate()
        return current application's NSTerminateNow
    end applicationShouldTerminate_
    
end script