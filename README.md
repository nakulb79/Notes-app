# Notes-app

A notes app built with Flutter, developed level-by-level from MVP to advanced features.

## Current Progress

### ✅ Level 2 — Step 1 (Live Search + Pinned-ready Model)

Implemented:
- Material 3 app shell
- Hive local storage bootstrap
- Note model (`id`, `title`, `content`, `createdAt`, `updatedAt`, `isPinned`)
- Notes list bound to Hive via `ValueListenableBuilder` for live reactive updates
- Create note flow
- Edit existing note flow
- Delete note from list
- Live search by title and content
- Pinned-first sorting logic (for upcoming pin action)
- Empty state widget for no-notes UX
- Clean architecture structure:
  - `lib/models`
  - `lib/screens`
  - `lib/services`
  - `lib/widgets`

## Next Step

Level 2 next steps:
- Add pin/unpin interactions
- Sorting controls (updated/created/title)
- Swipe actions
- Dark mode toggle
