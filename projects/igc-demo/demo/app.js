const ASSET = "./assets/runtime";
const AUDIO = {
  lobby: `${ASSET}/shared/audio/lobby-bronze-hearth-amen.mp3`,
  mini: `${ASSET}/shared/audio/mini-lobby-crown-of-echoes.mp3`,
};

const games = [
  {
    id: "amun",
    title: "阿蒙的寶藏",
    provider: "GameConverge",
    category: "Slot",
    style: "遺跡探險",
    art: `${ASSET}/shared/game-art/01_ancient_mask.png`,
    recommended: 98,
    popular: 91,
    latest: 4,
  },
  {
    id: "emerald",
    title: "Emerald Relic",
    provider: "GoWin",
    category: "Slot",
    style: "寶石祕境",
    art: `${ASSET}/shared/game-art/02_emerald_relic.png`,
    recommended: 96,
    popular: 84,
    latest: 8,
  },
  {
    id: "dragon",
    title: "Dragon's Hoard",
    provider: "Hacksaw",
    category: "Jackpot",
    style: "火焰地窟",
    art: `${ASSET}/shared/game-art/03_dragon_eye.png`,
    recommended: 94,
    popular: 99,
    latest: 3,
  },
  {
    id: "rune",
    title: "Rune of Fortune",
    provider: "Galexsys",
    category: "Table",
    style: "符文魔法",
    art: `${ASSET}/shared/game-art/05_rune_stone.png`,
    recommended: 90,
    popular: 77,
    latest: 6,
  },
  {
    id: "golden",
    title: "Golden Empire",
    provider: "Acewin",
    category: "Jackpot",
    style: "遺跡探險",
    art: `${ASSET}/shared/game-art/04_golden_ruin.png`,
    recommended: 88,
    popular: 86,
    latest: 2,
  },
  {
    id: "vault",
    title: "Mystic Vault",
    provider: "JILI",
    category: "Live",
    style: "機關密室",
    art: `${ASSET}/shared/game-art/06_mystic_vault.png`,
    recommended: 86,
    popular: 74,
    latest: 9,
  },
  {
    id: "jungle",
    title: "Jungle Temple",
    provider: "FC",
    category: "Slot",
    style: "叢林神廟",
    art: `${ASSET}/shared/game-art/07_jungle_temple.png`,
    recommended: 83,
    popular: 81,
    latest: 5,
  },
  {
    id: "crystal",
    title: "Crystal Cavern",
    provider: "GameConverge",
    category: "Slot",
    style: "寶石祕境",
    art: `${ASSET}/shared/game-art/08_crystal_cavern.png`,
    recommended: 99,
    popular: 95,
    latest: 1,
  },
  {
    id: "fire",
    title: "Fire Strike",
    provider: "Hacksaw",
    category: "Arcade",
    style: "火焰地窟",
    art: `${ASSET}/shared/game-art/09_fire_axe.png`,
    recommended: 84,
    popular: 88,
    latest: 7,
  },
  {
    id: "fire-2",
    title: "Ember Axe",
    provider: "Acewin",
    category: "Arcade",
    style: "火焰地窟",
    art: `${ASSET}/shared/game-art/09_fire_axe.png`,
    recommended: 78,
    popular: 79,
    latest: 10,
  },
  {
    id: "emerald-2",
    title: "Emerald Chain",
    provider: "GoWin",
    category: "Table",
    style: "寶石祕境",
    art: `${ASSET}/shared/game-art/02_emerald_relic.png`,
    recommended: 75,
    popular: 70,
    latest: 11,
  },
  {
    id: "rune-2",
    title: "Blue Rune Gate",
    provider: "JILI",
    category: "Live",
    style: "符文魔法",
    art: `${ASSET}/shared/game-art/05_rune_stone.png`,
    recommended: 73,
    popular: 72,
    latest: 12,
  },
];

const filterSets = {
  providers: ["GameConverge", "GoWin", "Hacksaw", "Galexsys", "Acewin", "JILI", "FC"],
  categories: ["Slot", "Jackpot", "Table", "Live", "Arcade"],
  styles: ["遺跡探險", "寶石祕境", "火焰地窟", "符文魔法", "機關密室", "叢林神廟"],
};

