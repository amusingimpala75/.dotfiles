// Nix supplies the pinned model read-only; never download or write to the agent directory.
import {
    modelState as upstreamModelState,
    modelVerified as upstreamModelVerified,
} from "./model-store-upstream.mjs";

export { agentDirectory } from "./model-store-upstream.mjs";

export function modelDirectory() {
    return "@modelDirectory@";
}

export function modelState(directory = modelDirectory()) {
    return upstreamModelState(directory);
}

export function modelVerified(directory = modelDirectory()) {
    return upstreamModelVerified(directory);
}

export async function installModel() {
    const directory = modelDirectory();
    if (!modelVerified(directory)) {
        throw new Error("The Nix-managed LANCET model failed verification; repair or rebuild pi-lancet-guard.");
    }
    return { installed: false, reason: "already-current", directory };
}
