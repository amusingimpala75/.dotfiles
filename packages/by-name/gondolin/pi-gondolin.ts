import { constants as fsConstants } from "node:fs";
import { access, mkdir, readFile, realpath, rename, stat, writeFile } from "node:fs/promises";
import path from "node:path";

import { Type } from "@earendil-works/pi-ai";
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

import { MemoryProvider, ReadonlyProvider, RealFSProvider, VM } from "@earendil-works/gondolin";

const GUEST_WORKSPACE = "/workspace";
const GUEST_HOST_STORE = "/host-store";
const HOST_NIX_STORE = "/nix/store";
// Gondolin images run as root, whose home directory is /root. Mount only Pi's
// skills there, rather than exposing the complete Pi configuration directory.
const GUEST_SKILLS_DIR = "/root/.config/pi/agent/skills";
// Keep global extension state in Pi's configured agent directory. This respects
// PI_CODING_AGENT_DIR rather than assuming an XDG/home-directory path.
const AGENT_DIR = getAgentDir();
const SKILLS_DIR = path.join(AGENT_DIR, "skills");
const REGISTRY_PATH = path.join(AGENT_DIR, "gondolin-images.json");

type ImageDefinition = {
  name: string;
  imagePath: string;
  devShell?: string;
  /** Incremented by the builder so a reused output path still refreshes the VM. */
  revision?: number;
  /** Workspace-relative directories hidden from the host by guest memory mounts. */
  memoryMounts?: string[];
};

type ImageRegistry = {
  version: 1;
  images: Record<string, ImageDefinition>;
  lastSelected?: string;
};

function emptyRegistry(): ImageRegistry {
  return { version: 1, images: {} };
}

/**
 * Return a canonical, workspace-relative POSIX path suitable for a nested VFS
 * mount. The registry is shared across host platforms, so never store host
 * path separators in it.
 */
function normaliseMemoryMount(value: string): string | undefined {
  const input = value.trim().replaceAll("\\", "/");
  if (input === "" || input.includes("\0") || path.posix.isAbsolute(input)) return undefined;

  const normalised = path.posix.normalize(input);
  if (normalised === "." || normalised === ".." || normalised.startsWith("../")) {
    return undefined;
  }
  return normalised;
}

