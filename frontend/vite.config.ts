/// <reference types="vitest" />
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import viteTsconfigPaths from "vite-tsconfig-paths";
import relay from "vite-plugin-relay-lite";
import checker from "vite-plugin-checker";

export default defineConfig(({ command, mode }) => ({
  server: {
    open: mode !== "test",
    port: 3000,
  },
  build: {
    outDir: "build",
  },
  plugins: [
    react(),
    viteTsconfigPaths(),
    relay(),
    ...(command === "serve"
      ? [
          checker({
            eslint: {
              lintCommand: 'eslint "./src/**/*.{ts,tsx,js,jsx}"',
            },
            typescript: true,
            overlay: {
              initialIsOpen: false,
            },
          }),
        ]
      : []),
  ],
  test: {
    environment: "jsdom",
    setupFiles: "./src/setupTests.tsx",
    coverage: {
      provider: "v8",
      reporter: ["lcov", "text", "text-summary"],
      exclude: ["src/api/__generated__/**"],
    },
  },
}));
