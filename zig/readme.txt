This is the zig build for xrdp
using zig 0.13.0 at this time
example command line
zig build -Dtarget=x86_64-native -Doptimize=ReleaseFast --summary all
cross compile with
zig build -Dtarget=arm-linux-gnueabihf -Doptimize=ReleaseFast --summary all
