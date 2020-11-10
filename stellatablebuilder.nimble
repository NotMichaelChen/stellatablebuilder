# Package

version       = "0.1.0"
author        = "NotMichaelChen"
description   = "Builds extra tables based on Stella/Satellite"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["stellatablebuilder"]

# Dependencies

requires "nim >= 1.2.0"
requires "bmslib 0.1.0"
requires "simpleparseopt 1.1.0"