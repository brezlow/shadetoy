#define PI 3.141

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  // 将屏幕坐标转换为标准化的中心对称坐标系，uv.x 和 uv.y 取值范围变为 -1 到
  // 1，并归一化纵横比。
  vec2 uv = (fragCoord - (0.5 * iResolution.xy)) / iResolution.y;

  float hei = 0.0;

  // Wobble
  // 添加两个正弦波，频率分别为 42 和
  // 20，用于模拟波动（"抖动"）效果。结果会生成一个随 uv.x
  // 变化的小幅波动，用于增加线条的动态感。

  hei += sin(uv.x * 42.0) * 0.005;
  hei += sin(uv.x * 20.0) * 0.010;

  // Heartbeat
  // hb_size: 心跳的宽度范围。
  // hb_smooth: 过渡区域的平滑程度。
  // 使用 smoothstep 控制心跳强度的过渡，当 abs(uv.x) 接近 hb_size 时，hb_mult
  // 平滑地从 1 过渡到 0。 hb_hei 使用正弦波模拟心跳的高低起伏，基于 uv.x 计算。
  // 最终将波动效果和心跳效果混合，心跳的影响由 hb_mult 决定
  const float hb_size = 0.20;
  const float hb_smooth = 0.15;
  float hb_mult =
      smoothstep(hb_size + hb_smooth, hb_size - hb_smooth, abs(uv.x));
  float hb_hei = sin(uv.x / hb_size * PI);
  hei = mix(hei, hb_hei, hb_mult);

  // Line + glow value
  // 通过 smoothstep 绘制中心线 (hei / 3.0) 和它的辉光。
  // 第一个 smoothstep：创建较细的中心线条。
  // 第二个 smoothstep：创建外围的辉光。
  // abs(hei / 3.0 - uv.y)
  // 表示计算当前像素距离中心线的垂直距离，产生线条的渐变效果。
  float val = 0.0;
  val += smoothstep(0.010, 0.005, abs(hei / 3.0 - uv.y));
  val += smoothstep(0.125, -0.1, abs(hei / 3.0 - uv.y));

  // Base color
  float anim = (uv.x - iTime) / 2.0;
  vec3 col = pow(fract(anim) * val, 1.5) * vec3(0.7725, 0.20, 0.2745);

  // Grid
  float grid_x = abs(1.0 - 2.0 * fract(uv.x * 6.0));
  float grid_y = abs(1.0 - 2.0 * fract(uv.y * 12.0));
  col += smoothstep(0.1, 0.0, min(grid_x, grid_y)) * (uv.y + 0.5) *
         vec3(0.1, 0.2, 0.2);

  // Output to screen
  fragColor = vec4(col, 1.0);
}