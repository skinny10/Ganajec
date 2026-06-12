import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff805611),
      surfaceTint: Color(0xff805611),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffddb5),
      onPrimaryContainer: Color(0xff633f00),
      secondary: Color(0xff705b40),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfffbdebc),
      onSecondaryContainer: Color(0xff57432b),
      tertiary: Color(0xff52643f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd5eaba),
      onTertiaryContainer: Color(0xff3b4c29),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f4),
      onSurface: Color(0xff211b13),
      onSurfaceVariant: Color(0xff4f4539),
      outline: Color(0xff817568),
      outlineVariant: Color(0xffd3c4b4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff362f27),
      inversePrimary: Color(0xfff6bc6f),
      primaryFixed: Color(0xffffddb5),
      onPrimaryFixed: Color(0xff2a1800),
      primaryFixedDim: Color(0xfff6bc6f),
      onPrimaryFixedVariant: Color(0xff633f00),
      secondaryFixed: Color(0xfffbdebc),
      onSecondaryFixed: Color(0xff271905),
      secondaryFixedDim: Color(0xffdec2a2),
      onSecondaryFixedVariant: Color(0xff57432b),
      tertiaryFixed: Color(0xffd5eaba),
      onTertiaryFixed: Color(0xff111f03),
      tertiaryFixedDim: Color(0xffb9cda0),
      onTertiaryFixedVariant: Color(0xff3b4c29),
      surfaceDim: Color(0xffe5d8cc),
      surfaceBright: Color(0xfffff8f4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1e5),
      surfaceContainer: Color(0xfff9ecdf),
      surfaceContainerHigh: Color(0xfff3e6da),
      surfaceContainerHighest: Color(0xffede0d4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4d3000),
      surfaceTint: Color(0xff805611),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff916420),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff45331c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff80694e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2b3b1a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff61734c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f4),
      onSurface: Color(0xff161009),
      onSurfaceVariant: Color(0xff3e3529),
      outline: Color(0xff5c5144),
      outlineVariant: Color(0xff776b5e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff362f27),
      inversePrimary: Color(0xfff6bc6f),
      primaryFixed: Color(0xff916420),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff754c06),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff80694e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff665137),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff61734c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff495a36),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd1c4b9),
      surfaceBright: Color(0xfffff8f4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1e5),
      surfaceContainer: Color(0xfff3e6da),
      surfaceContainerHigh: Color(0xffe7dbcf),
      surfaceContainerHighest: Color(0xffdcd0c4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff402700),
      surfaceTint: Color(0xff805611),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff674100),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3a2912),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff59462d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff213111),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3d4e2b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f4),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff342b20),
      outlineVariant: Color(0xff52473b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff362f27),
      inversePrimary: Color(0xfff6bc6f),
      primaryFixed: Color(0xff674100),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff492d00),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff59462d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff412f18),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3d4e2b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff273717),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc3b7ab),
      surfaceBright: Color(0xfffff8f4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffcefe2),
      surfaceContainer: Color(0xffede0d4),
      surfaceContainerHigh: Color(0xffdfd2c6),
      surfaceContainerHighest: Color(0xffd1c4b9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff6bc6f),
      surfaceTint: Color(0xfff6bc6f),
      onPrimary: Color(0xff462b00),
      primaryContainer: Color(0xff633f00),
      onPrimaryContainer: Color(0xffffddb5),
      secondary: Color(0xffdec2a2),
      onSecondary: Color(0xff3e2d16),
      secondaryContainer: Color(0xff57432b),
      onSecondaryContainer: Color(0xfffbdebc),
      tertiary: Color(0xffb9cda0),
      onTertiary: Color(0xff253515),
      tertiaryContainer: Color(0xff3b4c29),
      onTertiaryContainer: Color(0xffd5eaba),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff18120b),
      onSurface: Color(0xffede0d4),
      onSurfaceVariant: Color(0xffd3c4b4),
      outline: Color(0xff9c8f80),
      outlineVariant: Color(0xff4f4539),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffede0d4),
      inversePrimary: Color(0xff805611),
      primaryFixed: Color(0xffffddb5),
      onPrimaryFixed: Color(0xff2a1800),
      primaryFixedDim: Color(0xfff6bc6f),
      onPrimaryFixedVariant: Color(0xff633f00),
      secondaryFixed: Color(0xfffbdebc),
      onSecondaryFixed: Color(0xff271905),
      secondaryFixedDim: Color(0xffdec2a2),
      onSecondaryFixedVariant: Color(0xff57432b),
      tertiaryFixed: Color(0xffd5eaba),
      onTertiaryFixed: Color(0xff111f03),
      tertiaryFixedDim: Color(0xffb9cda0),
      onTertiaryFixedVariant: Color(0xff3b4c29),
      surfaceDim: Color(0xff18120b),
      surfaceBright: Color(0xff3f3830),
      surfaceContainerLowest: Color(0xff130d07),
      surfaceContainerLow: Color(0xff211b13),
      surfaceContainer: Color(0xff251f17),
      surfaceContainerHigh: Color(0xff302921),
      surfaceContainerHighest: Color(0xff3b342b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd5a2),
      surfaceTint: Color(0xfff6bc6f),
      onPrimary: Color(0xff372100),
      primaryContainer: Color(0xffba8740),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff5d8b6),
      onSecondary: Color(0xff32230d),
      secondaryContainer: Color(0xffa58d6f),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffcfe3b4),
      onTertiary: Color(0xff1b2a0b),
      tertiaryContainer: Color(0xff84976d),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff18120b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffeadaca),
      outline: Color(0xffbeb0a0),
      outlineVariant: Color(0xff9b8e80),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffede0d4),
      inversePrimary: Color(0xff654000),
      primaryFixed: Color(0xffffddb5),
      onPrimaryFixed: Color(0xff1c0e00),
      primaryFixedDim: Color(0xfff6bc6f),
      onPrimaryFixedVariant: Color(0xff4d3000),
      secondaryFixed: Color(0xfffbdebc),
      onSecondaryFixed: Color(0xff1b0e00),
      secondaryFixedDim: Color(0xffdec2a2),
      onSecondaryFixedVariant: Color(0xff45331c),
      tertiaryFixed: Color(0xffd5eaba),
      onTertiaryFixed: Color(0xff081400),
      tertiaryFixedDim: Color(0xffb9cda0),
      onTertiaryFixedVariant: Color(0xff2b3b1a),
      surfaceDim: Color(0xff18120b),
      surfaceBright: Color(0xff4b433a),
      surfaceContainerLowest: Color(0xff0b0703),
      surfaceContainerLow: Color(0xff231d15),
      surfaceContainer: Color(0xff2d271f),
      surfaceContainerHigh: Color(0xff393129),
      surfaceContainerHighest: Color(0xff443c34),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffeddb),
      surfaceTint: Color(0xfff6bc6f),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfff1b86c),
      onPrimaryContainer: Color(0xff140900),
      secondary: Color(0xffffeddb),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffdabe9e),
      onSecondaryContainer: Color(0xff140900),
      tertiary: Color(0xffe2f7c7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffb5c99c),
      onTertiaryContainer: Color(0xff050e00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff18120b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfffeeddd),
      outlineVariant: Color(0xffcfc0b1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffede0d4),
      inversePrimary: Color(0xff654000),
      primaryFixed: Color(0xffffddb5),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xfff6bc6f),
      onPrimaryFixedVariant: Color(0xff1c0e00),
      secondaryFixed: Color(0xfffbdebc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffdec2a2),
      onSecondaryFixedVariant: Color(0xff1b0e00),
      tertiaryFixed: Color(0xffd5eaba),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffb9cda0),
      onTertiaryFixedVariant: Color(0xff081400),
      surfaceDim: Color(0xff18120b),
      surfaceBright: Color(0xff574f46),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff251f17),
      surfaceContainer: Color(0xff362f27),
      surfaceContainerHigh: Color(0xff423a32),
      surfaceContainerHighest: Color(0xff4d453d),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xff150c07),
    value: Color(0xff150c07),
    light: ColorFamily(
      color: Color(0xff8c4f27),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdbc8),
      onColorContainer: Color(0xff6f3811),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff8c4f27),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdbc8),
      onColorContainer: Color(0xff6f3811),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff8c4f27),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdbc8),
      onColorContainer: Color(0xff6f3811),
    ),
    dark: ColorFamily(
      color: Color(0xffffb68b),
      onColor: Color(0xff522300),
      colorContainer: Color(0xff6f3811),
      onColorContainer: Color(0xffffdbc8),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb68b),
      onColor: Color(0xff522300),
      colorContainer: Color(0xff6f3811),
      onColorContainer: Color(0xffffdbc8),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb68b),
      onColor: Color(0xff522300),
      colorContainer: Color(0xff6f3811),
      onColorContainer: Color(0xffffdbc8),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor1,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
