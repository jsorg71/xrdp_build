const std = @import("std");

pub fn build(b: *std.Build) void {
    // build options
    var do_strip: bool = false;
    if (b.option(bool, "strip", "strip the executabes") orelse false) {
        do_strip = true;
    }
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // tomlc99
    const libtomlc = b.addSharedLibrary(.{
        .name = "tomlc",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libtomlc.linkLibC();
    libtomlc.defineCMacro("HAVE_CONFIG_H", "1");
    libtomlc.defineCMacro("CONFIG_AC_H", "1");
    libtomlc.addIncludePath(b.path("."));
    libtomlc.addCSourceFiles(.{ .files = libtomlc_sources });
    // libcommon
    const libcommon = b.addSharedLibrary(.{
        .name = "common",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libcommon.linkLibC();
    libcommon.defineCMacro("HAVE_CONFIG_H", "1");
    libcommon.defineCMacro("CONFIG_AC_H", "1");
    libcommon.addIncludePath(b.path("."));
    libcommon.addCSourceFiles(.{ .files = libcommon_sources });
    libcommon.linkSystemLibrary("crypto");
    libcommon.linkSystemLibrary("ssl");
    // libxrdp
    const libxrdp = b.addSharedLibrary(.{
        .name = "xrdp",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libxrdp.linkLibC();
    libxrdp.defineCMacro("HAVE_CONFIG_H", "1");
    libxrdp.defineCMacro("CONFIG_AC_H", "1");
    libxrdp.addIncludePath(b.path("."));
    libxrdp.addIncludePath(b.path("xrdp/common"));
    libxrdp.addCSourceFiles(.{ .files = libxrdp_sources });
    // libipm
    const libipm = b.addSharedLibrary(.{
        .name = "ipm",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libipm.linkLibC();
    libipm.defineCMacro("HAVE_CONFIG_H", "1");
    libipm.defineCMacro("CONFIG_AC_H", "1");
    libipm.addIncludePath(b.path("."));
    libipm.addIncludePath(b.path("xrdp/common"));
    libipm.addCSourceFiles(.{ .files = libipm_sources });
    // librfxencode
    const librfxencode = b.addStaticLibrary(.{
        .name = "rfxencode",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    librfxencode.linkLibC();
    librfxencode.defineCMacro("HAVE_CONFIG_H", "1");
    librfxencode.defineCMacro("CONFIG_AC_H", "1");
    librfxencode.addIncludePath(b.path("."));
    librfxencode.addIncludePath(b.path("xrdp/librfxcodec/src"));
    librfxencode.addIncludePath(b.path("xrdp/librfxcodec/include"));
    librfxencode.addIncludePath(b.path("xrdp/librfxcodec/src/sse2"));
    librfxencode.addCSourceFiles(.{ .files = librfxencode_sources });
    if (target.result.cpu.arch == std.Target.Cpu.Arch.x86) {
        librfxencode.defineCMacro("RFX_USE_ACCEL_X86", "1");
        addNasmFiles(librfxencode, .{
            .flags = librfxencode_asm_x86_flags,
            .files = librfxencode_asm_x86_sources,
        });
    } else if (target.result.cpu.arch == std.Target.Cpu.Arch.x86_64) {
        librfxencode.defineCMacro("RFX_USE_ACCEL_AMD64", "1");
        addNasmFiles(librfxencode, .{
            .flags = librfxencode_asm_x86_64_flags,
            .files = librfxencode_asm_x86_64_sources,
        });
    } else if (target.result.cpu.arch == std.Target.Cpu.Arch.arm) {
    }
    // xrdp
    const xrdp = b.addExecutable(.{
        .name = "xrdp",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    xrdp.linkLibC();
    xrdp.defineCMacro("HAVE_CONFIG_H", "1");
    xrdp.defineCMacro("CONFIG_AC_H", "1");
    xrdp.defineCMacro("XRDP_RFXCODEC", "1");
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
    xrdp.linkLibrary(librfxencode);
    xrdp.linkSystemLibrary("x264");
    // waitforx
    const waitforx = b.addExecutable(.{
        .name = "waitforx",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    waitforx.linkLibC();
    waitforx.defineCMacro("HAVE_CONFIG_H", "1");
    waitforx.defineCMacro("CONFIG_AC_H", "1");
    waitforx.addIncludePath(b.path("."));
    waitforx.addIncludePath(b.path("xrdp/common"));
    waitforx.addIncludePath(b.path("xrdp/sesman/sesexec"));
    waitforx.addCSourceFiles(.{ .files = waitforx_sources });
    waitforx.linkLibrary(libcommon);
    waitforx.linkSystemLibrary("x11");
    waitforx.linkSystemLibrary("xrandr");
    // keygen
    const keygen = b.addExecutable(.{
        .name = "xrdp-keygen",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    keygen.linkLibC();
    keygen.defineCMacro("HAVE_CONFIG_H", "1");
    keygen.defineCMacro("CONFIG_AC_H", "1");
    keygen.addIncludePath(b.path("."));
    keygen.addIncludePath(b.path("xrdp/common"));
    keygen.addCSourceFiles(.{ .files = keygen_sources });
    keygen.linkLibrary(libcommon);
    // libsesman
    const libsesman = b.addSharedLibrary(.{
        .name = "sesman",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libsesman.linkLibC();
    libsesman.defineCMacro("HAVE_CONFIG_H", "1");
    libsesman.defineCMacro("CONFIG_AC_H", "1");
    libsesman.addIncludePath(b.path("."));
    libsesman.addIncludePath(b.path("xrdp/common"));
    libsesman.addIncludePath(b.path("xrdp/libipm"));
    libsesman.addCSourceFiles(.{ .files = libsesman_sources });
    libsesman.linkSystemLibrary("pam");
    // sesman
    const sesman = b.addExecutable(.{
        .name = "xrdp-sesman",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    sesman.linkLibC();
    sesman.defineCMacro("HAVE_CONFIG_H", "1");
    sesman.defineCMacro("CONFIG_AC_H", "1");
    sesman.addIncludePath(b.path("."));
    sesman.addIncludePath(b.path("xrdp/common"));
    sesman.addIncludePath(b.path("xrdp/libipm"));
    sesman.addIncludePath(b.path("xrdp/sesman/libsesman"));
    sesman.addCSourceFiles(.{ .files = sesman_sources });
    sesman.linkLibrary(libcommon);
    sesman.linkLibrary(libsesman);
    sesman.linkLibrary(libipm);

    b.installArtifact(libtomlc);
    b.installArtifact(libcommon);
    b.installArtifact(libxrdp);
    b.installArtifact(libipm);
    b.installArtifact(librfxencode);
    b.installArtifact(xrdp);
    b.installArtifact(waitforx);
    b.installArtifact(keygen);
    b.installArtifact(libsesman);
    b.installArtifact(sesman);

}

const AddNasmFilesOptions = struct {
    files: []const []const u8,
    flags: []const []const u8 = &.{},
};

fn addNasmFiles(compile: *std.Build.Step.Compile, options: AddNasmFilesOptions) void {
    const b = compile.step.owner;
    //const root = options.root orelse b.path("");
    for (options.files) |file| {
        const src_file = file;
        const file_stem = std.mem.sliceTo(file, '.');
        const nasm = b.addSystemCommand(&.{"yasm"});
        nasm.addArgs(options.flags);
        const obj = nasm.addPrefixedOutputFileArg("-o", b.fmt("{s}.o", .{file_stem}));
        nasm.addFileArg(b.path(src_file));
        compile.addObjectFile(obj);
    }
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
    "xrdp/common/trans.c",
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

const librfxencode_sources = &.{
    "xrdp/librfxcodec/src/rfxencode.c",
    "xrdp/librfxcodec/src/rfxencode_rgb_to_yuv.c",
    "xrdp/librfxcodec/src/rfxencode_dwt_shift_rem.c",
    "xrdp/librfxcodec/src/rfxencode_compose.c",
    "xrdp/librfxcodec/src/rfxencode_tile.c",
    "xrdp/librfxcodec/src/rfxencode_rlgr1.c",
    "xrdp/librfxcodec/src/rfxencode_rlgr3.c",
    "xrdp/librfxcodec/src/rfxencode_differential.c",
    "xrdp/librfxcodec/src/rfxencode_diff_rlgr1.c",
    "xrdp/librfxcodec/src/rfxencode_diff_rlgr3.c",
    "xrdp/librfxcodec/src/rfxencode_quantization.c",
    "xrdp/librfxcodec/src/rfxencode_dwt.c",
    "xrdp/librfxcodec/src/rfxencode_alpha.c",
    // sse2
    "xrdp/librfxcodec/src/sse2/rfxencode_diff_count_sse2.c",
    "xrdp/librfxcodec/src/sse2/rfxencode_dwt_shift_rem_sse2.c",
    // amd64
    "xrdp/librfxcodec/src/amd64/rfxencode_tile_amd64.c",
};

const librfxencode_asm_x86_flags = &.{
    "-felf", "-DELF", "-D__x86__", "-Ixrdp/librfxcodec/src",
};

const librfxencode_asm_x86_sources = &.{
    "xrdp/librfxcodec/src/amd64/cpuid_x86.asm",
    "xrdp/librfxcodec/src/amd64/rfxcodec_encode_dwt_shift_x86_sse2.asm",
    "xrdp/librfxcodec/src/amd64/rfxcodec_encode_dwt_shift_x86_sse41.asm",
};

const librfxencode_asm_x86_64_flags = &.{
    "-felf64", "-DELF", "-D__x86_64__", "-Ixrdp/librfxcodec/src",
};

const librfxencode_asm_x86_64_sources = &.{
    "xrdp/librfxcodec/src/amd64/cpuid_amd64.asm",
    "xrdp/librfxcodec/src/amd64/rfxcodec_encode_dwt_shift_amd64_sse2.asm",
    "xrdp/librfxcodec/src/amd64/rfxcodec_encode_dwt_shift_amd64_sse41.asm",
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

const waitforx_sources = &.{
    "xrdp/waitforx/waitforx.c",
};

const keygen_sources = &.{
    "xrdp/keygen/keygen.c",
};

const libsesman_sources = &.{
    "xrdp/sesman/libsesman/sesman_access.c",
    "xrdp/sesman/libsesman/sesman_clip_restrict.c",
    "xrdp/sesman/libsesman/sesman_config.c",
    "xrdp/sesman/libsesman/verify_user_pam.c",
};

const sesman_sources = &.{
    "xrdp/sesman/eicp_process.c",
    "xrdp/sesman/ercp_process.c",
    "xrdp/sesman/lock_uds.c",
    "xrdp/sesman/pre_session_list.c",
    "xrdp/sesman/scp_process.c",
    "xrdp/sesman/sesexec_control.c",
    "xrdp/sesman/sesman.c",
    "xrdp/sesman/session_list.c",
    "xrdp/sesman/sig.c",
};