const state = {
  query: "",
  sort: "recommended",
  filterTab: "providers",
  selected: {
    providers: new Set(),
    categories: new Set(),
    styles: new Set(),
  },
  currentGame: games[7],
  favoriteIds: new Set(),
  muted: false,
  audioStarted: false,
  audioScene: "lobby",
};

function syncScale() {
  const isCoarsePointer = window.matchMedia("(hover: none) and (pointer: coarse)").matches;
  const isMobileViewport = window.innerWidth <= 767 || (window.innerWidth <= 1000 && window.innerHeight <= 500);
  const isMobileDevice = isCoarsePointer || isMobileViewport;
  const isLandscapePhone = isMobileDevice && window.innerWidth > window.innerHeight && window.innerHeight <= 500;
  const layout = isLandscapePhone ? "landscape-phone" : "portrait";
  const layoutWidth = isLandscapePhone ? 852 : 393;
  const layoutHeight = isLandscapePhone ? 393 : 852;
  const widthScale = window.innerWidth / layoutWidth;
  const heightScale = window.innerHeight / layoutHeight;
  const scale = Math.max(0.32, Math.min(widthScale, heightScale, 1.12));
  const rawAngle =
    typeof screen.orientation?.angle === "number"
      ? screen.orientation.angle
      : typeof window.orientation === "number"
        ? window.orientation
        : 90;
  const angle = ((rawAngle % 360) + 360) % 360;
  const rotation = isLandscapePhone && angle === 270 ? "-90deg" : "90deg";

  document.documentElement.dataset.layout = layout;
  document.documentElement.dataset.device = isMobileDevice ? "mobile" : "desktop";
  document.documentElement.style.setProperty("--phone-scale", String(scale));
  document.documentElement.style.setProperty("--phone-rotate", rotation);
}

const els = {
  phone: document.querySelector(".phone"),
  pcBackdrop: document.querySelector(".pc-backdrop"),
  lobbyView: document.querySelector("#lobbyView"),
  miniView: document.querySelector("#miniView"),
  gameGrid: document.querySelector("#gameGrid"),
  gameScroll: document.querySelector("#gameScroll"),
  searchInput: document.querySelector("#searchInput"),
  activeChips: document.querySelector("#activeChips"),
  overlay: document.querySelector("#overlay"),
  filterButton: document.querySelector("#filterButton"),
  sortButton: document.querySelector("#sortButton"),
  filterSheet: document.querySelector("#filterSheet"),
  sortSheet: document.querySelector("#sortSheet"),
  filterOptions: document.querySelector("#filterOptions"),
  clearFilters: document.querySelector("#clearFilters"),
  applyFilters: document.querySelector("#applyFilters"),
  clearSort: document.querySelector("#clearSort"),
  filterTabs: Array.from(document.querySelectorAll("[data-filter-tab]")),
  sortOptions: Array.from(document.querySelectorAll("[data-sort]")),
  navItems: Array.from(document.querySelectorAll(".nav-item")),
  musicButtons: Array.from(document.querySelectorAll(".music-button")),
  miniArt: document.querySelector("#miniArt"),
  miniTitle: document.querySelector("#miniTitle"),
  miniProvider: document.querySelector("#miniProvider"),
  favoriteButton: document.querySelector("#favoriteButton"),
  toast: document.querySelector("#toast"),
};

const audioTracks = Object.fromEntries(
  Object.entries(AUDIO).map(([key, path]) => {
    const track = new Audio(new URL(path, window.location.href).href);
    track.loop = true;
    track.preload = "auto";
    track.volume = 0.45;
    return [key, track];
  }),
);
let toastTimer;

function getFilteredGames() {
  const query = state.query.trim().toLowerCase();
  const matchesSet = (key, value) => state.selected[key].size === 0 || state.selected[key].has(value);

  return games
    .filter((game) => {
      const text = `${game.title} ${game.provider} ${game.category} ${game.style}`.toLowerCase();
      return (
        (!query || text.includes(query)) &&
        matchesSet("providers", game.provider) &&
        matchesSet("categories", game.category) &&
        matchesSet("styles", game.style)
      );
    })
    .sort((a, b) => {
      if (state.sort === "latest") return a.latest - b.latest;
      if (state.sort === "popular") return b.popular - a.popular;
      return b.recommended - a.recommended;
    });
}

