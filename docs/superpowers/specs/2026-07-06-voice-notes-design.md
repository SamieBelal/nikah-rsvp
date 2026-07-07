# Voice Notes Feature — Design Spec

## Overview

Guests can record and leave a 30-second voice message for Faizah & Samie. A vintage phone button on the invitation page navigates to a recording view. Recordings are stored in Supabase Storage. A private page lets the couple listen back.

## User Flow

1. Guest sees vintage phone button below RSVP button on invitation card
2. Tapping it slides to a new page view (page 3), same transition as RSVP form
3. Guest enters their name, taps record, speaks for up to 30 seconds
4. Guest can play back, re-record, or submit
5. On submit: audio uploads to Supabase Storage, metadata saved to `voice_notes` table
6. Guest sees a thank-you confirmation, same style as RSVP confirmation

## Invitation Page Changes

- Add a vintage rotary phone button below the existing RSVP button on page 1
- Label: "Leave a Voice Note"
- Styled with the site's gold/sage palette, Cormorant Garamond font
- Same `reveal` animation class as other card elements
- Clicking navigates to page 3 (new `#page3` div)

## Recording Page (Page 3)

### Layout
- Back button (top left, same `.back` style as RSVP page)
- Header: "Leave a Voice Note"
- Subtitle: "Record a message for Faizah & Samie"
- Name input field (required, same `.field` style as RSVP form)
- Large circular record button (gold/sage styling)

### Record Button States
- **Idle**: Microphone icon + "Tap to Record"
- **Recording**: Pulsing red ring animation, countdown timer 0:30 → 0:00, "Tap to Stop"
- **Auto-stop**: Recording stops automatically at 30 seconds

### After Recording
- Playback controls: play/pause button with elapsed time display
- "Re-record" button: discards current recording, returns to idle state
- "Send" button: uploads audio and metadata, same `.submit` style as RSVP form
- Send button shows "Sending..." while uploading, disabled during upload

### Confirmation
- Same pattern as RSVP confirmation: header changes to "Thank You", message like "Your voice note has been saved!"
- Option to record another or go back to invitation

## Backend — Supabase

### Storage
- Bucket: `voice-notes`
- File naming: `{uuid}.webm` (or `.mp4` fallback for Safari)
- Public read access (for the private listening page)

### Database Table

```sql
create table public.voice_notes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  file_path text not null,
  duration int default 0,
  created_at timestamptz default now()
);

alter table public.voice_notes enable row level security;

create policy "Public can submit voice notes"
  on public.voice_notes for insert to anon with check (true);

create policy "Public can read voice notes"
  on public.voice_notes for select to anon using (true);
```

### Upload Flow
1. Record audio using MediaRecorder API (webm/opus preferred, mp4 fallback for Safari)
2. On submit: generate a UUID filename
3. Upload audio blob to `voice-notes` bucket via Supabase Storage REST API
4. Insert metadata row into `voice_notes` table
5. Show confirmation on success, error message on failure

## Private Listening Page (`/voicenotes.html`)

### Layout
- Matches site styling (same fonts, colors, paper background)
- Title: "Voice Notes"
- List of all voice notes, newest first
- Each entry shows: name, duration (e.g. "0:23"), date
- Play button next to each entry
- Audio plays inline via HTML `<audio>` element
- Simple, clean — similar to the drawings gallery page

### Data Loading
- Fetch all rows from `voice_notes` table on page load
- Construct audio URLs from `file_path` + Supabase Storage base URL
- No authentication gate (private by obscurity, same as drawings page)

## Audio Recording — Technical Notes

- Use `navigator.mediaDevices.getUserMedia({ audio: true })` to get mic access
- Use `MediaRecorder` API to record
- Preferred MIME type: `audio/webm;codecs=opus` (Chrome/Firefox), fallback to `audio/mp4` (Safari)
- Track elapsed time with `setInterval`, auto-stop at 30s via `mediaRecorder.stop()`
- Collect chunks in `ondataavailable`, create Blob on `onstop`
- Browser support: works on all modern mobile browsers (iOS Safari 14.5+, Chrome, Firefox)

## Styling Notes

- Vintage phone button: inline SVG of a rotary phone icon, gold stroke, sized ~40px, centered above the label text
- Record button: large circle (60-70px), gold border, microphone icon center
- Recording state: red pulsing border animation via CSS keyframes
- All typography: Cormorant Garamond to match existing site
- Color variables: use existing `--gold`, `--sage`, `--sage-deep`, `--paper` CSS custom properties
