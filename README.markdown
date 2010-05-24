Selenium PLT
============

Developed by Untyped.

Selenium RC client for PLT Scheme.

Copyright 2006 to 2010 Untyped.

See LICENCE and COPYING for licence information.

Introduction
------------

This package is two things: a [PLT Scheme][3] client for [Selenium RC][2], and a PLT Scheme language format for [Selenium IDE][1]:

 * [Selenium IDE][1] is a Firefox plugin that lets you record web page interactions and export them to program code;
 
 * [Selenium RC][2] is a client/server framework that lets you replay recorded actions in one of several popular web browsers.

[1]: http://seleniumhq.org/projects/ide
[2]: http://seleniumhq.org/projects/remote-control
[3]: http://www.plt-scheme.org

Quick start
-----------

 1. Go to the [Selenium Downloads][4] page and grab Selenium IDE and Selenium RC. Also make sure you have recent versions of Firefox (3.6 tested) and Java (1.6 tested).

 2. Download this package and require `main.ss` from your Scheme code:

        #lang scheme
        
        (require "path/to/main.ss")

        ; This assumes Selenium Server is running on localhost port 4444. See config.ss for more info:
        (current-selenium-config (create-selenium-config "*firefox" "http://www.google.com"))
        
        ; Fire up a browser
        (sel-start)
        
        ; Web interactions go here...

 3. Install the Selenium IDE Firefox plugin and add the PLT Scheme language format:

    1. Open Selenium IDE from Firefox: *Tools menu > Selenium IDE*;
    
    2. Select the Selenium window and go to *Options menu > Options...*;
    
    3. Go to *Formats > Add* and copy and paste in the contents of `selenium-ide.js`;
    
    4. Name the new format "PLT Scheme" and close the options dialog;
    
    5. Set the clipboard format to PLT Scheme: choose *Options menu > Clipboard format > PLT Scheme*.

 4. Record some actions: go to Google, do a search, and so on...
 
 5. Select the recorded actions in Selenium IDE using *Edit menu > Select all*, copy them to your clipboard, and paste them into your Scheme code under the comment *Web interactions go here...*. They should come out looking like Scheme expressions. For example:

        ; Web interactions go here...
        (sel-open "/")
        (sel-type "q" "untyped")
        (sel-click "btnG")
        (sel-wait-for-page-to-load "30000")
        (sel-click "link=Home - Untyped")
        (sel-wait-for-page-to-load "30000")

 8. Run Selenium RC Server using the `java` command on your OS command line:
 
        bash$ java -jar selenium-server.jar

 9. Run your Scheme application, which should start a copy of Firefox and play back your recorded actions.

[4]: http://seleniumhq.org/download

Check `example.ss` for more example code and `api-internal.ss` for a full list of Selenium commands.

Enjoy!
