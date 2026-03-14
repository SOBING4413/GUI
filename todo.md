# KBBI Sambung Kata - GUI Demo (Visual Only)

## Design Guidelines

### Design References
- Roblox KBBI Sambung Kata GUI by Sobing4413
- Dark gaming UI with neon accents
- Glassmorphism + dark mode aesthetic

### Color Palette (Default: Biru/Blue Theme)
- Primary Background: #0A0E16 (Deep dark blue-black)
- Card Background: #0C1224 (Dark navy)
- Card Alt: #0F162A (Slightly lighter navy)
- Card Hover: #161E37 (Hover state)
- Panel Background: #090D1C (Panel dark)
- Accent: #3782F0 (Blue accent)
- Accent Light: #5AA5FF (Light blue)
- Accent Dark: #1E5AB4 (Dark blue)
- Stroke: #1C2D55 (Border)
- Stroke Light: #2D4682 (Light border)
- Text Primary: #FFFFFF
- Text Secondary: #AFC3E1 (Light blue-gray)
- Text Muted: #6E82A5 (Muted blue-gray)
- Success: #28C864
- Error: #E63741
- Warning: #F0B428
- Info: #37AAF0

### Theme System (5 themes)
- Merah (Red): accent #E63741
- Hijau (Green): accent #28C864
- Biru (Blue): accent #3782F0 (default)
- Ungu (Purple): accent #9646EB
- Abu-abu (Gray): accent #8C91A0

### Typography
- Title: font-black, 17px equivalent
- Subtitle: font-medium, 10px equivalent
- Labels: font-bold, 9-11px
- Body: font-normal, 11px
- Badges: font-bold, 8-9px

### Key Component Styles
- Main frame: 720x460px, rounded-2xl, dark gradient bg, draggable
- Top bar: dark semi-transparent, accent line below
- Left panel: 220px wide, dark panel with sections
- Right panel: scrollable word list with 50 button slots
- Buttons: alternating dark bg, hover glow, stroke animation
- Notifications: slide-in from right, progress bar, auto-dismiss
- Loading screen: animated globe, book flip, progress bar

### Layout
- Fixed-size window (720x460) centered on screen
- Top bar with title, controls (close, minimize, theme, sort, unload)
- Left sidebar: prefix display, status, auto-answer toggle, tips
- Right content: word list header + scrollable word buttons

## Development Tasks

1. **Index.tsx** - Main page with the KBBI GUI component
2. **KBBIGui.tsx** - Main GUI container with all panels
3. **LoadingScreen.tsx** - Animated loading screen
4. **TopBar.tsx** - Title bar with window controls
5. **LeftPanel.tsx** - Sidebar with prefix, status, auto-answer, tips
6. **WordList.tsx** - Right panel with scrollable word buttons
7. **NotificationSystem.tsx** - Toast notification system
8. **themes.ts** - Theme definitions and context