import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import viteTsconfigPaths from "vite-tsconfig-paths";
import relay from "vite-plugin-relay-lite";
import checker from "vite-plugin-checker";

export default defineConfig(({ mode }) => {
  return {
    server: {
      open: mode !== "test",
      port: 3000,
    },
    build: {
      outDir: "build",
      // Bump the warning limit slightly because ApexCharts is inherently massive
      rollupOptions: {
        output: {
          manualChunks(id) {
            if (id.includes("node_modules")) {
              // Only extract the massive, isolated libraries.
              if (id.includes("apexcharts") || id.includes("react-apexcharts"))
                return "apexcharts";
              if (id.includes("leaflet") || id.includes("react-leaflet"))
                return "leaflet";
              if (id.includes("@monaco-editor")) return "monaco-editor";
              if (id.includes("lucide-react")) return "lucide-icons";
              if (id.includes("@formatjs") || id.includes("react-intl"))
                return "i18n";

              // REMOVE the catch-all "vendor" and "react-vendor" returns.
              // By letting Rollup handle the rest automatically, we eliminate the circular dependency.
            }
          },
        },
      },
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
      checker({
        eslint: {
          // Instructs the checker on what files to run against
          lintCommand: 'eslint "./src/**/*.{ts,tsx}"',
          // ESLint 9 uses Flat Config by default; this ensures compatibility
          useFlatConfig: true,
        },
        // Replicates your 'apply: "serve"' behavior by disabling it during 'build'
        enableBuild: false,
        overlay: {
          // Replicates your 'failOnWarning/failOnError: false' by keeping the UI overlay unobtrusive
          initialIsOpen: false,
        },
      }),
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
