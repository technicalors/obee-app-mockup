/// Which preview layout the build ships. `v2` is the alternative served at
/// `/mobile2` (rounded schedule and the Tasks tab); every other value keeps
/// the default UI.
const uiVariant = String.fromEnvironment('OBEE_UI_VARIANT', defaultValue: 'v1');

const isUiV2 = uiVariant == 'v2';
