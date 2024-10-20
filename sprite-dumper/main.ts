import { Image } from "https://deno.land/x/imagescript@1.2.15/mod.ts";

// Function to render a PNG
async function renderPNG(sprite:string[], width: number, height: number, outputPath: string) {
  try {
    // Create a new image with the specified width and height
    const image = new Image(width, height);

    // Iterate over the labels and set pixel values
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const char = sprite[y][x] as keyof typeof PALETTE;
        image.setPixelAt(x + 1, y + 1, (PALETTE[char] << 8) | 0xFF);
      }
    }

    // Encode the image as a PNG
    const png = await image.scale(4).encode();

    // Write the PNG to a file
    await Deno.writeFile(outputPath, png);
  } catch (error) {
    console.debug(sprite, width, height, outputPath);
    console.log(error);
  }
}

const PALETTE = {
  '0': 0x000000,
  '1': 0xffffff,
  '2': 0x00d95f,
  '3': 0x00765f,
  '4': 0xff2600,
  '5': 0xffff00,
  '6': 0x26515f,
  '7': 0x00aeff,
  '8': 0x895100,
  '9': 0x0051a0,
  'A': 0xae765f,
  'B': 0x265100,
  'C': 0xff7600,
  'D': 0x8989a0,
  'E': 0x512600,
  'F': 0xff895f,
}

const OPS = {
  ENDIF: 'ENDIF',
  ENDM: 'ENDM',
  EQU: 'EQU',
  FCB: 'FCB',
  FCC: 'FCC',
  FDB: 'FDB',
  IF: 'IF',
  MACRO: 'MACRO',
  ORG: 'ORG',
};

const TOKEN = {
  COMMENT: ';',
};

async function loadFile() {
  try {
    const sequences = new Map();
    const labels = new Map();
    const asm = await Deno.readTextFile("../src/rewrite/JOUSTI.ASM");
    const lines = asm.split("\n").filter((line) => !line.startsWith(TOKEN.COMMENT));
    await Deno.writeTextFile("../src/rewrite/NOCOM-JOUSTI.ASM", lines.join("\n"));
    let lastLabel;
    for (const [index, line] of lines.entries()) {
      const tokens = line.trim().split(/\s+/);
      const [first, second] = tokens;
      switch (first) {
        case OPS.FDB:
          if (second.startsWith('_')) {
            sequences.set(second, {});
          }
          break;
        case OPS.ENDIF:
        case OPS.ENDM:
        case OPS.EQU:
        case OPS.FCB:
        case OPS.FCC:
        case OPS.IF:
        case OPS.MACRO:
        case OPS.ORG:
          break;
        default:
          switch (true) {
            case first.startsWith(TOKEN.COMMENT):
            case first.length === 0:
              break;
            default: {
              const sector = {
                start: index,
                last: null,
              };
              labels.set(first, sector);
              if (lastLabel) {
                labels.get(lastLabel).last = sector.start - 1;
              }
              lastLabel = first;
              break;
            }
        }
      }
    }
    for (const [key, value] of labels.entries()) {
      const bytes = [];
      const { start, last } = value;
      let width = 0;
      for (const line of lines.slice(start, last + 1)) {
        const tokens = line.trim().split(/\s+/);
        const [first, second] = tokens;
        if (first === OPS.FCB) {
          const segment = second.replace(/[$,]/g, '');
          width = Math.max(width, segment.length)
          bytes.push(segment);
        }
      }
      value.sprite = bytes;
      value.width = width;
      value.height = bytes.length;
      if (value.width > 0 && value.height > 0) {
        renderPNG(
          value.sprite,
          value.width,
          value.height,
          `./${key}.png`
        )
      }
    }
  } catch (error) {
    console.error("Error reading the file:", error);
  }
}

loadFile();
