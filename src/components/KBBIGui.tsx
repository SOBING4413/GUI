import { useState, useCallback, useEffect } from "react";
import { Theme, themes } from "@/lib/themes";
import TopBar from "./TopBar";
import LeftPanel from "./LeftPanel";
import WordList from "./WordList";
import NotificationSystem, { useNotifications } from "./NotificationSystem";

// Demo word data
const DEMO_WORDS = [
  { word: "bax", danger: "killer" as const, dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
  { word: "baz", danger: "killer" as const, dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
  { word: "bav", danger: "killer" as const, dangerLabel: "💀 KILLER", dangerColor: "#FF2828" },
  { word: "baf", danger: "danger" as const, dangerLabel: "⚠️ BAHAYA", dangerColor: "#FF961E" },
  { word: "baw", danger: "danger" as const, dangerLabel: "⚠️ BAHAYA", dangerColor: "#FF961E" },
  { word: "bay", danger: "risky" as const, dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
  { word: "baj", danger: "risky" as const, dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
  { word: "bak", danger: "risky" as const, dangerLabel: "🟡 RISKY", dangerColor: "#F0DC28" },
  { word: "bakar", danger: "normal" as const, dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
  { word: "bakso", danger: "normal" as const, dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
  { word: "baku", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "bala", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balai", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balas", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balap", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balet", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balik", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balok", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balon", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balsam", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balu", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "balur", danger: "normal" as const, dangerLabel: "🔵 NORMAL", dangerColor: "#64A0F0" },
  { word: "bambu", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "ban", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "banal", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "bancuh", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "banda", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "bandel", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "banding", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
  { word: "bandit", danger: "safe" as const, dangerLabel: "🟢 AMAN", dangerColor: "#28C864" },
];

export default function KBBIGui() {
  const [theme, setTheme] = useState<Theme>(themes["Biru"]);
  const [isMinimized, setIsMinimized] = useState(false);
  const [isClosed, setIsClosed] = useState(false);
  const [sortMode, setSortMode] = useState<"strategy" | "difficulty">("strategy");
  const [currentLetter, setCurrentLetter] = useState("BA");
  const { notifications, sendNotification, dismissNotification } = useNotifications();

  // Send initial notification
  useEffect(() => {
    const timer = setTimeout(() => {
      sendNotification(
        "loaded",
        "Script Berhasil Dimuat!",
        "KBBI v3 SmartAuto+DupFilter. 48,291 kata. Duplikat otomatis terfilter!",
        4
      );
    }, 500);
    return () => clearTimeout(timer);
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
      return next as "strategy" | "difficulty";
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
      className="min-h-screen flex items-center justify-center"
      style={{ backgroundColor: "#080A14" }}
    >
      <NotificationSystem notifications={notifications} onDismiss={dismissNotification} />

      {/* Shadow */}
      <div
        className="absolute rounded-[20px] blur-xl"
        style={{
          width: 760,
          height: 500,
          backgroundColor: "rgba(0,0,0,0.4)",
          transform: "translate(4px, 4px)",
        }}
      />

      {/* Main Frame */}
      <div
        className="relative rounded-2xl border overflow-hidden transition-all duration-350"
        style={{
          width: 720,
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
              wordCount={DEMO_WORDS.length}
              totalWords={48291}
              usedCount={3}
              sortMode={sortMode}
            />

            {/* Right Panel - Word List */}
            <WordList
              theme={theme}
              words={DEMO_WORDS}
              sortMode={sortMode}
              onWordClick={handleWordClick}
            />
          </div>
        )}
      </div>

      {/* Letter selector (demo control) */}
      {!isMinimized && (
        <div
          className="absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 px-4 py-2 rounded-xl border"
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
              onClick={() => setCurrentLetter(letter)}
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