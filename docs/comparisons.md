# Before / After Comparisons

Video comparisons for each nav mesh fix in this repository, showing bot behavior before and after applying the fix.

## How to add a video

**Option A — native GitHub upload (recommended, plays inline on the page):**
Drag and drop the video file into a GitHub issue or pull request comment box (a throwaway one is fine), then copy the generated `https://github.com/Ferks-FK/l4d2-nav-fixes/assets/...` URL and paste it on its own line under the relevant fix below (or wrap it as `<video src="URL" controls></video>`).

**Option B — YouTube thumbnail link:**
```
[![Before/After](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://youtu.be/VIDEO_ID)
```

---

## c1m1_hotel

### Changes 1 and 2 — Burning corridor (fire16 and fire14) _(optional nav change)_

Bots avoided a burning corridor and took a much longer, more dangerous route around it. For each of the corridor's two fires, the map intentionally blocks the nav areas with a `func_nav_blocker` and the fire's `trigger_hurt` marks them as damaging. The change removes both and recreates the fire's damage from the script, so bots run through the fire while still taking damage.

Script: [`scripts/vscripts/nav_changes/c1m1_hotel_navchanges.nut`](../scripts/vscripts/nav_changes/c1m1_hotel_navchanges.nut)

## Before / After
https://github.com/user-attachments/assets/4710dd5b-f3b0-4b53-a278-2621c258d40f

https://github.com/user-attachments/assets/6daf3037-428c-48c3-b6df-41af3660081e


## c1m3_mall

### Fix 1 — Mall corridor point of no return

Bots got stuck on the lower side of a one-way drop in the mall corridor, unable to find a route back to the group.

Script: [`scripts/vscripts/nav_fixes/c1m3_mall_navfixes.nut`](../scripts/vscripts/nav_fixes/c1m3_mall_navfixes.nut)

## Before / After
https://github.com/user-attachments/assets/bc143375-31d6-44e9-8fe6-93ca857bb427

https://github.com/user-attachments/assets/79246c71-468b-4f74-8fab-0cf351fafd54



