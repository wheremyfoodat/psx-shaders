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

uniform sampler2D Texture;
in vec2 Frag_UV;
layout(location = 0) out vec4 Out_Color;

uniform ivec2 u_startCoords;

int floatToU5(float f) {
    return int(floor(f * 31.0 + 0.5));
 }

uint sample16(ivec2 coords) {
    vec4 colour = texelFetch(Texture, coords, 0);
    int r = floatToU5(colour.r);
    int g = floatToU5(colour.g);
    int b = floatToU5(colour.b);
    int msb = int(ceil(colour.a)) << 15;
    return uint(r | (g << 5) | (b << 10) | msb);
}

void main() {
    ivec2 iUV = ivec2(floor((Frag_UV * vec2(1024.f, 512.f))));
    ivec2 icoords = iUV - u_startCoords;

    int x = u_startCoords.x + (icoords.x * 3) / 2;
    int y = u_startCoords.y + icoords.y;
    iUV = ivec2(x, y);

    const ivec2 size = ivec2(1023, 511);

    uint s0 = sample16(iUV & size);
    uint s1 = sample16((iUV + ivec2(1, 0)) & size);

    uint fullSample = ((s1 << 16) | s0) >> ((icoords.x & 1) * 8);
    uint r = fullSample & 0xffu;
    uint g = (fullSample >> 8u) & 0xffu;
    uint b = (fullSample >> 16u) & 0xffu;

    vec3 col = vec3(ivec3(r, g, b)) / 255.0;
    Out_Color = vec4(col, 1.0);
}
