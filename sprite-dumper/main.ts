import { Image } from "https://deno.land/x/imagescript@1.2.15/mod.ts";

// Function to render a PNG
async function renderPNG(bytes:string, width: number, height: number, outputPath: string) {
  try {
    // Create a new image with the specified width and height
    const image = new Image(width, height);

    // Iterate over the sectors and set pixel values
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const char = bytes[y * width + x];
        image.setPixelAt(x + 1, y + 1, (PALETTE[char] << 8) | 0xff);
      }
    }

    // Encode the image as a PNG
    const png = await image.scale(4).encode();

    // Write the PNG to a file
    await Deno.writeFile(outputPath, png);
  } catch (error) {
    console.debug(bytes, width, height, outputPath);
    console.log(error);
  }
}

const PALETTE = [
  0x000000,
  0xffffff,
  0x00d95f,
  0x00765f,
  0xff2600,
  0xffff00,
  0x26515f,
  0x00aeff,
  0x895100,
  0x0051a0,
  0xae765f,
  0x265100,
  0xff7600,
  0x8989a0,
  0x512600,
  0xff895f,
];

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

function isOp(token: string) {
  return Object.keys(OPS).includes(token);
}

const TOKEN = {
  COMMENT: ';',
};

type Label = string;

type Lines = string[];

type Sector = {
  start: number;
  end: number;
  lines: Lines;
  block: any;
}

function parseLiteral(literal: string, sectors: Map<Label, Sector>): number | string {
  let value: string | number = Number.parseInt(literal);
  if (Number.isNaN(value)) {
    value = literal;
    if (literal.startsWith('$')) {
      value = Number.parseInt(literal.slice(1), 16);
    }
    if (literal.startsWith('%')) {
      value = Number.parseInt(literal.slice(1), 2);
    }
  }
  const sector = sectors.get(literal);
  if (sector) {
    // @ts-ignore
    return parseSector(sector, sectors);
  }
  return value;
}

function parseExpression(expression: string, sectors: Map<Label, Sector>): number | string {
  const plusIndex = expression.indexOf('+');
  if (plusIndex > -1) {
    const a = parseExpression(expression.slice(0, plusIndex), sectors);
    const b = parseExpression(expression.slice(plusIndex + 1), sectors);
    // @ts-ignore
    return a + b;
  }
  const minusIndex = expression.indexOf('-');
  if (minusIndex > -1) {
    const a = parseExpression(expression.slice(0, minusIndex), sectors);
    const b = parseExpression(expression.slice(minusIndex + 1), sectors);
    // @ts-ignore
    return a - b;
  }
  return parseLiteral(expression, sectors);
}

function parseSector(sector: Sector, sectors: Map<Label, Sector>) {
  if (sector.block) {
    return sector.block;
  }
  const values = [];
  for (const line of sector.lines) {
    const tokens = line.split(/\s+/);
    const [first] = tokens;
    // If not an operation, remove the label
    if (!isOp(first)) {
      tokens.shift();
    }
    // Parse the operation
    const [op, args] = tokens;
    switch(op) {
      case OPS.FDB:
      case OPS.FCB:
      case OPS.EQU:
        values.push(...args.split(',').map((arg) => {
          const parsed = parseExpression(arg, sectors);
          return parsed;
        }));
        break;
    }
  }
  if (values.length > 1) {
    sector.block = values;
  } else {
    sector.block = values[0];
  }
  return sector.block;
}

function decimalToSegments(decimal: number, bits: number = 8, width: number = 2): number[] {
  const segments = [];
  const size = (1 << bits) - 1;
  let value = decimal;
  for (let i = 0; i < width; i++) {
    segments.push(value & size);
    value = value >> bits;
  }
  return segments.reverse();
}

function extractSprite(sector: Sector, size: number = 2) {
  if (sector.lines[sector.lines.length - 1].endsWith('!DMAFIX')) {
    const [dimensions] = sector.block.slice(-1);
    const [width, height] = decimalToSegments(dimensions, 8);
    const [bitmap] = sector.block.filter(Array.isArray).slice(-1);
    // @ts-ignore
    const colors = bitmap.map((value) => decimalToSegments(value, 4, size)).flat();
    return {
      colors,
      width,
      height,
    };
  }
}

async function loadFile() {
  const asm = await Deno.readTextFile("../src/rewrite/JOUSTI.ASM");
  const lines = asm
    .split(/[\n\r]/)
    .filter((line) => !line.startsWith(TOKEN.COMMENT) && line.length > 0)
    .map((line) => line.split(new RegExp(`\s*${TOKEN.COMMENT}`))[0].trim().split(/\s+/).join(' '));

  // Debugging
  await Deno.writeTextFile("../src/rewrite/JOUSTI-NORMALIZED.ASM", lines.join("\n"));

  const sectors = new Map<Label, Sector>();

  let lastLabel = null;
  for (const [index, line] of lines.entries()) {
    const tokens = line.trim().split(/\s+/);
    const [first] = tokens;
    if (!Object.keys(OPS).includes(first)) {
      const sector = {
        start: index,
        end: lines.length - 1,
        lines: [],
        block: null,
      };
      sectors.set(first, sector);
      if (lastLabel) {
        const lastSector = sectors.get(lastLabel);
        if (lastSector) {
          lastSector.end = sector.start - 1;
          lastSector.lines = lines.slice(lastSector.start, lastSector.end + 1);
        }
      }
      lastLabel = first;
    }
  }

  for (const [label, sector] of sectors.entries()) {
    try {
      parseSector(sector, sectors);
    } catch (error) {
      console.error(label, error);
    }
    // value.sprite = bytes;
    // value.width = width;
    // value.height = bytes.length;
    // if (value.width > 0 && value.height > 0) {
    //   renderPNG(
    //     value.sprite,
    //     value.width,
    //     value.height,
    //     `./${key}.png`
    //   )
    // }
  }

  // _CLIF1L
  // const sector = sectors.get('_CLIF3L');
  // if (sector) {
  //   // @ts-ignore
  //   const { colors, width, height } = extractSprite(sector);
  //   console.log(colors, width, height);
  // }

  const sector = sectors.get('_COMCL5');
  if (sector) {
    const size = 2;
    // @ts-ignore
    const colors = sector.block.map((value) => decimalToSegments(value, 3, size)).flat();
    const width = 60;
    const height = 33;
    renderPNG(colors, width * 2, height, `./_COMCL5.png`);
  }

  const sector = sectors.get('_CLIF5');
  if (sector) {
    // @ts-ignore
    const parts = {
      CSRC5: sector.block.slice(4, 7),
      CSRC5L: sector.block.slice(7, 10),
      CSRC5R: sector.block.slice(10, 13),
    };
    for (const [label, block] of Object.entries(parts)) {
      const [bitmap, position, dimensions] = block;
      // @ts-ignore
      const colors = bitmap.map((value) => decimalToSegments(value, 4, 2)).flat();
      const [width, height] = decimalToSegments(dimensions, 8);
      renderPNG(colors, width * 2, height, `./${label}.png`);
    }
  }

  for (const [label, sector] of sectors.entries().filter(([label]) => label.startsWith('_'))) {
    // @ts-ignore
    if (sector.lines[sector.lines.length - 1].endsWith('!DMAFIX')) {
      // @ts-ignore
      const { colors, width, height } = extractSprite(sector, ['_CLIF1R', '_CLIF3R', '_TRANS1', '_TRANS2', '_TRANS3', '_TRANS4'].includes(label) ? 4 : 2);
      renderPNG(colors, width * 2, height, `./${label}.png`);
    }
  }

}

loadFile();
