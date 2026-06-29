# /plan — Feature Planning

Create a structured implementation plan for the requested feature.

## Steps

1. **Read context** before starting:
   - `AGENTS.md` — Golden Rules
   - `SSOT.md` — Current architecture
   - `PRODUCT.md` — Product context
   - Files relevant to the feature

2. **Use the `planner` agent** to produce a plan with the following structure:
   - Scope (what is and is not included)
   - Unknowns (questions that need to be answered)
   - Task breakdown per layer (Models → Services → Views)
   - Risk assessment

3. **DO NOT start coding** until the user confirms the plan.

4. Ask: "Does this plan look right? Anything to change before we start implementation?"

## Example Usage
```
/plan Journal entry list with pagination
/plan Daily journaling reminder notification
/plan Backend API integration for data sync
```
