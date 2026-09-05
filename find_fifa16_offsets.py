#!/usr/bin/env python3
"""
FIFA 16 Offset Scanner & Local FUT Configurator
Scans fifa16.exe to detect ProtoSSLConnect offset and automatically generates
compatible EA-MITM.ini and cl.ini configurations.
"""
from __future__ import annotations

import argparse
import os
import struct
import sys
from pathlib import Path


def parse_pe_sections(data: bytes):
    if len(data) < 0x200 or data[:2] != b"MZ":
        raise ValueError("Not a valid PE file (missing MZ header)")
    e_lfanew = struct.unpack_from("<I", data, 0x3c)[0]
    if data[e_lfanew:e_lfanew+4] != b"PE\x00\x00":
        raise ValueError("Invalid PE signature")
    magic = struct.unpack_from("<H", data, e_lfanew + 0x18)[0]
    is_pe32_plus = (magic == 0x20b)
    if not is_pe32_plus:
        raise ValueError("FIFA 16 requires a 64-bit (PE32+) executable")

    num_sections = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_header_size = struct.unpack_from("<H", data, e_lfanew + 0x14)[0]
    sec_offset = e_lfanew + 0x18 + opt_header_size
    image_base = struct.unpack_from("<Q", data, e_lfanew + 0x30)[0]

    sections = []
    for i in range(num_sections):
        offset = sec_offset + i * 40
        name = data[offset:offset+8].rstrip(b"\x00").decode("latin1", errors="ignore")
        vsize, vaddr, rsize, raddr = struct.unpack_from("<IIII", data, offset + 8)
        sections.append({
            "name": name,
            "vaddr": vaddr,
            "vsize": vsize,
            "raddr": raddr,
            "rsize": rsize
        })
    return image_base, sections


def scan_executable(exe_path: Path):
    print(f"Scanning: {exe_path} ({exe_path.stat().st_size:,} bytes)")
    data = exe_path.read_bytes()
    image_base, sections = parse_pe_sections(data)
    print(f"  ImageBase: 0x{image_base:016X}")

    text_sec = next((s for s in sections if s["name"].lower() in (".text", "code")), None)
    if not text_sec:
        text_sec = sections[0]
    print(f"  Scanning code section '{text_sec['name']}' (0x{text_sec['vaddr']:X} - 0x{text_sec['vaddr']+text_sec['vsize']:X})...")

    text_bytes = data[text_sec["raddr"]:text_sec["raddr"] + text_sec["rsize"]]

    # ProtoSSLConnect prologue in MSVC 64-bit:
    # 55          push rbp
    # 56          push rsi
    # 57          push rdi
    # 48 83 ec 30 sub rsp, 0x30
    prologue = bytes([0x55, 0x56, 0x57, 0x48, 0x83, 0xEC, 0x30])

    candidates = []
    idx = 0
    while True:
        pos = text_bytes.find(prologue, idx)
        if pos == -1:
            break
        rva = text_sec["vaddr"] + pos
        va = image_base + rva
        candidates.append((pos, rva, va))
        idx = pos + 1

    print(f"  Found {len(candidates)} prologue candidate(s).")

    best_candidate = None
    target_strings = [b"protossl", b"ProtoSSL", b"gosredirector", b"easw.easports.com"]
    string_positions = []
    for s in target_strings:
        p = 0
        while True:
            pos = data.find(s, p)
            if pos == -1:
                break
            string_positions.append(pos)
            p = pos + len(s)

    print(f"  Found {len(string_positions)} network string reference(s) in executable.")

    if len(candidates) == 1:
        best_candidate = candidates[0]
    elif len(candidates) > 1:
        best_score = -1
        for pos, rva, va in candidates:
            score = 0
            chunk = text_bytes[pos:pos+256]
            if b"\x48\x8d" in chunk:
                score += 1
            if b"\xe8" in chunk:
                score += 1
            if score > best_score:
                best_score = score
                best_candidate = (pos, rva, va)
        if not best_candidate:
            best_candidate = candidates[0]
    else:
        print("  Notice: Direct prologue signature not found (binary may be packed or encrypted).")
        print("  Using default FIFA 16 ProtoSSL entry.")
        best_candidate = (0, 0x3066524, image_base + 0x3066524)

    chosen_rva = best_candidate[1]
    chosen_va = best_candidate[2]
    print(f"  Selected ProtoSSLConnect VA: 0x{chosen_va:016X} (RVA: 0x{chosen_rva:08X})")
    return image_base, chosen_rva, chosen_va


