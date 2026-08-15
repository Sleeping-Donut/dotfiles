# Third-party skills

Skills vendored from external sources into this directory. The prefix in the skill `name` (and folder name) marks the source, so it's obvious which skills to check for upstream updates.

- **matt pocock skills**
  - prefix: `mp`
  - source: https://github.com/mattpocock/skills
  - notes:
    - Strip Claude-only frontmatter (`disable-model-invocation: true`).
    - Add `slash: true` to wrappers.
    - Prefix `name:` + folder with `mp-`.
    - Re-point internal skill refs to `mp-` names.
  - skills:
    - `mp-grilling` — https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md
    - `mp-grill-with-docs` — https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md
    - `mp-domain-modeling` — https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md (plus `ADR-FORMAT.md` and `CONTEXT-FORMAT.md`)
    - `mp-grill-me` — https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
    - `mp-teach` — https://github.com/mattpocock/skills/blob/main/skills/productivity/teach/SKILL.md (plus `GLOSSARY-FORMAT.md`, `LEARNING-RECORD-FORMAT.md`, `MISSION-FORMAT.md`, `RESOURCES-FORMAT.md`)
    - `mp-wait-what` — https://github.com/mattpocock/skills/blob/main/skills/productivity/wait-what/SKILL.md
    - `mp-handoff` — https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md
    - `mp-writing-for-agents` — https://github.com/mattpocock/skills/blob/main/skills/productivity/writing-for-agents/SKILL.md (plus `SKILL-MECHANICS.md`)
    - `mp-prototype` — https://github.com/mattpocock/skills/blob/main/skills/engineering/prototype/SKILL.md (plus `LOGIC.md` and `UI.md`)

## Update

Re-fetch from the links above, diff, re-apply `notes`. They're a moving target — re-verify each still applies and edit them when upstream changes.
