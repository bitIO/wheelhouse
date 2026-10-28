---
name: conventions-react
description: React and Next.js default conventions — server vs client components, state placement, effects, memoization, forms, styling and UI kits. Use when writing or changing React/Next.js components, hooks or TSX files.
---

The repo's own conventions (`AGENTS.md`, lint rules, existing components) win over these. Accessibility review: `check-a11y`. Tests: `conventions-testing`.

## Components and data

- **Server first** where the framework supports it (Next.js App Router): fetch on the server, and mark `"use client"` only on the leaves that need interactivity.
- **Server state is not app state.** Use RSC or a query cache (TanStack Query, SWR) for server data. Use `useState`/`useReducer` for local UI state, context for cross-cutting values (theme, session), and a store (Zustand, Jotai, Redux Toolkit) only for real client-side app state.
- **Compose before you lift.** Pass `children` or slots first. Reach for context or a store only when drilling goes past 2–3 levels.
- **One non-trivial component per file**, with its styles and tests next to it.
- **Stable keys**: never the array index for lists that can reorder, insert or delete.
- **Suspense and error boundaries** at least at route level.

## Effects

- **Effects are for syncing with external systems**, not for deriving data. Compute derived values during render, and handle user actions in event handlers.
- **Always clean up**: timers, subscriptions, and `AbortController` for fetches. No floating promises.
- Correct dependency arrays. No disabling `react-hooks/exhaustive-deps` without a comment explaining why.
- **Custom hooks (`use*`)** extract state and effects together, not render logic.

## Memoization

- **With React Compiler enabled**: don't add `useMemo`, `useCallback` or `memo` by hand.
- **Without it**: only when profiling shows a cost, or to keep a prop stable for an already memoized child.

## Forms

- Prefer the UI kit's form API, or `react-hook-form`, with schema validation (zod). The same schema validates on the server.
- With server actions, use `useActionState` for pending and error state instead of hand-rolled flags.

## Styling and UI kits

- **The project's UI kit first**: buttons, modals, tables, inputs, notifications and forms come from the kit, not hand-rolled primitives.
- **Check the kit's current docs or MCP server for props and APIs**: they change between majors. For example, Mantine 7+ has no `createStyles`; use CSS modules plus the `classNames`/`styles` props.
- **Theme tokens** (colors, spacing, radius) instead of hard-coded hex values and magic numbers. Respect the user's color scheme; never force dark mode off.
- **CSS modules, Tailwind or the kit's style API** over global CSS. Inline `style` only for truly dynamic values. No `!important` except to override third-party styles.
- Mobile first unless the project says otherwise.
- Don't disable the kit's built-in accessibility (focus rings, labels, keyboard handling).
