# WuFlow UI Style Guide

**Purpose:** Give WuFlow a calm, recognizable visual identity inspired by its Wu Wei icon: ocean, night sky, warm paper, and a quiet sun. Keep the UI focused on observing behavior, not judging it.

## Principles

- **Content leads.** Background imagery and animation add atmosphere; they should not compete with text or controls.
- **Glass has a job.** Use material to group related information or distinguish an interactive surface. Avoid layering materials when one surface is enough.
- **One clear next action.** Give each screen or card a visually obvious primary action. Keep secondary actions quieter.
- **Reuse before adding variants.** Prefer the shared patterns below; introduce a new treatment when it solves a real need.
- **Use system behavior.** Prefer semantic colors and Dynamic Type text styles so the UI remains usable across appearance and accessibility settings.

## Starter tokens

These are initial values to validate on real screens, not a locked design system.

| Token | Starting value | Use |
|---|---:|---|
| Spacing | 8, 12, 16, 24 pt | Compact gaps, related content, standard insets, section separation |
| Card corners | 20 pt | Home and activity information cards |
| Control corners | Capsule or 12 pt | Prominent buttons and compact controls |
| Screen inset | 16 pt | Standard horizontal content inset; use 20 pt when the layout needs breathing room |
| Canvas | Parchment `#F5EFE2` | Main screen background |
| Surface | Paper `#FFF9ED` | Cards and grouped content |
| Primary ink | Midnight navy `#102B45` | Main text, icons, primary buttons, selected state |
| Supporting accent | Ocean blue `#286B8A` | Progress, secondary actions, links |
| Supporting surface | Mist blue `#BCD8E1` | Secondary cards and progress tracks |
| Occasional accent | Vermilion `#D84B36` | Incident markers or a notable insight; never a general-purpose warning color |
| Incident-free status | Matcha sage `#3B7A57` | Calm, positive marker for reduce activities between incidents |
| Above-goal status | Kin gold `#C59B27` | Goal exceeded bar, badge, and subtle card accent |
| Dividers | Muted parchment / semantic separator | Quietly separate related content |
| Text hierarchy | System styles | Screen title, `.headline` section title, `.subheadline` card title, `.footnote` supporting detail |

The hex values are starting estimates taken from the app icon and should be contrast-checked in the app. Prefer semantic foreground styles for ordinary text. Use opaque or lightly tinted surfaces as the default; reserve glass for places where translucency adds value. The full-screen plant photo is no longer the assumed Home canvas. Activity photography can provide the expressive imagery.

## Shared patterns

### Information card

- Use one rounded surface to group a related set of values and labels.
- Keep the title and primary value easy to scan; supporting copy should be secondary in both size and contrast.
- Use a consistent inset (start at 16 pt) and internal spacing from the token scale.
- Choose material or a solid semantic surface based on legibility; do not stack both by default.

### Primary action

- Use midnight navy for the main action with a clear verb label and a comfortable hit area. Use ocean blue for supporting emphasis.
- Keep icon and label aligned; do not rely on color alone to convey the action.
- Use a quieter style for secondary actions and destructive styling for destructive actions.

### Section heading

- Use a consistent heading style and align it with the content below it.
- Put a related navigation action such as “See all” on the same row, styled as secondary.
- Separate sections with spacing before adding dividers or additional card borders.

## Home screen direction

- **Greeting:** Keep it warm and personal without letting the greeting outweigh the behavioral snapshot. The static profile photo is omitted because it is not an account control or user-editable identity; the app icon and greeting provide identity with less visual weight.
- **Today’s behavior:** Show progress entries and reduce activities with no incident logged as separate, factual measures. Avoid combining them into a “completion” score. Keep a clear “View Activities” action to reach the full list.
- **Your Focus:** Use one 170 × 190 pt card pattern for both activity types. Increase and maintain activities show goal progress; decrease activities show time since the last incident. Crop images to fill by default; the shared image view also supports fitting the full image when that is preferable. Let activity photos carry personality.
- **Progress status colors:** Use muted mist for not started, ocean blue while in progress, midnight navy when the goal is reached, and kin gold for above-goal progress. Pair completed and above-goal colors with short status labels; reserve a soft gold halo for above-goal cards. Use matcha sage for incident-free reduce activities.
- **Quick Actions:** Use consistent compact controls. Give the leading action the navy treatment and keep secondary actions quiet.
- **Attention insight:** Show the leading life area and its share (for example, “Health, 96% this period”) in one compact surface, without nesting a card inside a glass frame. Keep the lightbulb as the insight cue and use a small custom yin-yang mark as its highlight bullet.
- **Canvas:** Use parchment behind the content, paper surfaces for cards, and the icon’s ocean colors for structure. A compact mountain, sun, and wave illustration may sit beside the greeting; avoid a full-screen image behind every section.

## Activities screen direction

- **Header:** Reuse the mountain, sun, and wave artwork. Let glass summary pills show activity count and streak; use glass filters only if they remain compact and readable over the artwork.
- **Activity rows:** Use equal thumbnail frames for both photos and icons, with the same crop, corner radius, and subtle border. Keep activity name, current amount, target, status, and progress aligned consistently.
- **Decrease milestones:** Show time incident-free and progress toward the next milestone (for example, 2d 5h toward 3 days). Use matcha sage as the calm milestone-progress color; the milestone ladder should be defined as a product rule before implementation.
- **Debug controls:** Keep notification diagnostics out of the activity list. If needed, place them in a debug-only menu.
- **Brand mark:** Use the yin-yang mark sparingly as a section accent rather than repeating it on every activity row.

## Review checklist

- Can the screen’s main purpose and next action be understood at a glance?
- Are cards, controls, and section headings using the shared spacing and shape patterns?
- Is text readable on parchment, paper, and mist-blue surfaces?
- Does the layout remain clear with larger text and in light and dark appearance?
- Does each accent color communicate a consistent meaning?

## First validation pass

Apply the palette and canvas to Home first. Review the behavior snapshot, mixed-type Focus cards, quick actions, and attention insight together before extending the patterns to Activities or Insights. Adjust the starter tokens based on that review rather than expanding the guide preemptively.
