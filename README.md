# BASIS.SYSTEM for DOS 3.3 Launcher

[![Build Status](https://travis-ci.com/a2stuff/basys33.svg?branch=main)](https://travis-ci.com/a2stuff/basys33)

💾 Disk images can be found on the [Releases](https://github.com/a2stuff/basis33/releases) page 💾


## Background

[ProDOS 2.4](https://prodos8.com/) includes the [Bitsy Bye](https://prodos8.com/bitsy-bye/) program launcher. It can launch System (SYS), Binary (BIN) and BASIC (BAS) files. For other file types, if there's a `BASIS.SYSTEM` handler in the root volume, it is invoked to handle the file.

[DOS 3.3 Launcher](http://apple2.org.za/gswv/a2zine/Docs/Dos33Launcher_Docs.txt) is a tool to run certain DOS 3.3 games (or more commonly, game cracks) under ProDOS. Launchers must be specially configured to invoke it for these DOS 3.3 files (file types $F1, $F2, $F3, $F4).

## What's this?

This repro includes a `BASIS.SYSTEM` implementation that takes the passed file and invokes `DOS3.3.LAUNCHER` on it. It searches for `DOS3.3.LAUNCHER` starting in the directory containing the DOS 3.3 file, and then upwards. So you can create a disk like this:

* `PRODOS`
* `QUIT.SYSTEM`
* `BASIS.SYSTEM`
* `DOS.GAMES/`
    * `DOS3.3.LAUNCHER`
    * `GAME1`
    * `GAME2`
    * ...

And then Bitsy Bye will be able to launch them.

If invoked on a file type other than $F1...$F4 it will QUIT back to ProDOS.