function renderGames() {
  const fragment = document.createDocumentFragment();

  getFilteredGames().forEach((game) => {
    const card = document.createElement("button");
    card.className = "game-card";
    card.type = "button";
    card.dataset.gameId = game.id;
    card.setAttribute("aria-label", `進入 ${game.title} 迷你廳`);
    card.innerHTML = `
      <img class="game-card-art" src="${game.art}" alt="" loading="lazy" />
      <img class="game-card-frame" src="${ASSET}/mobile-lobby/game-card/card-frame-118x160-v01.png" alt="" />
      <span class="game-card-title">${game.title}</span>
      <span class="game-card-provider">${game.provider}</span>
    `;
    fragment.appendChild(card);
  });

  els.gameGrid.replaceChildren(fragment);
}

function renderChips() {
  const chips = [];
  if (state.query.trim()) chips.push(`搜尋：${state.query.trim()}`);
  Object.values(state.selected).forEach((set) => set.forEach((value) => chips.push(value)));

  els.activeChips.replaceChildren(
    ...chips.slice(0, 3).map((label) => {
      const chip = document.createElement("span");
      chip.className = "chip";
      chip.textContent = label;
      return chip;
    }),
  );
}

function renderFilterOptions() {
  const values = filterSets[state.filterTab];
  const selected = state.selected[state.filterTab];
  const buttons = values.map((value) => {
    const button = document.createElement("button");
    button.className = `option-button${selected.has(value) ? " is-selected" : ""}`;
    button.type = "button";
    button.textContent = value;
    button.dataset.value = value;
    button.addEventListener("click", () => {
      if (selected.has(value)) selected.delete(value);
      else selected.add(value);
      renderFilterOptions();
      renderChips();
    });
    return button;
  });

  els.filterOptions.replaceChildren(...buttons);
  els.filterTabs.forEach((tab) => {
    tab.classList.toggle("is-active", tab.dataset.filterTab === state.filterTab);
  });
}

function renderSort() {
  els.sortOptions.forEach((button) => {
    button.classList.toggle("is-active", button.dataset.sort === state.sort);
  });
}

function openSheet(sheet) {
  els.overlay.classList.add("is-open");
  els.overlay.setAttribute("aria-hidden", "false");
  sheet.classList.add("is-open");
  sheet.setAttribute("aria-hidden", "false");
}

function closeSheets() {
  els.overlay.classList.remove("is-open");
  els.overlay.setAttribute("aria-hidden", "true");
  [els.filterSheet, els.sortSheet].forEach((sheet) => {
    sheet.classList.remove("is-open");
    sheet.setAttribute("aria-hidden", "true");
  });
}

function showMiniLobby(game) {
  state.currentGame = game;
  els.phone.dataset.view = "mini";
  els.lobbyView.classList.remove("is-active");
  els.miniView.classList.add("is-active");
  els.miniArt.src = game.art;
  els.miniTitle.textContent = game.title;
  els.miniProvider.textContent = game.provider;
  els.favoriteButton.classList.toggle("is-favorite", state.favoriteIds.has(game.id));
  switchAudioScene("mini");
  closeSheets();
}

function showLobby(nav = "home") {
  els.phone.dataset.view = "lobby";
  els.miniView.classList.remove("is-active");
  els.lobbyView.classList.add("is-active");
  els.navItems.forEach((item) => item.classList.toggle("is-active", item.dataset.nav === nav));
  switchAudioScene("lobby");
  closeSheets();
}

function applySearchAndFilters() {
  renderGames();
  renderChips();
  els.gameScroll.scrollTop = 0;
}

function setMuted(nextMuted) {
  state.muted = nextMuted;
  els.musicButtons.forEach((button) => {
    button.classList.toggle("is-muted", state.muted);
    button.setAttribute("aria-label", state.muted ? "取消靜音" : "靜音背景音樂");
  });
  Object.values(audioTracks).forEach((track) => {
    track.muted = state.muted;
  });
  if (!state.muted && state.audioStarted) {
    playCurrentAudio().catch(() => {
      state.audioStarted = false;
    });
  }
}

