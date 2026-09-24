// 设计系统: WinUI 3 / Fluent Design 系统色板原样落地。
// 浅色: 窗口 #F3F3F3 (Mica 基底), 卡片层 #FFFFFF, accent fill #005FB8;
// 深色: 窗口 #202020, 卡片层 #2B2B2B, accent fill #4CC2FF (深色字, Fluent 惯例)。
// 文字三级: #1B1B1B/#5D5D5D/#8D8D8D (light) · #FFFFFF/#C8C8C8/#8B8B8B (dark)。
// 字体: Segoe UI + Microsoft YaHei UI 回退; 字重只用 400/600 (雅黑无 Medium,
// w500 会逐字回退导致中文粗细不一致)。
import 'package:flutter/material.dart';

class YimColors {
  // ---- 浅色 (WinUI light: 大面积 #F3F3F3 灰, 白色做卡片/气泡层) ----
  static const primary = Color(0xFF005FB8); // AccentFillDefault (light)
  static const accentText = Color(0xFF0067C0); // AccentText (light)
  static const bgLight = Color(0xFFF3F3F3); // 窗口/聊天/详情: 统一浅灰
  static const sidebarLight = Color(0xFFF3F3F3); // 列表列与窗底同色 (无割裂)
  static const surfaceLight = Color(0xFFFFFFFF); // 卡片/面板层
  static const chatBgLight = Color(0xFFF3F3F3);
  static const myBubbleLight = Color(0xFF005FB8); // accent 实底 + 白字
  static const otherBubbleLight = Color(0xFFFFFFFF); // 灰底上的白卡, 无描边
  static const borderLight = Color(0xFFE5E5E5); // DividerStroke/CardStroke
  static const textLight = Color(0xFF1B1B1B);
  static const textSecondary = Color(0xFF5D5D5D);
  static const textTertiary = Color(0xFF8D8D8D);
  static const danger = Color(0xFFC42B1C); // SystemFillColorCritical

  // ---- 深色 (WinUI dark) ----
  static const bgDark = Color(0xFF202020);
  static const chatBgDark = Color(0xFF1C1C1C); // 聊天区略沉一档
  static const surfaceDark = Color(0xFF2B2B2B); // LayerFill (dark)
  static const surfaceDarkHigh = Color(0xFF323232); // ControlFill/hover
  static const myBubbleDark = Color(0xFF4CC2FF); // AccentFillDefault (dark)
  static const otherBubbleDark = Color(0xFF2B2B2B);
  static const primaryDark = Color(0xFF4CC2FF);
  static const accentTextDark = Color(0xFF4CC2FF);
  static const borderDark = Color(0xFF383838);
  static const textDark = Color(0xFFF3F3F3);
  static const textSecondaryDark = Color(0xFFC8C8C8);
  static const textTertiaryDark = Color(0xFF8B8B8B);

  // 深色 accent 上的文字 (Fluent: 亮 accent 压黑字)
  static const onAccentDark = Color(0xFF001322);
}

class YimRadius {
  static const bubble = 12.0;
  static const input = 6.0; // Fluent 控件小圆角 (4-8)
  static const card = 8.0;
  static const avatar = 100.0; // 圆形
}

class YimSpacing {
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0, xl = 24.0, xxl = 32.0;
}

class AppTheme {
  static const fontFamily = 'Segoe UI';
  static const fontFamilyFallback = ['Microsoft YaHei UI', 'Microsoft YaHei'];

  static ThemeData light() => _base(
        Brightness.light,
        const ColorScheme.light(
          primary: YimColors.primary,
          surface: YimColors.bgLight,
          error: YimColors.danger,
        ),
        bg: YimColors.bgLight,
        surface: YimColors.surfaceLight,
        text: YimColors.textLight,
        textSec: YimColors.textSecondary,
        border: YimColors.borderLight,
        inputFill: YimColors.surfaceLight,
        accentText: YimColors.accentText,
      );

  static ThemeData dark() => _base(
        Brightness.dark,
        const ColorScheme.dark(
          primary: YimColors.primaryDark,
          surface: YimColors.bgDark,
          error: YimColors.danger,
        ),
        bg: YimColors.bgDark,
        surface: YimColors.surfaceDark,
        text: YimColors.textDark,
        textSec: YimColors.textSecondaryDark,
        border: YimColors.borderDark,
        inputFill: YimColors.surfaceDarkHigh,
        accentText: YimColors.accentTextDark,
      );

  static ThemeData _base(Brightness brightness, ColorScheme scheme,
      {required Color bg,
      required Color surface,
      required Color text,
      required Color textSec,
      required Color border,
      required Color inputFill,
      required Color accentText}) {
    final base = ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        brightness: brightness,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        scaffoldBackgroundColor: bg);
    final txt = base.textTheme.apply(bodyColor: text, displayColor: text);
    return base.copyWith(
      textTheme: txt.copyWith(
        displaySmall:
            TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: text),
        titleMedium:
            TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: text),
        bodyMedium: TextStyle(fontSize: 15, color: text),
        bodySmall: TextStyle(fontSize: 13, color: textSec),
        labelSmall: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: textSec),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: text),
        iconTheme: IconThemeData(color: text),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(YimRadius.input),
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(YimRadius.input),
            borderSide: BorderSide(color: border)),
        // Fluent 聚焦: accent 双像素描边
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(YimRadius.input),
            borderSide: BorderSide(color: scheme.primary, width: 2)),
        hintStyle: TextStyle(color: YimColors.textTertiary, fontSize: 15),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          // Fluent dark: 亮 accent 上压黑字
          foregroundColor: brightness == Brightness.dark
              ? YimColors.onAccentDark
              : Colors.white,
          minimumSize: const Size(0, 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(0, 40),
          side: BorderSide(color: border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primary.withValues(alpha: 0.12),
          selectedForegroundColor: accentText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: bg,
        selectedIconTheme: IconThemeData(color: accentText),
        selectedLabelTextStyle:
            TextStyle(color: accentText, fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: textSec, fontSize: 12),
      ),
      splashFactory: InkRipple.splashFactory,
      // Fluent SubtleFill (hover): 极淡黑/白罩层
      hoverColor: text.withValues(alpha: 0.04),
    );
  }
}
