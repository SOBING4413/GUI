import { useState, useCallback, useEffect, useMemo } from "react";
import { Theme, themes } from "@/lib/themes";
import TopBar from "./TopBar";
import LeftPanel from "./LeftPanel";
import WordList from "./WordList";
import LoadingScreen from "./LoadingScreen";
import NotificationSystem, { useNotifications } from "./NotificationSystem";

// Demo word data organized by prefix
const ALL_DEMO_WORDS: Record<string, Array<{ word: string; danger: "impossible" | "killer" | "danger" | "risky" | "normal" | "safe"; dangerLabel: string; dangerColor: string }>> = {
  BA: [
    { word: "bax", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "baz", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "bav", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "baf", danger: "danger", dangerLabel: "⚠️ BAHAYA", dangerColor: "#FF961E" },
    { word: "baw", danger: "danger", dangerLabel: "⚠️ BAHAYA", dangerColor: "#FF961E" },
    { word: "bay", danger: "risky", dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
    { word: "baj", danger: "risky", dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
    { word: "bak", danger: "risky", dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
    { word: "bakar", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "bakso", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "baku", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "bala", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balai", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balas", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balap", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balet", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balik", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balok", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balon", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balsam", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "balur", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "bambu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "ban", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "banal", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "bancuh", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "banda", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "bandel", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "banding", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "bandit", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  ],
  KA: [
    { word: "kax", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "kaz", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "kabel", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kabar", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kabur", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "kaca", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kacang", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kadal", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kado", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kain", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kajar", danger: "risky", dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
    { word: "kakak", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kalah", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kalung", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kamar", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kambing", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kampung", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kamus", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kanan", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "kandang", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  ],
  MA: [
    { word: "max", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "maf", danger: "danger", dangerLabel: "⚠️ BAHAYA", dangerColor: "#FF961E" },
    { word: "maaf", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "mabuk", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "macam", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "macet", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "madu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "mahal", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "mahir", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "main", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "makan", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "makin", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "malam", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "malas", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "malu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "mampu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "mandi", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "manis", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "mantap", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "marga", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  ],
  SA: [
    { word: "sax", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "saf", danger: "danger", dangerLabel: "⚠️ BAHAYA", dangerColor: "#FF961E" },
    { word: "sabun", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sadar", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sagu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "saham", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sahur", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "sains", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "saja", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sakit", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "saku", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "salah", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "salam", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "salib", danger: "risky", dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
    { word: "salju", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "salon", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sama", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sambil", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sampah", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "sandal", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  ],
  TA: [
    { word: "tax", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "taz", danger: "killer", dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
    { word: "tabir", danger: "normal", dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
    { word: "tabung", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tadi", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tagar", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tahan", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tahu", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tahun", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tajam", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "takut", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tali", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "taman", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tambah", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tampan", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tanah", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tanda", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tangan", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tangga", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
    { word: "tanpa", danger: "safe", dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  ],
};

// Danger level priority for sorting
const DANGER_PRIORITY: Record<string, number> = {
  impossible: 0,
  killer: 1,
  danger: 2,
  risky: 3,
  normal: 4,
  safe: 5,
};

// Difficulty score based on last character
const DIFFICULTY_SCORE: Record<string, number> = {
  x: 10, z: 10, q: 10, v: 9, f: 8, w: 7, j: 6, y: 5,
  k: 4, b: 3, p: 3, g: 3, d: 3, c: 2, m: 2, l: 2,
  r: 1, n: 1, s: 1, t: 1, h: 1, i: 0, a: 0, e: 0,
  o: 0, u: 0,
};

export default function KBBIGui() {
  const [theme, setTheme] = useState<Theme>(themes["Biru"]);
  const [isMinimized, setIsMinimized] = useState(false);
  const [isClosed, setIsClosed] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [sortMode, setSortMode] = useState<"strategy" | "difficulty">("strategy");
  const [currentLetter, setCurrentLetter] = useState("BA");
  const { notifications, sendNotification, dismissNotification } = useNotifications();

  // Get words for current letter prefix and sort them
  const currentWords = useMemo(() => {
    const words = ALL_DEMO_WORDS[currentLetter] || [];
    const sorted = [...words];

    if (sortMode === "strategy") {
      // Strategy mode: killer/danger first (ascending priority number = higher danger)
      sorted.sort((a, b) => DANGER_PRIORITY[a.danger] - DANGER_PRIORITY[b.danger]);
    } else {
      // Difficulty mode: sort by last character difficulty score (descending)
      sorted.sort((a, b) => {
        const scoreA = DIFFICULTY_SCORE[a.word.slice(-1).toLowerCase()] ?? 0;
        const scoreB = DIFFICULTY_SCORE[b.word.slice(-1).toLowerCase()] ?? 0;
        return scoreB - scoreA;
      });
    }

    return sorted;
  }, [currentLetter, sortMode]);

  // Send initial notification after loading
  useEffect(() => {
    if (isLoading) return;
    const timer = setTimeout(() => {
      sendNotification(
        "loaded",
        "Script Berhasil Dimuat!",
        "KBBI v3 SmartAuto+DupFilter. 48,291 kata. Duplikat otomatis terfilter!",
        4
      );
    }, 300);
    return () => clearTimeout(timer);
  }, [isLoading, sendNotification]);

  const handleLoadingComplete = useCallback(() => {
    setIsLoading(false);
  }, []);

  const handleThemeChange = useCallback(
    (name: string) => {
      setTheme(themes[name]);
      sendNotification("info", "Tema Diubah", `Tema: ${name}`, 2.5);
    },
    [sendNotification]
  );

  const handleMinimize = useCallback(() => {
    setIsMinimized((prev) => {
      const next = !prev;
      sendNotification(
        "info",
        next ? "Diminimalkan" : "Dipulihkan",
        next ? "Klik — untuk memulihkan." : "GUI telah dipulihkan.",
        2
      );
      return next;
    });
  }, [sendNotification]);

  const handleClose = useCallback(() => {
    sendNotification("info", "Menutup GUI", "KBBI sedang ditutup...", 2);
    setTimeout(() => setIsClosed(true), 300);
  }, [sendNotification]);

  const handleSort = useCallback(() => {
    setSortMode((prev) => {
      const next = prev === "strategy" ? "difficulty" : "strategy";
      if (next === "strategy") {
        sendNotification(
          "strategy",
          "Mode: Strategy+ 🧠",
          "Kata akhiran x/z/q/v/f di PALING ATAS!",
          3
        );
      } else {
        sendNotification(
          "info",
          "Mode: Difficulty",
          "Urutan berdasarkan tingkat kesulitan huruf akhir.",
          2.5
        );
      }
      return next;
    });
  }, [sendNotification]);

  const handleUnload = useCallback(() => {
    sendNotification("unloaded", "Script Di-unload", "KBBI telah di-unload.", 3);
    setTimeout(() => setIsClosed(true), 1000);
  }, [sendNotification]);

  const handleWordClick = useCallback(
    (word: string) => {
      const lastChar = word.slice(-1).toUpperCase();
      sendNotification(
        "success",
        "Kata Dipilih",
        `"${word}" → ${lastChar}`,
        2.5
      );
    },
    [sendNotification]
  );

  const handleLetterChange = useCallback(
    (letter: string) => {
      setCurrentLetter(letter);
      const wordCount = ALL_DEMO_WORDS[letter]?.length || 0;
      sendNotification(
        "info",
        `Huruf: ${letter}`,
        `${wordCount} kata ditemukan untuk awalan "${letter}"`,
        2
      );
    },
    [sendNotification]
  );

  // Show loading screen
  if (isLoading) {
    return (
      <div className="min-h-screen" style={{ backgroundColor: "#080A14" }}>
        <LoadingScreen onComplete={handleLoadingComplete} />
      </div>
    );
  }

  if (isClosed) {
    return (
      <div className="min-h-screen flex items-center justify-center" style={{ backgroundColor: "#080A14" }}>
        <NotificationSystem notifications={notifications} onDismiss={dismissNotification} />
        <p className="text-white/30 text-sm">GUI telah ditutup.</p>
      </div>
    );
  }

  return (
    <div
      className="min-h-screen flex items-center justify-center p-4"
      style={{ backgroundColor: "#080A14" }}
    >
      <NotificationSystem notifications={notifications} onDismiss={dismissNotification} />

      {/* Shadow */}
      <div
        className="absolute rounded-[20px] blur-xl hidden sm:block"
        style={{
          width: 760,
          height: 500,
          backgroundColor: "rgba(0,0,0,0.4)",
          transform: "translate(4px, 4px)",
        }}
      />

      {/* Main Frame */}
      <div
        className="relative rounded-2xl border overflow-hidden transition-all duration-350 w-full max-w-[720px]"
        style={{
          height: isMinimized ? 48 : 460,
          background: `linear-gradient(145deg, ${theme.gradTop} 0%, ${theme.gradBot} 100%)`,
          borderColor: `${theme.stroke}D9`,
          borderWidth: 1.5,
        }}
      >
        {/* Top Bar */}
        <TopBar
          theme={theme}
          onThemeChange={handleThemeChange}
          onMinimize={handleMinimize}
          onClose={handleClose}
          onSort={handleSort}
          onUnload={handleUnload}
          sortMode={sortMode}
          isMinimized={isMinimized}
        />

        {/* Content area */}
        {!isMinimized && (
          <div className="flex gap-2 p-2.5 pt-1.5" style={{ height: "calc(100% - 50px)" }}>
            {/* Left Panel */}
            <LeftPanel
              theme={theme}
              currentLetter={currentLetter}
              wordCount={currentWords.length}
              totalWords={48291}
              usedCount={3}
              sortMode={sortMode}
            />

            {/* Right Panel - Word List */}
            <WordList
              theme={theme}
              words={currentWords}
              sortMode={sortMode}
              onWordClick={handleWordClick}
            />
          </div>
        )}
      </div>

      {/* Letter selector (demo control) */}
      {!isMinimized && (
        <div
          className="absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 px-4 py-2 rounded-xl border flex-wrap justify-center"
          style={{
            backgroundColor: "rgba(18, 20, 28, 0.95)",
            borderColor: "rgba(45, 48, 60, 0.8)",
          }}
        >
          <span className="text-[10px] font-bold" style={{ color: "#6E82A5" }}>
            DEMO — Pilih huruf:
          </span>
          {["BA", "KA", "MA", "SA", "TA"].map((letter) => (
            <button
              key={letter}
              onClick={() => handleLetterChange(letter)}
              className="px-2.5 py-1 rounded-md text-[11px] font-bold transition-colors duration-150"
              style={{
                backgroundColor:
                  currentLetter === letter ? theme.accent : "rgba(255,255,255,0.08)",
                color: currentLetter === letter ? "#FFFFFF" : "#8C91A5",
              }}
            >
              {letter}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