async function startAudio() {
  try {
    await playCurrentAudio();
    state.audioStarted = true;
  } catch {
    state.audioStarted = false;
  }
}

async function playCurrentAudio() {
  const currentTrack = audioTracks[state.audioScene];

  Object.entries(audioTracks).forEach(([key, track]) => {
    track.muted = state.muted;
    if (key !== state.audioScene) track.pause();
  });

  if (state.muted) return;
  await currentTrack.play();
}

function switchAudioScene(scene) {
  if (state.audioScene === scene) return;
  const previousTrack = audioTracks[state.audioScene];
  state.audioScene = scene;
  previousTrack.pause();
  previousTrack.currentTime = 0;
  if (state.audioStarted && !state.muted) {
    playCurrentAudio().catch(() => {
      state.audioStarted = false;
    });
  }
}

function notify(message) {
  window.clearTimeout(toastTimer);
  els.toast.textContent = message;
  els.toast.classList.add("is-visible");
  toastTimer = window.setTimeout(() => els.toast.classList.remove("is-visible"), 1800);
}

function bindEvents() {
  els.searchInput.addEventListener("input", (event) => {
    state.query = event.target.value;
    applySearchAndFilters();
  });

  els.filterButton.addEventListener("click", () => {
    renderFilterOptions();
    openSheet(els.filterSheet);
  });

  els.sortButton.addEventListener("click", () => {
    renderSort();
    openSheet(els.sortSheet);
  });

  els.overlay.addEventListener("click", closeSheets);

  els.filterTabs.forEach((button) => {
    button.addEventListener("click", () => {
      state.filterTab = button.dataset.filterTab;
      renderFilterOptions();
    });
  });

  els.clearFilters.addEventListener("click", () => {
    Object.values(state.selected).forEach((set) => set.clear());
    renderFilterOptions();
    applySearchAndFilters();
  });

  els.applyFilters.addEventListener("click", () => {
    applySearchAndFilters();
    closeSheets();
  });

  els.sortOptions.forEach((button) => {
    button.addEventListener("click", () => {
      state.sort = button.dataset.sort;
      renderSort();
      applySearchAndFilters();
    });
  });

  els.clearSort.addEventListener("click", () => {
    state.sort = "recommended";
    renderSort();
    applySearchAndFilters();
  });

  document.querySelector(".close-sort").addEventListener("click", closeSheets);

  els.gameGrid.addEventListener("click", (event) => {
    const card = event.target.closest(".game-card");
    if (!card) return;
    const game = games.find((item) => item.id === card.dataset.gameId);
    if (game) showMiniLobby(game);
  });

  els.navItems.forEach((item) => {
    item.addEventListener("click", () => {
      if (item.dataset.nav === "home") {
        showLobby("home");
        return;
      }
      els.navItems.forEach((nav) => nav.classList.toggle("is-active", nav === item));
      showLobby(item.dataset.nav);
      notify(`${item.textContent.trim()} demo state`);
    });
  });

  els.musicButtons.forEach((button) => {
    button.addEventListener("click", async () => {
      await startAudio();
      setMuted(!state.muted);
    });
  });

  document.addEventListener(
    "pointerdown",
    () => {
      if (!state.audioStarted && !state.muted) startAudio();
    },
    { once: true },
  );

  els.favoriteButton.addEventListener("click", () => {
    const id = state.currentGame.id;
    if (state.favoriteIds.has(id)) state.favoriteIds.delete(id);
    else state.favoriteIds.add(id);
    els.favoriteButton.classList.toggle("is-favorite", state.favoriteIds.has(id));
  });

  document.querySelector(".play-button").addEventListener("click", () => {
    notify(`${state.currentGame.title} launch placeholder`);
  });
}

function init() {
  syncScale();
  renderGames();
  renderChips();
  renderFilterOptions();
  renderSort();
  bindEvents();

  startAudio().then(() => {
    if (!state.audioStarted) notify("點一下畫面即可啟動背景音樂");
  });
}

window.addEventListener("resize", syncScale);
window.addEventListener("orientationchange", syncScale);
screen.orientation?.addEventListener?.("change", syncScale);
init();
