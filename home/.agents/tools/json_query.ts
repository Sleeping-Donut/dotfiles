import { tool } from "@opencode-ai/plugin"
import { execFile } from "node:child_process"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)

async function runJq(jqArgs: string[], opts: { input?: string; maxBuffer?: number }) {
  try {
    const { stdout } = await execFileAsync("jq", jqArgs, opts)
    return { ok: true as const, stdout }
  } catch (err) {
    const error = err as NodeJS.ErrnoException & { stderr?: string }
    if (error.code === "ENOENT") {
      const { stdout } = await execFileAsync("nix", ["run", "nixpkgs#jq", "--", ...jqArgs], opts)
      return { ok: true as const, stdout }
    }
    return { ok: false as const, message: error.stderr?.trim() || error.message }
  }
}

export default tool({
  description: "Query JSON data with a jq filter. Provide exactly one of input (JSON string) or file (path to a JSON file).",
  args: {
    filter: tool.schema.string().describe("jq filter expression, e.g. '.users[] | {name, id}'"),
    input: tool.schema.string().describe("JSON string to query"),
    file: tool.schema.string().describe("Path to a JSON file to query"),
    compact: tool.schema.boolean().optional().describe("Compact output (no pretty-print)"),
  },
  async execute(args) {
    const { filter, input, file, compact } = args
    if ((input !== undefined) === (file !== undefined))
      return "Error: provide exactly one of input or file."
    const jqArgs = compact ? ["-c", filter] : [filter]
    const result = file
      ? await runJq([...jqArgs, file], { maxBuffer: 16 * 1024 * 1024 })
      : await runJq(jqArgs, { input, maxBuffer: 16 * 1024 * 1024 })
    if (!result.ok) return `jq error: ${result.message}`
    return result.stdout || "(empty)"
  },
})
