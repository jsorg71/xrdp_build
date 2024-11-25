const std = @import("std");

pub fn build(b: *std.Build) void {
    // build options
    const do_strip = b.option(
        bool,
        "strip",
        "Strip the executabes"
    ) orelse false;
    const use_libpainter = b.option(
        bool,
        "enable-painter",
        "Use included libpainter library (default: yes)"
    ) orelse true;
    const use_librfxcodec = b.option(
        bool,
        "enable-rfxcodec",
        "Use included librfxcodec library (default: yes)"
    ) orelse true;
    const enable_ibus = b.option(
        bool,
        "enable-ibus",
        "Allow unicode input via IBus) (default: no)"
    ) orelse false;
    const enable_fdkaac = b.option(
        bool,
        "enable-fdkaac",
        "Build aac(audio codec) (default: no)"
    ) orelse false;
    const enable_opus = b.option(
        bool,
        "enable-opus",
        "Build opus(audio codec) (default: no)"
    ) orelse false;
    const enable_mp3lame = b.option(
        bool,
        "enable-mp3lame",
        "Build lame mp3(audio codec) (default: no)",
    ) orelse false;
    const enable_pixman = b.option(
        bool,
        "enable-pixman",
        "Use pixman library (default: no)"
    ) orelse false;
    const enable_x264 = b.option(
        bool,
        "enable-x264",
        "Use x264 library (default: no)"
    ) orelse false;
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
    if (!enable_pixman) {
        libcommon.addCSourceFiles(.{ .files = &.{ "xrdp/common/pixman-region16.c", }});
    }
    setExtraLibraryPaths(libcommon, target);
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
    libxrdp.linkLibrary(libcommon);
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
    libipm.linkLibrary(libcommon);
    // libxup
    const libxup = b.addSharedLibrary(.{
        .name = "xup",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libxup.linkLibC();
    libxup.defineCMacro("HAVE_CONFIG_H", "1");
    libxup.defineCMacro("CONFIG_AC_H", "1");
    libxup.addIncludePath(b.path("."));
    libxup.addIncludePath(b.path("xrdp/common"));
    libxup.addCSourceFiles(.{ .files = libxup_sources });
    libxup.linkLibrary(libcommon);
    // libvnc
    const libvnc = b.addSharedLibrary(.{
        .name = "vnc",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libvnc.linkLibC();
    libvnc.defineCMacro("HAVE_CONFIG_H", "1");
    libvnc.defineCMacro("CONFIG_AC_H", "1");
    libvnc.addIncludePath(b.path("."));
    libvnc.addIncludePath(b.path("xrdp/common"));
    libvnc.addCSourceFiles(.{ .files = libvnc_sources });
    libvnc.linkLibrary(libcommon);
    // libmc
    const libmc = b.addSharedLibrary(.{
        .name = "mc",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libmc.linkLibC();
    libmc.defineCMacro("HAVE_CONFIG_H", "1");
    libmc.defineCMacro("CONFIG_AC_H", "1");
    libmc.addIncludePath(b.path("."));
    libmc.addIncludePath(b.path("xrdp/common"));
    libmc.addCSourceFiles(.{ .files = libmc_sources });
    libmc.linkLibrary(libcommon);
    // libxrdpapi
    const libxrdpapi = b.addSharedLibrary(.{
        .name = "xrdpapi",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    libxrdpapi.linkLibC();
    libxrdpapi.defineCMacro("HAVE_CONFIG_H", "1");
    libxrdpapi.defineCMacro("CONFIG_AC_H", "1");
    libxrdpapi.addIncludePath(b.path("."));
    libxrdpapi.addIncludePath(b.path("xrdp/common"));
    libxrdpapi.addCSourceFiles(.{ .files = libxrdpapi_sources });
    libxrdpapi.linkLibrary(libcommon);
    // libpainter
    const libpainter = b.addStaticLibrary(.{
            .name = "painter",
            .target = target,
            .optimize = optimize,
            .strip = do_strip,
        });
    if (use_libpainter) {
        libpainter.linkLibC();
        libpainter.defineCMacro("HAVE_CONFIG_H", "1");
        libpainter.defineCMacro("CONFIG_AC_H", "1");
        libpainter.addIncludePath(b.path("."));
        libpainter.addIncludePath(b.path("xrdp/libpainter/src"));
        libpainter.addIncludePath(b.path("xrdp/libpainter/include"));
        libpainter.addCSourceFiles(.{ .files = libpainter_sources });
    }
    // librfxencode
    const librfxencode = b.addStaticLibrary(.{
            .name = "rfxencode",
            .target = target,
            .optimize = optimize,
            .strip = do_strip,
        });
    if (use_librfxcodec) {
        librfxencode.linkLibC();
        librfxencode.defineCMacro("HAVE_CONFIG_H", "1");
        librfxencode.defineCMacro("CONFIG_AC_H", "1");
        librfxencode.addIncludePath(b.path("."));
        librfxencode.addIncludePath(b.path("xrdp/librfxcodec/src"));
        librfxencode.addIncludePath(b.path("xrdp/librfxcodec/include"));
        librfxencode.addCSourceFiles(.{ .files = librfxencode_sources });
        if (target.result.cpu.arch == std.Target.Cpu.Arch.x86) {
            librfxencode.addCSourceFiles(.{ .files = librfxencode_sse2_sources });
            librfxencode.addCSourceFiles(.{ .files = librfxencode_x86_sources });
            librfxencode.addIncludePath(b.path("xrdp/librfxcodec/src/sse2"));
            librfxencode.defineCMacro("RFX_USE_ACCEL_X86", "1");
            addNasmFiles(librfxencode, .{
                .flags = librfxencode_asm_x86_flags,
                .files = librfxencode_asm_x86_sources,
            });
        } else if (target.result.cpu.arch == std.Target.Cpu.Arch.x86_64) {
            librfxencode.addCSourceFiles(.{ .files = librfxencode_sse2_sources });
            librfxencode.addCSourceFiles(.{ .files = librfxencode_amd64_sources });
            librfxencode.addIncludePath(b.path("xrdp/librfxcodec/src/sse2"));
            librfxencode.defineCMacro("RFX_USE_ACCEL_AMD64", "1");
            addNasmFiles(librfxencode, .{
                .flags = librfxencode_asm_x86_64_flags,
                .files = librfxencode_asm_x86_64_sources,
            });
        } else if (target.result.cpu.arch == std.Target.Cpu.Arch.aarch64) {
            librfxencode.addCSourceFiles(.{ .files = librfxencode_neon_sources });
            librfxencode.addIncludePath(b.path("xrdp/librfxcodec/src/neon"));
            librfxencode.defineCMacro("RFX_USE_ACCEL_ARM64", "1");
        }
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
    xrdp.linkSystemLibrary("x264");
    setExtraLibraryPaths(xrdp, target);
    if (use_libpainter) {
        xrdp.defineCMacro("XRDP_PAINTER", "1");
        xrdp.addIncludePath(b.path("xrdp/libpainter/include"));
        xrdp.linkLibrary(libpainter);
    }
    if (use_librfxcodec) {
        xrdp.defineCMacro("XRDP_RFXCODEC", "1");
        xrdp.addIncludePath(b.path("xrdp/librfxcodec/include"));
        xrdp.linkLibrary(librfxencode);
    }
    if (enable_pixman) {
        xrdp.defineCMacro("XRDP_PIXMAN", "1");
        xrdp.linkSystemLibrary("pixman-1");
    }
    if (enable_x264) {
        xrdp.defineCMacro("XRDP_X264", "1");
        xrdp.linkSystemLibrary("x264");
    }
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
    setExtraLibraryPaths(waitforx, target);
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
    libsesman.linkLibrary(libcommon);
    libsesman.linkSystemLibrary("pam");
    setExtraLibraryPaths(libsesman, target);
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
    // chansrv
    const chansrv = b.addExecutable(.{
        .name = "xrdp-chansrv",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    chansrv.linkLibC();
    chansrv.defineCMacro("HAVE_CONFIG_H", "1");
    chansrv.defineCMacro("CONFIG_AC_H", "1");
    chansrv.addIncludePath(b.path("."));
    chansrv.addIncludePath(b.path("xrdp/common"));
    chansrv.addIncludePath(b.path("xrdp/sesman/libsesman"));
    chansrv.addIncludePath(b.path("xrdp/sesman/chansrv"));
    chansrv.addCSourceFiles(.{ .files = chansrv_sources });
    if (enable_ibus) {
        chansrv.defineCMacro("XRDP_IBUS", "1");
        chansrv.addCSourceFiles(.{ .files = &.{ "xrdp/sesman/chansrv/input_ibus.c", }});
        chansrv.linkSystemLibrary("ibus-1.0");
        chansrv.linkSystemLibrary("glib-2.0");
    }
    if (enable_fdkaac) {
        chansrv.defineCMacro("XRDP_FDK_AAC", "1");
        chansrv.linkSystemLibrary("fdk-aac");
    }
    if (enable_opus) {
        chansrv.defineCMacro("XRDP_OPUS", "1");
        chansrv.linkSystemLibrary("opus");
    }
    if (enable_mp3lame) {
        chansrv.defineCMacro("XRDP_MP3LAME", "1");
        chansrv.linkSystemLibrary("mp3lame");
    }
    chansrv.linkLibrary(libcommon);
    chansrv.linkLibrary(libsesman);
    chansrv.linkSystemLibrary("x11");
    chansrv.linkSystemLibrary("xrandr");
    chansrv.linkSystemLibrary("xfixes");
    setExtraLibraryPaths(chansrv, target);
    // xrdp-dis
    const xrdp_dis = b.addExecutable(.{
        .name = "xrdp-dis",
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
    xrdp_dis.linkLibC();
    xrdp_dis.defineCMacro("HAVE_CONFIG_H", "1");
    xrdp_dis.defineCMacro("CONFIG_AC_H", "1");
    xrdp_dis.addIncludePath(b.path("."));
    xrdp_dis.addIncludePath(b.path("xrdp/common"));
    xrdp_dis.addCSourceFiles(.{ .files = &.{ "xrdp/sesman/tools/dis.c", }});
    xrdp_dis.linkLibrary(libcommon);
    // lib/xrdp
    installLibXrdpArtifact(b, libtomlc);
    installLibXrdpArtifact(b, libcommon);
    installLibXrdpArtifact(b, libxrdp);
    installLibXrdpArtifact(b, libipm);
    installLibXrdpArtifact(b, libsesman);
    installLibXrdpArtifact(b, libxup);
    installLibXrdpArtifact(b, libvnc);
    installLibXrdpArtifact(b, libmc);
    installLibXrdpArtifact(b, libxrdpapi);
    if (use_libpainter) {
        b.installArtifact(libpainter);
    }
    if (use_librfxcodec) {
        b.installArtifact(librfxencode);
    }
    // bin
    b.installArtifact(waitforx);
    b.installArtifact(keygen);
    b.installArtifact(xrdp_dis);
    // sbin
    installSbinArtifact(b, xrdp);
    installSbinArtifact(b, sesman);
    installSbinArtifact(b, chansrv);
}

fn installSbinArtifact(b: *std.Build,
    compile: *std.Build.Step.Compile) void {
    const install = b.addInstallArtifact(compile, .{
        .dest_dir = .{
            .override = .{ .custom = "sbin" },
        },
    });
    b.getInstallStep().dependOn(&install.step);
}

fn installLibXrdpArtifact(b: *std.Build,
    compile: *std.Build.Step.Compile) void {
    const install = b.addInstallArtifact(compile, .{
        .dest_dir = .{
            .override = .{ .custom = "lib/xrdp" },
        },
    });
    b.getInstallStep().dependOn(&install.step);
}

const AddNasmFilesOptions = struct {
    files: []const []const u8,
    flags: []const []const u8,
};

fn addNasmFiles(compile: *std.Build.Step.Compile, options: AddNasmFilesOptions) void {
    const b = compile.step.owner;
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

fn setExtraLibraryPaths(compile: *std.Build.Step.Compile, target: std.Build.ResolvedTarget) void {
    if (target.result.cpu.arch == std.Target.Cpu.Arch.x86) {
        // zig seems to use /usr/lib/x86-linux-gnu instead
        // of /usr/lib/i386-linux-gnu
        compile.addLibraryPath(.{.cwd_relative = "/usr/lib/i386-linux-gnu/"});
    }
}

const libtomlc_sources = &.{
    "xrdp/third_party/tomlc99/toml.c",
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

const libxup_sources = &.{
    "xrdp/xup/xup.c",
};

const libvnc_sources = &.{
    "xrdp/vnc/vnc.c",
    "xrdp/vnc/vnc_clip.c",
    "xrdp/vnc/rfb.c",
};

const libmc_sources = &.{
    "xrdp/mc/mc.c",
};

const libxrdpapi_sources = &.{
    "xrdp/xrdpapi/xrdpapi.c",
};

const libpainter_sources = &.{
    "xrdp/libpainter/src/painter.c",
    "xrdp/libpainter/src/painter_utils.c",
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
};

const librfxencode_neon_sources = &.{
    "xrdp/librfxcodec/src/neon/rfxencode_diff_count_neon.c",
    "xrdp/librfxcodec/src/neon/rfxencode_dwt_shift_rem_neon.c",
};

const librfxencode_sse2_sources = &.{
    "xrdp/librfxcodec/src/sse2/rfxencode_diff_count_sse2.c",
    "xrdp/librfxcodec/src/sse2/rfxencode_dwt_shift_rem_sse2.c",
};

const librfxencode_x86_sources = &.{
    "xrdp/librfxcodec/src/x86/rfxencode_tile_x86.c",
};

const librfxencode_amd64_sources = &.{
    "xrdp/librfxcodec/src/amd64/rfxencode_tile_amd64.c",
};

const librfxencode_asm_x86_flags = &.{
    "-felf", "-DELF", "-D__x86__", "-Ixrdp/librfxcodec/src",
};

const librfxencode_asm_x86_sources = &.{
    "xrdp/librfxcodec/src/x86/cpuid_x86.asm",
    "xrdp/librfxcodec/src/x86/rfxcodec_encode_dwt_shift_x86_sse2.asm",
    "xrdp/librfxcodec/src/x86/rfxcodec_encode_dwt_shift_x86_sse41.asm",
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

const chansrv_sources = &.{
    "xrdp/sesman/chansrv/audin.c",
    "xrdp/sesman/chansrv/chansrv.c",
    "xrdp/sesman/chansrv/chansrv_common.c",
    "xrdp/sesman/chansrv/chansrv_config.c",
    "xrdp/sesman/chansrv/chansrv_fuse.c",
    "xrdp/sesman/chansrv/chansrv_xfs.c",
    "xrdp/sesman/chansrv/clipboard.c",
    "xrdp/sesman/chansrv/clipboard_file.c",
    "xrdp/sesman/chansrv/devredir.c",
    "xrdp/sesman/chansrv/irp.c",
    "xrdp/sesman/chansrv/rail.c",
    "xrdp/sesman/chansrv/smartcard.c",
    "xrdp/sesman/chansrv/smartcard_pcsc.c",
    "xrdp/sesman/chansrv/sound.c",
    "xrdp/sesman/chansrv/xcommon.c",
};
