fn main() {
    // NOTE: the cfg!() macro is evaluated against the HOST platform, not the
    // target platform being compiled for. When cross-compiling (e.g. building
    // x86_64-pc-windows-msvc from a Linux host) this selected the wrong
    // backend. Use CARGO_CFG_TARGET_OS, which Cargo provides to build scripts
    // precisely for this purpose.
    let target_os =
        std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();

    if target_os == "windows" {
        // The first choice is Windows because DXGI is amazing.
        println!("cargo:rustc-cfg=dxgi");
    } else if target_os == "macos" {
        // Quartz is second because macOS is the (annoying) exception.
        println!("cargo:rustc-cfg=quartz");
    } else {
        // On UNIX we pray that X11 (with XCB) is available.
        println!("cargo:rustc-cfg=x11");
    }
}
