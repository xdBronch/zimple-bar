## Build instructions (likely to change or break in the future)
```
git clone https://github.com/xdBronch/zimple-bar.git
cd zimple-bar
zig build -Doptimize=ReleaseFast
```
This will create ``zbar`` in zig-out/bin. By default it uses the CPU and GPU file paths that I use but yours may be different, specify them with ``-Dcpu_path=<your_path>`` and ``-Dgpu_path=<your path>`` during the build process.
Using ReleaseSmall may be a better choice as it is smaller in storage and ram usage but I doubt it makes any real difference, see all options with ``zig build --help``
