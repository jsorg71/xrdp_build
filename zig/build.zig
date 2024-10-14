
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const xrdp = b.addExecutable(.{
        .name = "xrdp",
        .target = target,
        .optimize = optimize,
        } );
    xrdp.addCSourceFile(.{
        .file = b.path("xrdp/xrdp/xrdp.c"),
        .flags = &.{
            "-Wall",
            "-O2",
            "-I.",
            "-Ixrdp/common",
            "-Ixrdp/libxrdp",
            "-Ixrdp/third_party",
            "-DCONFIG_AC_H",
            "-DHAVE_CONFIG_H",
            }
        } );
    xrdp.linkLibC();
    b.installArtifact(xrdp);
}
