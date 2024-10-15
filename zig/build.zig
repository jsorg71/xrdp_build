
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // tomlc99
    const libtomlc = b.addStaticLibrary(.{ .name = "tomlc", .target = target, .optimize = optimize });
    libtomlc.linkLibC();
    libtomlc.defineCMacro("HAVE_CONFIG_H", "1");
    libtomlc.defineCMacro("CONFIG_AC_H", "1");
    libtomlc.addIncludePath(b.path("."));
    libtomlc.addCSourceFiles(.{ .files = libtomlc_sources });
    // libcommon
    const libcommon = b.addSharedLibrary(.{ .name = "common", .target = target, .optimize = optimize });
    libcommon.linkLibC();
    libcommon.defineCMacro("HAVE_CONFIG_H", "1");
    libcommon.defineCMacro("CONFIG_AC_H", "1");
    libcommon.addIncludePath(b.path("."));
    libcommon.addCSourceFiles(.{ .files = libcommon_sources });
    // libxrdp
    const libxrdp = b.addSharedLibrary(.{ .name = "xrdp", .target = target, .optimize = optimize });
    libxrdp.linkLibC();
    libxrdp.defineCMacro("HAVE_CONFIG_H", "1");
    libxrdp.defineCMacro("CONFIG_AC_H", "1");
    libxrdp.addIncludePath(b.path("."));
    libxrdp.addIncludePath(b.path("xrdp/common"));
    libxrdp.addCSourceFiles(.{ .files = libxrdp_sources });
    // libipm
    const libipm = b.addSharedLibrary(.{ .name = "ipm", .target = target, .optimize = optimize });
    libipm.linkLibC();
    libipm.defineCMacro("HAVE_CONFIG_H", "1");
    libipm.defineCMacro("CONFIG_AC_H", "1");
    libipm.addIncludePath(b.path("."));
    libipm.addIncludePath(b.path("xrdp/common"));
    libipm.addCSourceFiles(.{ .files = libipm_sources });
    // xrdp
    const xrdp = b.addExecutable(.{ .name = "xrdp", .target = target, .optimize = optimize  });
    xrdp.linkLibC();
    xrdp.defineCMacro("HAVE_CONFIG_H", "1");
    xrdp.defineCMacro("CONFIG_AC_H", "1");
    xrdp.addIncludePath(b.path("."));
    xrdp.addIncludePath(b.path("xrdp/common"));
    xrdp.addIncludePath(b.path("xrdp/libxrdp"));
    xrdp.addIncludePath(b.path("xrdp/third_party"));
    xrdp.addIncludePath(b.path("xrdp/third_party/tomlc99"));
    xrdp.addIncludePath(b.path("xrdp/libipm"));
    xrdp.addCSourceFiles(.{ .files = xrdp_sources });

    xrdp.linkLibrary(libtomlc);
    xrdp.linkLibrary(libcommon);
    xrdp.linkLibrary(libxrdp);
    xrdp.linkLibrary(libipm);

    xrdp.linkSystemLibrary("crypto");
    xrdp.linkSystemLibrary("ssl");

    b.installArtifact(libtomlc);
    b.installArtifact(libcommon);
    b.installArtifact(libxrdp);
    b.installArtifact(libipm);
    b.installArtifact(xrdp);

}

const libtomlc_sources = &.{
    "xrdp/third_party/tomlc99/toml.c",
    //"xrdp/third_party/tomlc99/toml_cat.c",",
    //"xrdp/third_party/tomlc99/toml_json.c",",
    //"xrdp/third_party/tomlc99/toml_sample.c",
};

const libcommon_sources = &.{
    "xrdp/common/base64.c",
    "xrdp/common/fifo.c",
    "xrdp/common/file.c",
    "xrdp/common/guid.c",
    "xrdp/common/list16.c",
    "xrdp/common/list.c",
    "xrdp/common/log.c",
    "xrdp/common/os_calls.c",
    "xrdp/common/parse.c",
    "xrdp/common/pixman-region16.c",
    //"xrdp/common/pixman-region.c", do not compile directly
    "xrdp/common/scancode.c",
    "xrdp/common/ssl_calls.c",
    "xrdp/common/string_calls.c",
    "xrdp/common/thread_calls.c",
    "xrdp/common/trans.c"
};

const libxrdp_sources = &.{
    "xrdp/libxrdp/libxrdp.c",
    "xrdp/libxrdp/xrdp_bitmap32_compress.c",
    "xrdp/libxrdp/xrdp_bitmap_compress.c",
    "xrdp/libxrdp/xrdp_caps.c",
    "xrdp/libxrdp/xrdp_channel.c",
    "xrdp/libxrdp/xrdp_fastpath.c",
    "xrdp/libxrdp/xrdp_iso.c",
    "xrdp/libxrdp/xrdp_jpeg_compress.c",
    "xrdp/libxrdp/xrdp_mcs.c",
    "xrdp/libxrdp/xrdp_mppc_enc.c",
    "xrdp/libxrdp/xrdp_orders.c",
    "xrdp/libxrdp/xrdp_orders_rail.c",
    "xrdp/libxrdp/xrdp_rdp.c",
    "xrdp/libxrdp/xrdp_sec.c",
    //"xrdp/libxrdp/xrdp_surface.c", not used
};

const libipm_sources = &.{
    "xrdp/libipm/eicp.c",
    "xrdp/libipm/ercp.c",
    "xrdp/libipm/libipm.c",
    "xrdp/libipm/libipm_recv.c",
    "xrdp/libipm/libipm_send.c",
    "xrdp/libipm/scp_application_types.c",
    "xrdp/libipm/scp.c",
};

const xrdp_sources = &.{
    "xrdp/xrdp/funcs.c",
    "xrdp/xrdp/lang.c",
    "xrdp/xrdp/xrdp_bitmap.c",
    "xrdp/xrdp/xrdp_bitmap_common.c",
    "xrdp/xrdp/xrdp_bitmap_load.c",
    "xrdp/xrdp/xrdp.c",
    "xrdp/xrdp/xrdp_cache.c",
    "xrdp/xrdp/xrdp_egfx.c",
    "xrdp/xrdp/xrdp_encoder.c",
    "xrdp/xrdp/xrdp_encoder_x264.c",
    "xrdp/xrdp/xrdp_font.c",
    "xrdp/xrdp/xrdp_listen.c",
    "xrdp/xrdp/xrdp_login_wnd.c",
    "xrdp/xrdp/xrdp_main_utils.c",
    "xrdp/xrdp/xrdp_mm.c",
    "xrdp/xrdp/xrdp_painter.c",
    "xrdp/xrdp/xrdp_process.c",
    "xrdp/xrdp/xrdp_region.c",
    "xrdp/xrdp/xrdp_tconfig.c",
    //"xrdp/xrdp/xrdpwin.c", Windows file
    "xrdp/xrdp/xrdp_wm.c",
};