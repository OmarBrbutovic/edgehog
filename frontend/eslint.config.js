// This file is part of Edgehog.
//
// Copyright 2026 SECO Mind Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import reactRefresh from "eslint-plugin-react-refresh";
import reactHooks from "eslint-plugin-react-hooks";
import relay from "eslint-plugin-relay";
import testingLibrary from "eslint-plugin-testing-library";
import prettier from "eslint-config-prettier";
import { fixupPluginRules } from "@eslint/compat";

export default tseslint.config(
  // 1. Global ignores replace the old globalIgnores wrapper
  { ignores: ["**/build", "**/.eslintrc.cjs"] },

  // 2. Native Flat Configs replacing FlatCompat.extends()
  js.configs.recommended,
  ...tseslint.configs.recommended,
  prettier, // Prettier should remain at the top level to disable conflicting rules

  // 3. Project Specific Configuration
  {
    languageOptions: {
      globals: {
        ...globals.browser,
      },
      // Note: parser: tsParser is no longer needed here,
      // tseslint.configs.recommended handles it automatically.
    },

    plugins: {
      "react-refresh": reactRefresh,
      "react-hooks": reactHooks,
      // Keeping fixupPluginRules for these two just in case they haven't
      // fully updated their internal AST calls for ESLint 10 compatibility
      relay: fixupPluginRules(relay),
      "testing-library": fixupPluginRules(testingLibrary),
    },

    rules: {
      // Manually unpacking recommended rules for plugins that
      // don't export native flat configs yet
      ...reactHooks.configs.recommended.rules,
      ...relay.configs.recommended.rules,
      ...testingLibrary.configs.react.rules,

      // Your custom overrides
      "react-refresh/only-export-components": [
        "warn",
        {
          allowConstantExport: true,
        },
      ],
      "@typescript-eslint/no-explicit-any": ["warn"],
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
        },
      ],
      "testing-library/no-manual-cleanup": "off",
    },
  },
);