function memoryMountsFrom(value: unknown): string[] | undefined {
  if (!Array.isArray(value)) return undefined;
  const mounts = [...new Set(value
    .filter((entry): entry is string => typeof entry === "string")
    .map(normaliseMemoryMount)
    .filter((entry): entry is string => entry !== undefined))].sort();
  return mounts.length > 0 ? mounts : undefined;
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
        const memoryMounts = memoryMountsFrom(image.memoryMounts);
        registry.images[projectRoot] = {
          name: image.name,
          imagePath: image.imagePath,
          ...(typeof image.devShell === "string" ? { devShell: image.devShell } : {}),
          ...(Number.isSafeInteger(image.revision) && (image.revision as number) >= 0
            ? { revision: image.revision as number }
            : {}),
          ...(memoryMounts ? { memoryMounts } : {}),
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

function pathInMount(localPath: string, localRoot: string, guestRoot: string): string | undefined {
  const rel = path.relative(localRoot, localPath);
  if (rel === "") return guestRoot;
  if (rel.startsWith("..") || path.isAbsolute(rel)) return undefined;
  return path.posix.join(guestRoot, ...rel.split(path.sep));
}

function toGuestPath(localCwd: string, localPath: string): string {
  const workspacePath = pathInMount(localPath, localCwd, GUEST_WORKSPACE);
  if (workspacePath) return workspacePath;

  const skillsPath = pathInMount(localPath, SKILLS_DIR, GUEST_SKILLS_DIR);
  if (skillsPath) return skillsPath;

  throw new Error(`path escapes mounted filesystems: ${localPath}`);
}

function projectImageCandidates(
  registry: ImageRegistry,
  currentDirectory: string,
): Array<{ projectRoot: string; image: ImageDefinition }> {
  return Object.entries(registry.images)
    .filter(([projectRoot]) =>
      currentDirectory === projectRoot || currentDirectory.startsWith(`${projectRoot}${path.sep}`),
    )
    .sort(([left], [right]) => right.length - left.length)
    .map(([projectRoot, image]) => ({ projectRoot, image }));
}

function closestProjectImage(
  registry: ImageRegistry,
  currentDirectory: string,
): { projectRoot: string; image: ImageDefinition } | undefined {
  return projectImageCandidates(registry, currentDirectory)[0];
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
        // A login shell sources Alpine's /etc/profile, which replaces the
        // PATH embedded in the Gondolin image. Preserve the image's exported
        // Nix dev-shell environment instead.
        const process = vm.exec(["/bin/bash", "-c", command], {
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
  let vmImageKey: string | undefined;
  let selectedProjectRoot: string | undefined;
  // This is deliberately session-local and can only be changed by Pi's
  // user-invoked command below; it is never exposed as an agent tool.
  let sandboxEnabled = true;

  async function selectedImage(): Promise<ImageDefinition | undefined> {
    const registry = await loadRegistry();
    // The builder updates lastSelected when it produces an image. Prefer it
    // over an in-memory selection so a rebuild is picked up by a live Pi host.
    const preferred = registry.lastSelected ?? selectedProjectRoot;
    if (preferred && registry.images[preferred] && await imageExists(registry.images[preferred])) {
      selectedProjectRoot = preferred;
      return registry.images[preferred];
    }

    // A registry may have been created before anything was selected. In that
    // case prefer the closest image definition for Pi's current project.
    const currentDirectory = await realpath(localCwd).catch(() => localCwd);
    for (const projectImage of projectImageCandidates(registry, currentDirectory)) {
      if (await imageExists(projectImage.image)) {
        selectedProjectRoot = projectImage.projectRoot;
        return projectImage.image;
      }
    }
    return undefined;
  }

  async function setStatus(ctx: ExtensionContext, state: string): Promise<void> {
    const image = await selectedImage();
    const label = image ? `${image.name} (${image.devShell ?? "default"})` : "built-in image";
    const mode = sandboxEnabled ? state : "disabled (host)";
    ctx.ui.setStatus("gondolin", ctx.ui.theme.fg("accent", `Gondolin: ${mode} — ${label}`));
  }

  /**
   * Map Pi's Nix-store entrypoint into the guest on demand, rather than making
   * the agent search the whole store. The mapping is only meaningful inside
   * Gondolin.
   */
  async function agentGuestStorePath(): Promise<string | undefined> {
    const entrypoint = process.argv[1];
    if (!entrypoint) return undefined;
    const resolved = await realpath(entrypoint).catch(() => path.resolve(entrypoint));
    return pathInMount(resolved, HOST_NIX_STORE, GUEST_HOST_STORE);
  }

  async function ensureVm(ctx?: ExtensionContext): Promise<VM> {
    const image = await selectedImage();
    // The path alone is not enough: a rebuild replaces its contents in place.
    const requestedImageKey = image ? `${image.imagePath}\0${image.revision ?? 0}` : "built-in";
    if (vm && vmImageKey === requestedImageKey) return vm;
    if (vm) await stopVm(ctx);
    if (vmStarting) return vmStarting;

    vmStarting = (async () => {
      const registry = await loadRegistry();
      const currentDirectory = await realpath(localCwd).catch(() => localCwd);
      const memoryMounts = closestProjectImage(registry, currentDirectory)?.image.memoryMounts ?? [];
      const workspaceMemoryMounts = Object.fromEntries(memoryMounts.map((relativePath) => [
        path.posix.join(GUEST_WORKSPACE, relativePath),
        new MemoryProvider(),
      ]));

      if (ctx) await setStatus(ctx, "starting");
      const created = await VM.create({
        ...(image ? { sandbox: { imagePath: image.imagePath } } : {}),
        vfs: {
          mounts: {
            [GUEST_WORKSPACE]: new RealFSProvider(localCwd),
            ...workspaceMemoryMounts,
            [GUEST_HOST_STORE]: new ReadonlyProvider(new RealFSProvider(HOST_NIX_STORE)),
            [GUEST_SKILLS_DIR]: new RealFSProvider(SKILLS_DIR),
          },
        },
      });
      vm = created;
      vmImageKey = requestedImageKey;
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
      vmImageKey = undefined;
    }
  }

  pi.registerTool({
    name: "gondolin_host_store_path",
    label: "Gondolin host-store path",
    description: "Return Pi's exact /host-store path inside the Gondolin VM. Call only when you need to inspect Pi's Nix-store files.",
    parameters: Type.Object({}),
    annotations: { readOnlyHint: true, destructiveHint: false, openWorldHint: false },
    async execute() {
      if (!sandboxEnabled) {
        return {
          content: [{ type: "text", text: "Gondolin sandboxing is disabled, so /host-store is not mounted." }],
          details: { sandboxEnabled, guestPath: undefined },
        };
      }
      const guestPath = await agentGuestStorePath();
      const text = guestPath
        ? `Pi's host-store entrypoint is available at: ${guestPath}`
        : "Pi's entrypoint is not located in the host Nix store.";
      return {
        content: [{ type: "text", text }],
        details: { sandboxEnabled, guestPath },
      };
    },
  });

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

      const currentDirectory = await realpath(localCwd).catch(() => localCwd);
      const projectDefault = closestProjectImage(registry, currentDirectory)?.projectRoot;
      const choices = available.map(({ projectRoot, image }) =>
        `${image.name} — ${projectRoot}${
          projectRoot === projectDefault ? " (default for this project)" : ""
        }`,
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

  pi.registerCommand("gondolin-sandbox", {
    description: "Enable or disable Gondolin sandboxing for this session",
    handler: async (_args, ctx) => {
      const action = sandboxEnabled ? "Disable sandbox (run on host)" : "Enable sandbox";
      const choice = await ctx.ui.select("Gondolin sandbox", [action]);
      if (!choice) return;

      sandboxEnabled = !sandboxEnabled;
      if (sandboxEnabled) {
        await ensureVm(ctx);
        pi.sendMessage(
          {
            customType: "gondolin-sandbox-mode",
            content: "Gondolin sandbox enabled; subsequent tools run in /workspace.",
            display: true,
            details: { sandboxEnabled },
          },
          { triggerTurn: false },
        );
        ctx.ui.notify("Gondolin sandbox enabled.", "info");
      } else {
        // Closing the VM makes the mode change unambiguous and frees its
        // resources. It is recreated only when the user re-enables it.
        await stopVm(ctx);
        await setStatus(ctx, "disabled");
        pi.sendMessage(
          {
            customType: "gondolin-sandbox-mode",
            content: "Gondolin sandbox disabled; subsequent tools run on the host.",
            display: true,
            details: { sandboxEnabled },
          },
          { triggerTurn: false },
        );
        ctx.ui.notify("Gondolin sandbox disabled; tools now run on the host.", "warning");
      }
    },
  });

  pi.registerCommand("gondolin-reload", {
    description: "Force-restart the Gondolin VM",
    handler: async (_args, ctx) => {
      // If startup is already in progress, let it finish so stopVm can close
      // the resulting VM rather than returning the in-flight instance.
      if (vmStarting) await vmStarting.catch(() => undefined);
      await stopVm(ctx);
      await ensureVm(ctx);
      ctx.ui.notify("Gondolin VM reloaded.", "info");
    },
  });

  pi.registerCommand("gondolin-memory-mounts", {
    description: "Hide workspace directories behind guest-local memory mounts",
    handler: async (_args, ctx) => {
      const registry = await loadRegistry();
      const currentDirectory = await realpath(localCwd).catch(() => localCwd);
      const projectImage = closestProjectImage(registry, currentDirectory);
      if (!projectImage) {
        ctx.ui.notify(
          "No Gondolin image is registered for this project. Run gondolin-build-nix-image first.",
          "warning",
        );
        return;
      }

      const { projectRoot, image } = projectImage;
      const memoryMounts = new Set(image.memoryMounts ?? []);
      let changed = false;
      while (true) {
        const mounts = [...memoryMounts].sort();
        const addChoice = "Add workspace directory…";
        const doneChoice = "Done";
        const choices = [addChoice, ...mounts.map((mount) => `Remove ${mount}`), doneChoice];
        const choice = await ctx.ui.select(
          `Gondolin memory mounts — ${projectRoot}`,
          choices,
        );
        if (!choice || choice === doneChoice) break;

        if (choice === addChoice) {
          const input = await ctx.ui.input(
            "Directory to hide from the host",
            "e.g. node_modules or frontend/node_modules",
          );
          if (input === undefined) continue;
          const mount = normaliseMemoryMount(input);
          if (!mount) {
            ctx.ui.notify("Enter a non-empty path relative to the workspace (no .. or leading /).", "warning");
            continue;
          }
          if (memoryMounts.has(mount)) {
            ctx.ui.notify(`${mount} is already a guest-local memory mount.`, "warning");
            continue;
          }
          try {
            const parent = await stat(path.join(localCwd, path.posix.dirname(mount)));
            if (!parent.isDirectory()) throw new Error("not a directory");
          } catch {
            ctx.ui.notify(
              `The parent directory of ${mount} must exist in the host workspace before it can be mounted.`,
              "warning",
            );
            continue;
          }
          memoryMounts.add(mount);
          changed = true;
          continue;
        }

        const mount = choice.slice("Remove ".length);
        if (memoryMounts.delete(mount)) changed = true;
      }

      if (!changed) return;
      if (vm && !await ctx.ui.confirm(
        "Restart Gondolin VM?",
        "Applying this change restarts the VM and permanently discards all guest-local memory mounts, including installed dependencies.",
      )) return;

      const mounts = [...memoryMounts].sort();
      if (mounts.length > 0) {
        registry.images[projectRoot] = { ...image, memoryMounts: mounts };
      } else {
        const { memoryMounts: _memoryMounts, ...imageWithoutMemoryMounts } = image;
        registry.images[projectRoot] = imageWithoutMemoryMounts;
      }
      await saveRegistry(registry);

      // VFS mounts are established at VM startup, so restart to apply the
      // saved configuration before the next tool invocation.
      await stopVm(ctx);
      await setStatus(ctx, "configured");
      ctx.ui.notify(
        `Gondolin memory mounts updated for ${projectRoot}: ${mounts.length === 0 ? "none" : mounts.join(", ")}`,
        "info",
      );
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    await ensureVm(ctx);
  });
  pi.on("session_shutdown", async (_event, ctx) => stopVm(ctx));

  pi.registerTool({
    ...localRead,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!sandboxEnabled) return localRead.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      return createReadTool(localCwd, { operations: createGondolinReadOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });
  pi.registerTool({
    ...localWrite,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!sandboxEnabled) return localWrite.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      return createWriteTool(localCwd, { operations: createGondolinWriteOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });
  pi.registerTool({
    ...localEdit,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!sandboxEnabled) return localEdit.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      return createEditTool(localCwd, { operations: createGondolinEditOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });
  pi.registerTool({
    ...localBash,
    async execute(id, params, signal, onUpdate, ctx) {
      if (!sandboxEnabled) return localBash.execute(id, params, signal, onUpdate);
      const activeVm = await ensureVm(ctx);
      return createBashTool(localCwd, { operations: createGondolinBashOps(activeVm, localCwd) })
        .execute(id, params, signal, onUpdate);
    },
  });

  // Selecting an image stops the current VM. Start its replacement before
  // routing a direct ! command so it cannot fall through to host execution.
  pi.on("user_bash", async (_event, ctx) => {
    if (!sandboxEnabled) return undefined;
    const activeVm = await ensureVm(ctx);
    return { operations: createGondolinBashOps(activeVm, localCwd) };
  });
  pi.on("before_agent_start", async (event, ctx) => {
    if (!sandboxEnabled) return undefined;
    await ensureVm(ctx);
    return {
      systemPrompt: event.systemPrompt.replace(
        `Current working directory: ${localCwd}`,
        `Current working directory: ${GUEST_WORKSPACE} (Gondolin VM, mounted from host: ${localCwd})`,
      ),
    };
  });
}
