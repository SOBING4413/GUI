import { useState, useEffect, useRef } from "react";
import { Theme, themes, themeOrder } from "@/lib/themes";

interface TopBarProps {
  theme: Theme;
  onThemeChange: (name: string) => void;
  onMinimize: () => void;
  onClose: () => void;
  onSort: () => void;
  onUnload: () => void;
  sortMode: string;
  isMinimized: boolean;
}

export default function TopBar({
  theme,
  onThemeChange,
  onMinimize,
  onClose,
  onSort,
  onUnload,
  sortMode,
  isMinimized,
}: TopBarProps) {
  const [showThemePanel, setShowThemePanel] = useState(false);
  const [currentThemeName, setCurrentThemeName] = useState("Biru");
  const themePanelRef = useRef<HTMLDivElement>(null);
  const themeButtonRef = useRef<HTMLButtonElement>(null);

  const handleThemeSelect = (name: string) => {
    setCurrentThemeName(name);
    onThemeChange(name);
    setShowThemePanel(false);
  };

  // Close theme panel when clicking outside
  useEffect(() => {
    if (!showThemePanel) return;

    const handleClickOutside = (e: MouseEvent) => {
      if (
        themePanelRef.current &&
        !themePanelRef.current.contains(e.target as Node) &&
        themeButtonRef.current &&
        !themeButtonRef.current.contains(e.target as Node)
      ) {
        setShowThemePanel(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [showThemePanel]);

  return (
    <div className="relative">
      {/* Top Bar */}
      <div
        className="relative h-12 flex items-center px-3 rounded-t-2xl z-10"
        style={{ backgroundColor: "rgba(0,0,0,0.5)" }}
      >
        {/* Accent line */}
        <div
          className="absolute bottom-0 left-0 right-0 h-[2px] animate-pulse"
          style={{
            backgroundColor: theme.accent,
            animationDuration: "4s",
          }}
        />

        {/* Title icon */}
        <div className="relative">
          <div
            className="absolute -inset-[3px] rounded-[10px] animate-pulse"
            style={{
              backgroundColor: theme.accent,
              opacity: 0.2,
              animationDuration: "3s",
            }}
          />
          <div
            className="w-8 h-8 rounded-lg flex items-center justify-center text-white font-black text-[17px] border"
            style={{
              backgroundColor: theme.accent,
              borderColor: `${theme.accentLight}80`,
            }}
          >
            K
          </div>
        </div>

        {/* Title text */}
        <div className="ml-3">
          <h1
            className="text-[17px] font-black leading-tight"
            style={{ color: theme.textPrimary }}
          >
            KBBI SAMBUNG KATA
          </h1>
          <p
            className="text-[10px] font-medium leading-tight"
            style={{ color: theme.textMuted }}
          >
            by.Sobing4413 • v3 SmartAuto + DupFilter
          </p>
        </div>

        {/* Control buttons */}
        <div className="ml-auto flex items-center gap-2">
          {/* Unload */}
          <button
            onClick={onUnload}
            className="w-[30px] h-[30px] rounded-lg text-[13px] flex items-center justify-center transition-all duration-200 hover:text-white"
            style={{
              backgroundColor: "rgba(255,255,255,0.08)",
              color: "#B4B4BE",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(180,100,50,0.85)";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.08)";
            }}
            title="Unload"
          >
            ⏏
          </button>

          {/* Sort */}
          <button
            onClick={onSort}
            className="w-[30px] h-[30px] rounded-lg text-[12px] flex items-center justify-center transition-all duration-200 hover:text-white"
            style={{
              backgroundColor: "rgba(255,255,255,0.08)",
              color: "#B4B4BE",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(180,120,255,0.85)";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.08)";
            }}
            title={sortMode === "strategy" ? "Mode: Strategy+" : "Mode: Difficulty"}
          >
            🧠
          </button>

          {/* Theme */}
          <button
            ref={themeButtonRef}
            onClick={() => setShowThemePanel(!showThemePanel)}
            className="w-[30px] h-[30px] rounded-lg text-[12px] flex items-center justify-center transition-all duration-200 hover:text-white"
            style={{
              backgroundColor: "rgba(255,255,255,0.08)",
              color: "#B4B4BE",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = theme.accent;
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.08)";
            }}
            title="Pilih Tema"
          >
            ◆
          </button>

          {/* Minimize */}
          <button
            onClick={onMinimize}
            className="w-[30px] h-[30px] rounded-lg text-[14px] flex items-center justify-center transition-all duration-200 hover:text-white"
            style={{
              backgroundColor: "rgba(255,255,255,0.08)",
              color: "#B4B4BE",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(220,180,40,0.85)";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.08)";
            }}
            title={isMinimized ? "Pulihkan" : "Minimalkan"}
          >
            —
          </button>

          {/* Close */}
          <button
            onClick={onClose}
            className="w-[30px] h-[30px] rounded-lg text-[13px] flex items-center justify-center transition-all duration-200 hover:text-white"
            style={{
              backgroundColor: "rgba(255,255,255,0.08)",
              color: "#B4B4BE",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(220,50,50,0.85)";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.08)";
            }}
            title="Tutup"
          >
            ✕
          </button>
        </div>
      </div>

      {/* Theme Panel */}
      {showThemePanel && (
        <div
          ref={themePanelRef}
          className="absolute right-4 top-14 w-[200px] rounded-xl z-50 overflow-hidden border"
          style={{
            backgroundColor: "#12141C",
            borderColor: "#2D303C",
          }}
        >
          <p className="px-3 py-2 text-[10px] font-black" style={{ color: "#969BAF" }}>
            🎨 PILIH TEMA
          </p>
          {themeOrder.map((name) => {
            const t = themes[name];
            return (
              <button
                key={name}
                onClick={() => handleThemeSelect(name)}
                className="w-full flex items-center gap-3 px-3 py-2.5 transition-colors duration-150 hover:bg-[#282A37]"
                style={{ backgroundColor: "#1C1E28" }}
              >
                <div
                  className="w-4 h-4 rounded-full border-2"
                  style={{
                    backgroundColor: t.accent,
                    borderColor: `${t.accent}99`,
                  }}
                />
                <span className="text-[13px] font-bold" style={{ color: "#C8C8D2" }}>
                  {name}
                </span>
                {name === currentThemeName && (
                  <span className="ml-auto text-sm font-bold" style={{ color: t.accent }}>
                    ✓
                  </span>
                )}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
