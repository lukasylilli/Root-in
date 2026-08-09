"""Feature-Grafik 1024x500 fuer den Play Store bauen (PLAN.md Phase 15.2).

Aufruf (zwei Schritte, weil sips das Skalieren uebernimmt):

    sips -c 540 340 meine/Logo.jpeg --out /tmp/fg_crop.png
    sips -s format png -z 360 227 /tmp/fg_crop.png --out /tmp/fg_logo.png
    python3 store/make_feature_graphic.py /tmp/fg_logo.png \
        store/feature_graphic_1024x500.png

Kein ImageMagick/PIL auf dieser Maschine, deshalb PNG von Hand lesen und
schreiben. Das Quell-JPEG hat einen fest eingebrannten weissen Hintergrund —
sips koennte ihn nicht entfernen, hier wird er als Alpha interpretiert:
dunkel = Tinte = deckendes Weiss, hell = Hintergrund = durchsichtig.
"""

import struct
import sys
import zlib


def read_png(path):
    data = open(path, "rb").read()
    pos, idat, w, h, ct = 8, b"", None, None, None
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos : pos + 4])
        ctype = data[pos + 4 : pos + 8]
        chunk = data[pos + 8 : pos + 8 + length]
        if ctype == b"IHDR":
            w, h, _bd, ct = struct.unpack(">IIBB", chunk[:10])
        elif ctype == b"IDAT":
            idat += chunk
        pos += 12 + length

    channels = {0: 1, 2: 3, 4: 2, 6: 4}[ct]
    raw = zlib.decompress(idat)
    stride = w * channels
    prev = bytearray(stride)
    rows = []
    i = 0
    for _ in range(h):
        ftype = raw[i]
        i += 1
        line = bytearray(raw[i : i + stride])
        i += stride
        for x in range(stride):
            a = line[x - channels] if x >= channels else 0
            b = prev[x]
            c = prev[x - channels] if x >= channels else 0
            if ftype == 1:
                line[x] = (line[x] + a) & 255
            elif ftype == 2:
                line[x] = (line[x] + b) & 255
            elif ftype == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif ftype == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pred) & 255
        rows.append(bytes(line))
        prev = line
    return w, h, channels, rows


def write_png(path, width, height, pixels):
    raw = b"".join(b"\x00" + bytes(row) for row in pixels)

    def chunk(tag, payload):
        body = tag + payload
        return struct.pack(">I", len(payload)) + body + struct.pack(
            ">I", zlib.crc32(body) & 0xFFFFFFFF
        )

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    open(path, "wb").write(png)


def main(logo_path, out_path):
    canvas_w, canvas_h = 1024, 500
    bg = (0x2E, 0x7D, 0x5B)  # AppColors.seed
    ink = (0xFF, 0xFF, 0xFF)

    lw, lh, channels, rows = read_png(logo_path)
    off_x = (canvas_w - lw) // 2
    off_y = (canvas_h - lh) // 2

    canvas = [bytearray(bg * canvas_w) for _ in range(canvas_h)]

    for y in range(lh):
        row = rows[y]
        target = canvas[off_y + y]
        for x in range(lw):
            lum = row[x * channels]
            alpha = (255 - lum) / 255.0  # dunkel = deckend
            if alpha <= 0.01:
                continue
            base = (off_x + x) * 3
            for c in range(3):
                target[base + c] = int(
                    ink[c] * alpha + target[base + c] * (1 - alpha)
                )

    write_png(out_path, canvas_w, canvas_h, canvas)
    print(f"geschrieben: {out_path} ({canvas_w}x{canvas_h})")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
