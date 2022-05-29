# Package

version       = "0.1.0"
author        = "NotMichaelChen"
description   = "Builds extra tables based on Stella/Satellite"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["stellatablebuilder"]

# Dependencies

requires "nim >= 1.6.0"
requires "https://github.com/NotMichaelChen/bmslib#1403a4052d5e9f8f58bb287859de139ab93e4d50"
requires "simpleparseopt 1.1.1"