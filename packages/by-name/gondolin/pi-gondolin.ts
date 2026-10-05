import { constants as fsConstants } from "node:fs";
import { access, mkdir, readFile, realpath, rename, writeFile } from "node:fs/promises";
import path from "node:path";

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  type BashOperations,
  createBashTool,
  createEditTool,
  createReadTool,
  createWriteTool,
  type EditOperations,
  type ReadOperations,
  type WriteOperations,
  getAgentDir,
} from "@earendil-works/pi-coding-agent";

import { RealFSProvider, VM } from "@earendil-works/gondolin";

const GUEST_WORKSPACE = "/workspace";
// Keep global extension state in Pi's configured agent directory.  This
// respects PI_CODING_AGENT_DIR rather than assuming an XDG/home-directory path.
const REGISTRY_PATH = path.join(getAgentDir(), "gondolin-images.json");

type ImageDefinition = {
  name: string;
  imagePath: string;
  devShell?: string;
};

type ImageRegistry = {
  version: 1;
  images: Record<string, ImageDefinition>;
  lastSelected?: string;
};

function emptyRegistry(): ImageRegistry {
  return { version: 1, images: {} };
}

async function loadRegistry(): Promise<ImageRegistry> {
  try {
    const parsed: unknown = JSON.parse(await readFile(REGISTRY_PATH, "utf8"));
    if (typeof parsed !== "object" || parsed === null) return emptyRegistry();
    const candidate = parsed as Record<string, unknown>;
    const rawImages = candidate.images;
    if (typeof rawImages !== "object" || rawImages === null) return emptyRegistry();

    const registry = emptyRegistry();
    for (const [projectRoot, rawImage] of Object.entries(rawImages)) {
      if (typeof rawImage !== "object" || rawImage === null) continue;
      const image = rawImage as Record<string, unknown>;
      if (typeof image.name === "string" && typeof image.imagePath === "string") {
        registry.images[projectRoot] = {
          name: image.name,
          imagePath: image.imagePath,
          ...(typeof image.devShell === "string" ? { devShell: image.devShell } : {}),
        };
      }
    }
    if (typeof candidate.lastSelected === "string") {
      registry.lastSelected = candidate.lastSelected;
    }
    return registry;
  } catch (error: unknown) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      return emptyRegistry();
    }
    return emptyRegistry();
  }
}

async function saveRegistry(registry: ImageRegistry): Promise<void> {
  await mkdir(path.dirname(REGISTRY_PATH), { recursive: true });
  const temporaryPath = `${REGISTRY_PATH}.${process.pid}.tmp`;
  await writeFile(temporaryPath, `${JSON.stringify(registry, null, 2)}\n`, "utf8");
  await rename(temporaryPath, REGISTRY_PATH);
}

async function imageExists(image: ImageDefinition): Promise<boolean> {
  try {
    await access(path.join(image.imagePath, "manifest.json"), fsConstants.R_OK);
    return true;
  } catch {
    return false;
  }
}

function shQuote(value: string): string {
  return `'${value.replace(/'/g, "'\\''")}'`;
}

function toGuestPath(localCwd: string, localPath: string): string {
  const rel = path.relative(localCwd, localPath);
  if (rel === "") return GUEST_WORKSPACE;
  if (rel.startsWith("..") || path.isAbsolute(rel)) {
    throw new Error(`path escapes workspace: ${localPath}`);
  }
  return path.posix.join(GUEST_WORKSPACE, ...rel.split(path.sep));
}

function createGondolinReadOps(vm: VM, localCwd: string): ReadOperations {
  return {
    readFile: (p) => vm.fs.readFile(toGuestPath(localCwd, p)),
    access: (p) => vm.fs.access(toGuestPath(localCwd, p), { mode: fsConstants.R_OK }),
    detectImageMimeType: async (p) => {
      try {
        const result = await vm.exec([
          "/bin/sh",
          "-lc",
          `file --mime-type -b ${shQuote(toGuestPath(localCwd, p))}`,
        ]);
        const mime = result.stdout.trim();
        return ["image/jpeg", "image/png", "image/gif", "image/webp"].includes(mime)
          ? mime
          : null;
      } catch {
        return null;
      }
    },
  };
}

function createGondolinWriteOps(vm: VM, localCwd: string): WriteOperations {
  return {
    writeFile: async (p, content) => {
      const guestPath = toGuestPath(localCwd, p);
      await vm.fs.mkdir(path.posix.dirname(guestPath), { recursive: true });
      await vm.fs.writeFile(guestPath, content);
    },
    mkdir: (dir) => vm.fs.mkdir(toGuestPath(localCwd, dir), { recursive: true }),
  };
}

function createGondolinEditOps(vm: VM, localCwd: string): EditOperations {
  const read = createGondolinReadOps(vm, localCwd);
  const write = createGondolinWriteOps(vm, localCwd);
  return { readFile: read.readFile, access: read.access, writeFile: write.writeFile };
}

