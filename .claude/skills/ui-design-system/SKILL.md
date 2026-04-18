---
name: ui-design-system
description: UI design system toolkit for Senior UI Designer including design token generation, component documentation, responsive design calculations, design domain rules, and multi-stack implementation guidelines. Use for creating design systems, maintaining visual consistency, and facilitating design-dev collaboration.
---

# UI Design System

Professional toolkit for creating and maintaining scalable design systems.

## Core Capabilities
- Design token generation (colors, typography, spacing)
- Component system architecture
- Responsive design calculations
- Accessibility compliance
- Developer handoff documentation
- Multi-stack implementation (React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, shadcn/ui)

## Key Scripts

### design_token_generator.py
Generates complete design system tokens from brand colors.

**Usage**: `python scripts/design_token_generator.py [brand_color] [style] [format]`
- Styles: modern, classic, playful
- Formats: json, css, scss

**Features**:
- Complete color palette generation
- Modular typography scale
- 8pt spacing grid system
- Shadow and animation tokens
- Responsive breakpoints
- Multiple export formats

## Design Domains (by Priority)

| Priority | Category | Impact |
|----------|----------|--------|
| 1 | Accessibility | CRITICAL |
| 2 | Touch & Interaction | CRITICAL |
| 3 | Performance | HIGH |
| 4 | Layout & Responsive | HIGH |
| 5 | Typography & Color | MEDIUM |
| 6 | Animation | MEDIUM |
| 7 | Style Selection | MEDIUM |
| 8 | Charts & Data | LOW |

### Accessibility Rules (CRITICAL)

| Rule | Do |
|------|-----|
| `color-contrast` | Minimum 4.5:1 ratio for normal text |
| `focus-states` | Visible focus rings on interactive elements |
| `alt-text` | Descriptive alt text for meaningful images |
| `aria-labels` | aria-label for icon-only buttons |
| `keyboard-nav` | Tab order matches visual order |
| `form-labels` | Use label with for attribute |

### Touch & Interaction (CRITICAL)

| Rule | Do |
|------|-----|
| `touch-target-size` | Minimum 44x44px touch targets |
| `hover-vs-tap` | Use click/tap for primary interactions |
| `loading-buttons` | Disable button during async operations |
| `error-feedback` | Clear error messages near problem |
| `cursor-pointer` | Add cursor-pointer to clickable elements |

### Layout & Responsive (HIGH)

| Rule | Do |
|------|-----|
| `viewport-meta` | width=device-width, initial-scale=1 |
| `readable-font-size` | Minimum 16px body text on mobile |
| `horizontal-scroll` | Ensure content fits viewport width |
| `z-index-management` | Define z-index scale (10, 20, 30, 50) |

## Stack Guidelines

When implementing UI, default to `html-tailwind` unless the user specifies a stack.

| Stack | Focus |
|-------|-------|
| `html-tailwind` | Tailwind utilities, responsive, a11y (DEFAULT) |
| `react` | State, hooks, performance, patterns |
| `nextjs` | SSR, routing, images, API routes |
| `vue` | Composition API, Pinia, Vue Router |
| `svelte` | Runes, stores, SvelteKit |
| `swiftui` | Views, State, Navigation, Animation |
| `react-native` | Components, Navigation, Lists |
| `flutter` | Widgets, State, Layout, Theming |
| `shadcn` | shadcn/ui components, theming, forms, patterns |

## Common Professional UI Rules

### Icons & Visual Elements

| Rule | Do | Don't |
|------|----|----- |
| **No emoji icons** | Use SVG icons (Heroicons, Lucide, Simple Icons) | Use emojis like 🎨 🚀 ⚙️ as UI icons |
| **Stable hover states** | Use color/opacity transitions on hover | Use scale transforms that shift layout |
| **Correct brand logos** | Research official SVG from Simple Icons | Guess or use incorrect logo paths |
| **Consistent icon sizing** | Use fixed viewBox (24x24) with w-6 h-6 | Mix different icon sizes randomly |

### Light/Dark Mode Contrast

| Rule | Do | Don't |
|------|----|----- |
| **Glass card light mode** | Use `bg-white/80` or higher opacity | Use `bg-white/10` (too transparent) |
| **Text contrast light** | Use `#0F172A` (slate-900) for text | Use `#94A3B8` (slate-400) for body text |
| **Muted text light** | Use `#475569` (slate-600) minimum | Use gray-400 or lighter |
| **Border visibility** | Use `border-gray-200` in light mode | Use `border-white/10` (invisible) |

### Layout & Spacing

| Rule | Do | Don't |
|------|----|----- |
| **Floating navbar** | Add `top-4 left-4 right-4` spacing | Stick navbar to `top-0 left-0 right-0` |
| **Content padding** | Account for fixed navbar height | Let content hide behind fixed elements |
| **Consistent max-width** | Use same `max-w-6xl` or `max-w-7xl` | Mix different container widths |

## Pre-Delivery Checklist

### Visual Quality
- [ ] No emojis used as icons (use SVG instead)
- [ ] All icons from consistent icon set (Heroicons/Lucide)
- [ ] Brand logos are correct (verified from Simple Icons)
- [ ] Hover states don't cause layout shift
- [ ] Use theme colors directly (bg-primary) not var() wrapper

### Interaction
- [ ] All clickable elements have `cursor-pointer`
- [ ] Hover states provide clear visual feedback
- [ ] Transitions are smooth (150-300ms)
- [ ] Focus states visible for keyboard navigation

### Light/Dark Mode
- [ ] Light mode text has sufficient contrast (4.5:1 minimum)
- [ ] Glass/transparent elements visible in light mode
- [ ] Borders visible in both modes
- [ ] Test both modes before delivery

### Layout
- [ ] Floating elements have proper spacing from edges
- [ ] No content hidden behind fixed navbars
- [ ] Responsive at 375px, 768px, 1024px, 1440px
- [ ] No horizontal scroll on mobile

### Accessibility
- [ ] All images have alt text
- [ ] Form inputs have labels
- [ ] Color is not the only indicator
- [ ] `prefers-reduced-motion` respected
