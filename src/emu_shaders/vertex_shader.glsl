/*

MIT License

Copyright (c) 2022 PCSX-Redux authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#version 330 core

// inPos: The vertex position.
// inColor: The colour in BGR888. Top 8 bits are garbage and are trimmed by the
// vertex shader to conserve CPU time inClut: The CLUT (palette) for textured
// primitives inTexpage: The texpage. We use bit 15 for indicating an untextured
// primitive (1 = untextured). This lets us batch untextured and textured
// primitives together. Bit 15 is unused by hardware, so this is a possible
// optimization inUV: The UVs (texture coordinates) for textured primitives
layout(location = 0) in ivec2 inPos;
layout(location = 1) in uint inColor;
layout(location = 2) in int inClut;
layout(location = 3) in int inTexpage;
layout(location = 4) in vec2 inUV;

out vec4 vertexColor;
out vec2 texCoords;
flat out ivec2 clutBase;
flat out ivec2 texpageBase;
flat out int texMode;

// We always apply a 0.5 offset in addition to the drawing offsets, to cover up
// OpenGL inaccuracies
uniform vec2 u_vertexOffsets = vec2(+0.5, -0.5);

void main() {
    // Normalize coords to [0, 2]
    float x = float(inPos.x);
    float y = float(inPos.y);
    float xx = (x + u_vertexOffsets.x) / 512.0;
    float yy = (y + u_vertexOffsets.y) / 256;
 
    // Normalize to [-1, 1]
    xx -= 1.0;
    yy -= 1.0;
 
    float red = float(inColor & 0xffu);
    float green = float((inColor >> 8u) & 0xffu);
    float blue = float((inColor >> 16u) & 0xffu);
    vec3 color = vec3(red, green, blue);
    gl_Position = vec4(xx, yy, 1.0, 1.0);
    vertexColor = vec4(color / 255.0, 1.0);

    if ((inTexpage & 0x8000) != 0) { // Untextured primitive
        texMode = 4;
    } else {
        texMode = (inTexpage >> 7) & 3;
        texCoords = inUV;
        texpageBase = ivec2((inTexpage & 0xf) * 64, ((inTexpage >> 4) & 0x1) * 256);
        clutBase = ivec2((inClut & 0x3f) * 16, inClut >> 6);
  }
}