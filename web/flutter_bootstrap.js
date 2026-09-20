{{flutter_js}}
{{flutter_build_config}}

// CanvasKit's WebGL renderer can exhaust Chrome's active-context limit on
// affected GPU drivers, which then causes repeated GLSL compilation errors.
// Keep CanvasKit's rendering fidelity while using its software surface.
_flutter.loader.load({
  config: {
    canvasKitForceCpuOnly: true,
  },
});
