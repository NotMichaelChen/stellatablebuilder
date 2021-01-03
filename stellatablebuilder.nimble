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
requires "https://github.com/NotMichaelChen/bmslib#5aa4ca6af8eb87b88a62e0ebc3b2804a419c1893"
requires "simpleparseopt 1.1.0"