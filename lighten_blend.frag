#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform qt_Uniforms {
    mat4 qt_Matrix;
    float qt_Opacity;
};
layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D overlayTexture;


vec4 blendLighten(vec4 bgColor, vec4 overlayColor) {
    return vec4(
        max(bgColor.r, overlayColor.r),
        max(bgColor.g, overlayColor.g),
        max(bgColor.b, overlayColor.b),
        0
    );
}

void main() {
    vec4 bgColor = texture(source, qt_TexCoord0);
    vec4 overlayColor = texture(overlayTexture, qt_TexCoord0);
    vec4 blendedColor = blendLighten(bgColor, overlayColor);
    fragColor = blendedColor * qt_Opacity;
}
