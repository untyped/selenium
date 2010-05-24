Selenium PLT
============

Developed by Untyped.

Selenium RC client for PLT Scheme.

Copyright 2006 to 2010 Untyped.

See LICENCE and COPYING for licence information.

Introduction
------------

Selenium is a suite of functional testing tools for web applications. This package works with two of these tools:

 * [Selenium IDE][1] is a Firefox plugin that lets you record web page interactions and export them to a programming language of your choice (in our case PLT Scheme);
 
 * [Selenium RC][2] is a client/server framework that lets you replay recorded actions in a web browser of your choice.

Using Selenium.plt, you can record and play back web page interactions using code written in [PLT Scheme][3].

[1]: http://seleniumhq.org/projects/ide
[2]: http://seleniumhq.org/projects/remote-control
[3]: http://www.plt-scheme.org

Quick start
-----------

 1. Go to the [Selenium Downloads][4] page and grab Selenium IDE and Selenium RC.

 2. Download the code for this package and require `main.ss` from your Scheme code:

    #lang scheme

    (require "path/to/main.ss")

    ; This assumes Selenium Server is running on localhost port 4444. See config.ss for more info:
    (current-selenium-config (create-selenium-config "*firefox" "http://www.google.com"))

 3. Install the Selenium IDE Firefox plugin and add the PLT Scheme language format:

    a. Open Selenium IDE from Firefox: *Tools menu > Selenium IDE*;
    b. Select the Selenium window and go to *Options menu > Options...*;
    c. Go to *Formats > Add* and copy and paste the contents of `selenium-ide.js` from Selenium.plt;
    d. Name the new format "PLT Scheme" and close the options dialog;
    e. Set the clipboard format to PLT Scheme: choose *Options menu > Clipboard format > PLT Scheme*.

 4. Record some actions: go to Google, do a search, and so on...
 
 5. Select the actions in Selenium IDE: *Edit menu > Select all*.
 
 6. Copy the actions to the clipboard.
 
 7. Paste the actions into your Scheme module (they should come out looking as Scheme expressions).

 8. On your command line, run Selenium Server:
 
    bash$ java -jar selenium-server.jar

 9. Run your Scheme application, which should start a copy of Firefox and play back your recorded actions.

[4]: http://seleniumhq.org/download