def generate_configs(output_dir: Path, va: int, host: str = "127.0.0.1"):
    mitm_content = f"""; FIFA 16 Local FUT - generated localhost routing
[Hook]
InitDelay=3000

[Origin]
LaunchFailureCheckRva=0

[ProtoSSL]
Connect=0x{va:016X}
Send=0
Recv=0

[Redirect]
Count=8

Redirect.0.Hostname=spring14.gosredirector.ea.com
Redirect.0.Address={host}
Redirect.0.Port=42230
Redirect.0.Secure=0

Redirect.1.Hostname=spring15.gosredirector.ea.com
Redirect.1.Address={host}
Redirect.1.Port=42230
Redirect.1.Secure=0

Redirect.2.Hostname=gosredirector.ea.com
Redirect.2.Address={host}
Redirect.2.Port=42230
Redirect.2.Secure=0

Redirect.3.Hostname={host}
Redirect.3.SourcePort=10051
Redirect.3.Address={host}
Redirect.3.Port=10051
Redirect.3.Secure=0

Redirect.4.Hostname={host}
Redirect.4.SourcePort=17502
Redirect.4.Address={host}
Redirect.4.Port=17502
Redirect.4.Secure=0

Redirect.5.Hostname={host}
Redirect.5.SourcePort=42232
Redirect.5.Address={host}
Redirect.5.Port=42232
Redirect.5.Secure=0

Redirect.6.Hostname={host}
Redirect.6.SourcePort=8199
Redirect.6.Address={host}
Redirect.6.Port=8199
Redirect.6.Secure=0

Redirect.7.Hostname={host}
Redirect.7.SourcePort=8099
Redirect.7.Address={host}
Redirect.7.Port=8099
Redirect.7.Secure=0
"""
    cl_content = f"""; FIFA 16 Local FUT - generated localhost routing
FUT_ENABLE_MENU = 1
FUT_TARGET_HOSTNAME = {host}
FUT_TARGET_PORT = 8099
FUT_RS4_BASE_URL = http://{host}:8099/
FIFA_POW_NUCLEUS_PROXY_URL = http://{host}:8099/
"""
    (output_dir / "EA-MITM.ini").write_text(mitm_content, encoding="utf-8")
    (output_dir / "cl.ini").write_text(cl_content, encoding="utf-8")
    print(f"Generated: {output_dir / 'EA-MITM.ini'}")
    print(f"Generated: {output_dir / 'cl.ini'}")


def main():
    parser = argparse.ArgumentParser(description="FIFA 16 Offset Scanner & Configurator")
    parser.add_argument("--exe", help="Path to fifa16.exe")
    parser.add_argument("--output-dir", default=".", help="Directory to write EA-MITM.ini and cl.ini")
    args = parser.parse_args()

    exe_path = None
    if args.exe:
        exe_path = Path(args.exe)
    else:
        for c in (Path("fifa16.exe"), Path("Game/fifa16.exe"), Path("../fifa16.exe")):
            if c.is_file():
                exe_path = c
                break

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    if exe_path and exe_path.is_file():
        base, rva, va = scan_executable(exe_path)
    else:
        print("Notice: fifa16.exe not found in current directory; generating default FIFA 16 config.")
        print("Run this script with --exe <path-to-fifa16.exe> if your version requires custom offsets.")
        va = 0x0000000143066524

    generate_configs(out_dir, va)
    print("Configuration complete!")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
