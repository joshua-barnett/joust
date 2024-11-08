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

function decimalToSegments(decimal: number, bits: number = 8): number[] {
  const segments = [];
  const size = (1 << bits) - 1;
  let value = decimal;
  while (value > 0) {
    segments.push(value & size);
    value = value >> bits;
  }
  return segments;
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
  const sector = sectors.get('_CLIF1L');
  const parts = sector.block.slice(1);
  debugger

  // for (const [label, sector] of sectors.entries().filter(([label]) => label.startsWith('_'))) {
  //   // @ts-ignore
  //   if (sector.lines[sector.lines.length - 1].endsWith('!DMAFIX')) {
  //     const last = sector.block.pop();
  //     const [height, width] = decimalToSegments(last, 8);
  //     let x, y;
  //     let next = sector.block.pop();
  //     if (!Array.isArray(next)) {
  //       // @ts-ignore
  //       ([y, x] = decimalToSegments(next, 8));
  //       next = sector.block.pop();
  //     }
  //     // @ts-ignore
  //     const colors = next.map((value) => decimalToSegments(value, 4)).flat();
  //     renderPNG(colors, width * 2, height, `./${label}.png`);
  //   }
  //   // if (Array.isArray(sector.block) && sector.block.every((value) => Number.isInteger(value))) {
  //   //   const [size] = sector.block;
  //   //   const segments = decimalTo16BitSegments(size);
  //   //   console.log(label, sector.block);
  //   // }
  // }
}

loadFile();
