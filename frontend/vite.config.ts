import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import viteTsconfigPaths from "vite-tsconfig-paths";
import relay from "vite-plugin-relay-lite";

// @ts-expect-error - The vite-plugin-eslint package.json 'exports' field misconfigures its typings mapping.
import eslint from "vite-plugin-eslint";

export default defineConfig(({ mode }) => {
  return {
    server: {
      open: mode !== "test",
      port: 3000,
    },
    build: {
      outDir: "build",
    },
    css: {
      preprocessorOptions: {
        scss: {
          quietDeps: true,
        },
      },
    },
    plugins: [
      react(),
      viteTsconfigPaths(),
      relay(),
      {
        ...eslint({
          failOnWarning: false,
          failOnError: false,
        }),
        apply: "serve",
        enforce: "post",
      },
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
  };
});
