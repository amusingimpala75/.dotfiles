# Flake updates

Language for proposing and maintaining dependency updates.

## Language

**Update track**:
A recurring category of dependency updates: bleeding updates cover selected fast-moving inputs; full updates cover every input.

**Refresh**:
Regenerating a proposed update against the current accepted configuration and current upstream dependencies.
_Avoid_: Rebase

**Bot-managed PR**:
An update proposal still exclusively maintained by the update bot.

**User-managed PR**:
An update proposal taken over by a person, which the bot must leave untouched until it is closed or merged.
