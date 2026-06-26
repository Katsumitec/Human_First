# IGC Dungeon Ruins Demo

Static HTML demo for the IGC Dungeon Ruins lobby.

## Preview

Open `index.html` directly in a browser, or run a local static server:

```bash
cd /Users/erinlin/Developer/IGC-Demo
python3 -m http.server 8765
```

Then open:

```text
http://127.0.0.1:8765/
```

## Publish With GitHub Pages

1. Create a new public GitHub repository.
2. Push this folder to the repository.
3. In GitHub, go to `Settings > Pages`.
4. Set `Source` to `Deploy from a branch`.
5. Select branch `main` and folder `/root`.

The site URL will be similar to:

```text
https://<github-username>.github.io/<repository-name>/
```

## Files

- `index.html` - demo entry point
- `styles.css` - visual layout and interactions
- `app.js` - demo state and UI behavior
- `assets/` - local images and audio assets
