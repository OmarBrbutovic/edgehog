import { fixupConfigRules, fixupPluginRules } from "@eslint/compat";
import { FlatCompat } from "@eslint/eslintrc";
import js from "@eslint/js";
import tsParser from "@typescript-eslint/parser";
import reactRefresh from "eslint-plugin-react-refresh";
import relay from "eslint-plugin-relay";
import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Emulate __dirname for ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default [
  {
    ignores: ["**/build", "**/.eslintrc.cjs"],
  },
  ...fixupConfigRules(
    compat.extends(
      "eslint:recommended",
      "plugin:@typescript-eslint/recommended",
      "plugin:react-hooks/recommended",
      "plugin:relay/recommended",
      "prettier",
      "plugin:testing-library/react"
    )
  ),
  {
    languageOptions: {
      globals: {
        ...globals.browser,
      },
      parser: tsParser,
    },
    plugins: {
      relay: fixupPluginRules(relay),
      "react-refresh": reactRefresh,
    },
    rules: {
      "react-refresh/only-export-components": [
        "warn",
        {
          allowConstantExport: true,
        },
      ],
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
        },
      ],
      "testing-library/no-manual-cleanup": "off",
    },
  },
];
