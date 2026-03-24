# Notes-app

A notes app built with Flutter, developed level-by-level from MVP to advanced features.

## Current Progress

### ✅ Level 3 — Step 5 (Quick Color Change + Attachments)

Implemented:
- Material 3 app shell
- Hive local storage bootstrap
- Note model (`id`, `title`, `content`, `createdAt`, `updatedAt`, `isPinned`, `tags`, `metadata`)
- Notes list bound to Hive via `ValueListenableBuilder` for live reactive updates
- Create note flow
- Edit existing note flow
- Delete note from list
- Live search by title and content
- Pin/unpin interaction from notes list
- Swipe actions: right to pin/unpin, left to delete
- Sorting controls: recent, oldest, title (+ pinned-first toggle)
- Theme mode selector: System / Light / Dark
- Theme preference persisted locally in Hive settings box
- Add/edit tags on note form
- Tag suggestions from existing notes
- Tag filtering chips in notes list
- Note colors stored in metadata and editable from note form
- Colorized note cards in notes list
- Quick color change from notes list (long press)
- Markdown edit/preview toggle in note editor
- Markdown rendering preview with Material 3 typography
- Image attachments stored as local file paths in metadata
- Attachment picker and thumbnail previews in editor
- Pinned-first sorting logic
- Empty state widget for no-notes UX
- Clean architecture structure:
  - `lib/models`
  - `lib/screens`
  - `lib/services`
  - `lib/widgets`

## Next Step

Level 3 next steps:
- Markdown quick-format toolbar
- Camera capture for attachments
- Attachment reorder and captions