function createGondolinBashOps(vm: VM, localCwd: string): BashOperations {
  return {
    exec: async (command, cwd, { onData, signal, timeout }) => {
      const controller = new AbortController();
      const onAbort = () => controller.abort();
      signal?.addEventListener("abort", onAbort, { once: true });
      const timer = timeout && timeout > 0
        ? setTimeout(() => controller.abort(), timeout * 1000)
        : undefined;

      try {
        const process = vm.exec(["/bin/bash", "-lc", command], {
          cwd: toGuestPath(localCwd, cwd),
          signal: controller.signal,
          stdout: "pipe",
          stderr: "pipe",
        });
        for await (const chunk of process.output()) onData(chunk.data);
        return { exitCode: (await process).exitCode };
      } catch (error) {
        if (signal?.aborted) throw new Error("aborted");
        throw error;
      } finally {
        if (timer) clearTimeout(timer);
        signal?.removeEventListener("abort", onAbort);
      }
    },
  };
}

export default function (pi: ExtensionAPI) {
  const localCwd = process.cwd();
  const localRead = createReadTool(localCwd);
  const localWrite = createWriteTool(localCwd);
  const localEdit = createEditTool(localCwd);
  const localBash = createBashTool(localCwd);

  let vm: VM | null = null;
  let vmStarting: Promise<VM> | null = null;
  let selectedProjectRoot: string | undefined;

  async function selectedImage(): Promise<ImageDefinition | undefined> {
    const registry = await loadRegistry();
    const preferred = selectedProjectRoot ?? registry.lastSelected;
    if (preferred && registry.images[preferred] && await imageExists(registry.images[preferred])) {
      selectedProjectRoot = preferred;
      return registry.images[preferred];
    }

    // A registry may have been created before anything was selected.  In that
    // case prefer the closest image definition for Pi's current project.
    const currentDirectory = await realpath(localCwd).catch(() => localCwd);
    const candidates = Object.entries(registry.images)
      .filter(([projectRoot]) =>
        currentDirectory === projectRoot || currentDirectory.startsWith(`${projectRoot}${path.sep}`),
      )
      .sort(([left], [right]) => right.length - left.length);
    for (const [projectRoot, image] of candidates) {
      if (await imageExists(image)) {
        selectedProjectRoot = projectRoot;
        return image;
      }
    }
    return undefined;
  }

  async function setStatus(ctx: ExtensionContext, state: string): Promise<void> {
    const image = await selectedImage();
    const label = image ? `${image.name} (${image.devShell ?? "default"})` : "built-in image";
    ctx.ui.setStatus("gondolin", ctx.ui.theme.fg("accent", `Gondolin: ${state} — ${label}`));
  }

  async function ensureVm(ctx?: ExtensionContext): Promise<VM> {
    if (vm) return vm;
    if (vmStarting) return vmStarting;

    vmStarting = (async () => {
      const image = await selectedImage();
      if (ctx) await setStatus(ctx, "starting");
      const created = await VM.create({
        ...(image ? { sandbox: { imagePath: image.imagePath } } : {}),
        vfs: {
          mounts: {
            [GUEST_WORKSPACE]: new RealFSProvider(localCwd),
          },
        },
      });
      vm = created;
      if (ctx) await setStatus(ctx, "running");
      return created;
    })();
    return vmStarting;
  }

  async function stopVm(ctx?: ExtensionContext): Promise<void> {
    if (!vm) return;
    if (ctx) await setStatus(ctx, "stopping");
    try {
      await vm.close();
    } finally {
      vm = null;
      vmStarting = null;
    }
  }

  pi.registerCommand("gondolin-image", {
    description: "Select the Gondolin image used by this Pi session",
    handler: async (_args, ctx) => {
      const registry = await loadRegistry();
      const available = (await Promise.all(
        Object.entries(registry.images).map(async ([projectRoot, image]) =>
          (await imageExists(image)) ? { projectRoot, image } : undefined,
        ),
      )).filter((entry): entry is { projectRoot: string; image: ImageDefinition } => entry !== undefined);

      if (available.length === 0) {
        ctx.ui.notify(
          "No Gondolin images are registered. Run gondolin-build-nix-image in a flake project first.",
          "warning",
        );
        return;
      }

      const choices = available.map(({ projectRoot, image }) =>
        `${image.name} — ${projectRoot}${image.devShell ? ` (${image.devShell})` : ""}`,
      );
      const choice = await ctx.ui.select("Gondolin image", choices);
      if (!choice) return;
      const selection = available[choices.indexOf(choice)];
      selectedProjectRoot = selection.projectRoot;
      registry.lastSelected = selection.projectRoot;
      await saveRegistry(registry);
      await stopVm(ctx);
      await setStatus(ctx, "selected");
      ctx.ui.notify(`Gondolin image selected: ${selection.image.name}`, "info");
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    await ensureVm(ctx);
  });
  pi.on("session_shutdown", async (_event, ctx) => stopVm(ctx));

  pi.registerTool({
    ...localRead,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      return createReadTool(localCwd, { operations: createGondolinReadOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });
  pi.registerTool({
    ...localWrite,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      return createWriteTool(localCwd, { operations: createGondolinWriteOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });
  pi.registerTool({
    ...localEdit,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      return createEditTool(localCwd, { operations: createGondolinEditOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });
  pi.registerTool({
    ...localBash,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      return createBashTool(localCwd, { operations: createGondolinBashOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });

  pi.on("user_bash", () => vm ? { operations: createGondolinBashOps(vm, localCwd) } : undefined);
  pi.on("before_agent_start", async (event, ctx) => {
    await ensureVm(ctx);
    return {
      systemPrompt: event.systemPrompt.replace(
        `Current working directory: ${localCwd}`,
        `Current working directory: ${GUEST_WORKSPACE} (Gondolin VM, mounted from host: ${localCwd})`,
      ),
    };
  });
}
