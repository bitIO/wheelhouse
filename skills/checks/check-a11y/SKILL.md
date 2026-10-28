---
name: check-a11y
description: Accessibility checklist (WCAG 2.x AA) for reviewing UI changes; keyboard, screen reader, contrast, focus, forms and semantics. Use when verifying or gating work that adds or changes user interface.
---

# Accessibility check

Think about every user: keyboard only, screen reader, low vision, motor impairments. Report findings; don't fix them.

## Checklist

- **Automated first**: an axe-core scan (for example through Playwright), then the manual checks that tools miss.
- **Keyboard**: every action is reachable; logical tab order; visible focus; no focus traps; Escape closes overlays.
- **Screen reader**: labels, roles, landmarks, alt text, heading order. Check the accessibility tree, not the pixels.
- **Contrast**: WCAG AA, 4.5:1 for text and 3:1 for large text and UI components.
- **Focus management**: focus moves to dialogs and returns afterwards; route changes announce the new content.
- **Forms**: every input has a label, errors are identified in text and linked to their field, required fields are announced.
- **Semantics**: real buttons and links instead of clickable divs; native elements before ARIA.
- **Motion**: `prefers-reduced-motion` is respected.

## Report

For each finding give the severity, the WCAG criterion (for example 1.4.3), `file:line`, the barrier and the fix. Separate what the scan found from what you confirmed manually. State what was scanned (tool and scope) and what was checked by hand.
