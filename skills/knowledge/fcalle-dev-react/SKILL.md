---
name: fcalle-dev-react
description: React patterns — functional components, hooks rules, state management, RSC, accessibility, forms, CSS conventions. Use when writing or reviewing React/Next.js components, hooks, TSX files, or UI logic.
---

## React

- **Functional components + hooks**; class components only when interfacing with legacy code.
- **Server components / RSC** when the framework supports it (Next.js 13+); fetch on the server when you can.
- **One component per file** for non-trivial components; co-locate styles and tests.
- **Props are read-only** — never mutate; derive state instead.
- **`useState` for local UI state, `useReducer` for complex transitions, context for cross-cutting concerns, a real store (Zustand/Redux Toolkit/Jotai) for app state.**
- **No prop drilling beyond 2–3 levels** — lift to context or store.
- **Stable keys** — never use array index as a key for dynamic lists.
- **Memoization is opt-in, not default** — `useMemo`/`useCallback` only when profiling shows a need.
- **Effects are escape hatches** — prefer event handlers and derived state. If you reach for `useEffect`, ask "is this really a side effect of rendering?"
- **Suspense + Error Boundaries** at route level, minimum.
- **Accessibility is non-negotiable** — semantic HTML, ARIA only when semantics fall short, keyboard navigable, color contrast checked.
- **Forms** — controlled inputs for validation-heavy forms, uncontrolled for simple ones; consider `react-hook-form` for complex cases.
- **CSS** — design system first; CSS Modules / Tailwind / vanilla-extract over global styles. No inline styles except for dynamic values.
- **Custom hooks for reusable logic** — name them `use*`. Extract state+effects together, not render logic.
- **Dependency arrays correct and minimal** — no missing deps, no `// eslint-disable-next-line` for deps unless truly necessary.
- **Clean up side effects** — cancel timers, subscriptions, and fetch requests in the effect cleanup (e.g. `AbortController`). No floating promises — `await` or attach `.catch`.
- **Prefer derived state and `useMemo` over `useEffect`** for derived values. Avoid state derived from props.
- **`React.lazy`/dynamic imports** for large route chunks. Do not prematurely micro-optimize with `useCallback`/`memo` — add them only when they measurably matter.
- **No inline objects/arrays in JSX** that break `memo` for no reason; keep props stable where it matters.

## Accessibility

- **Semantic HTML over divs.** Every interactive element must be keyboard-reachable and have an accessible name (label, `aria-label`, `aria-labelledby`).
- **Form controls**: real `<label>` or the UI kit's `label` prop, visible error messages, `required`/`disabled` reflected in the DOM.
- **Manage focus on navigation/modals/drawers** (UI-kit Modal/Drawer handle this — don't reinvent).
- **Preserve the user's colorScheme preferences**; never lock dark mode off.

## Styling

- Follow the project's CSS approach (CSS modules, UI-kit styles, or existing patterns). Responsive before pixel-perfect; design for small screens first unless the project says otherwise.
- No `!important` unless overriding third-party behavior. Keep specificity low and class names descriptive.

## Testing

- **Behavior-first**: assert what the user sees and does, not implementation details. Prefer user-centric queries (`getByRole`, `getByLabelText`, `getByText`) over `testId`.
- **Do not mock code the backend owns** — only mock at process boundaries.

## UI kit (when the project has one)

- Use the project's UI kit components instead of hand-rolling primitives (buttons, modals, tables, inputs, notifications, forms).
- Consult the UI kit's MCP server or docs for accurate component APIs, props, and hooks before writing code — never guess prop names or behaviors.
- Use the kit's form + validation (e.g. `useForm` + zod resolver) instead of bespoke validation.
- Respect the kit theme: use theme tokens (`theme.colors`, `theme.spacing`, `theme.radius`) and provider colorScheme for dark mode. Avoid hardcoded hex colors and magic spacing values.
- Prefer the kit's style props and `styles`/`classNames` API over inline `style={{}}` for one-off tweaks; use `createStyles`/CSS modules for reusable styling.
- Leverage the kit's built-in accessibility (focus rings, labels, keyboard nav) — do not disable it.
