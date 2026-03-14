import { useState } from "react";
import { Theme } from "@/lib/themes";

interface LeftPanelProps {
  theme: Theme;
  currentLetter: string;
  wordCount: number;
  totalWords: number;
  usedCount: number;
  sortMode: string;
}

export default function LeftPanel({
  theme,
  currentLetter,
  wordCount,
  totalWords,
  usedCount,
  sortMode,
}: LeftPanelProps) {
  const [autoEnabled, setAutoEnabled] = useState(false);

  const tips = [
    "Klik kata → auto input",
    "🤖 Auto = ambil dari opsi atas",
    "🚫 Kata terpakai hilang dari opsi",
    "🔄 Reset saat match baru",
    "💀 = akhiran x/z/q (KILLER)",
    "◆ Ganti tema, ⏏ Unload",
  ];

  return (
    <div
      className="w-[220px] flex-shrink-0 rounded-xl p-2 flex flex-col gap-2 border"
      style={{
        background: `linear-gradient(160deg, #141622 0%, #0E1018 100%)`,
        borderColor: "rgba(35, 38, 48, 0.8)",
      }}
    >
      {/* Prefix Section */}
      <div
        className="rounded-[10px] p-2.5 border"
        style={{
          background: "linear-gradient(to bottom, #161928 0%, #10121E 100%)",
          borderColor: "rgba(35, 40, 55, 0.6)",
        }}
      >
        <p className="text-[9px] font-bold mb-1" style={{ color: theme.textMuted }}>
          🔤 AWALAN HURUF
        </p>
        <div className="flex items-start justify-between">
          <span
            className="text-[38px] font-black leading-none"
            style={{ color: theme.accent }}
          >
            {currentLetter || "—"}
          </span>
          <div className="flex flex-col items-end gap-1">
            {wordCount <= 3 && wordCount > 0 && (
              <span
                className="text-[9px] font-bold px-2 py-0.5 rounded-md"
                style={{
                  backgroundColor: "rgba(200, 30, 30, 0.25)",
                  color: "#FF6464",
                }}
              >
                ⚠️ KRITIS! {wordCount}
              </span>
            )}
            {wordCount === 0 && currentLetter && (
              <span
                className="text-[9px] font-bold px-2 py-0.5 rounded-md"
                style={{
                  backgroundColor: "rgba(200, 30, 30, 0.25)",
                  color: "#FF5050",
                }}
              >
                💀 MATI!
              </span>
            )}
            <span
              className="text-[8px] font-bold px-2 py-0.5 rounded"
              style={{
                backgroundColor:
                  sortMode === "strategy"
                    ? "rgba(180, 120, 255, 0.2)"
                    : "rgba(80, 130, 220, 0.2)",
                color:
                  sortMode === "strategy" ? "#C8A0FF" : "#A0C8FF",
              }}
            >
              {sortMode === "strategy" ? "🧠 STRATEGY+" : "📊 DIFFICULTY"}
            </span>
          </div>
        </div>
      </div>

      {/* Status Section */}
      <div
        className="rounded-lg px-2.5 py-2 border"
        style={{
          backgroundColor: "#10121C",
          borderColor: "rgba(30, 35, 48, 0.5)",
        }}
      >
        <p className="text-[11px] font-medium" style={{ color: theme.accentLight }}>
          ✅ {totalWords.toLocaleString()} kata dimuat
        </p>
        <p
          className="text-[11px] mt-0.5"
          style={{ color: theme.textSecondary, opacity: 0.9 }}
        >
          Kata ditemukan: {wordCount} (🚫{usedCount} terpakai)
        </p>
      </div>

      {/* Auto Answer Section */}
      <div
        className="rounded-[10px] px-2.5 py-2 border relative overflow-hidden"
        style={{
          background: "linear-gradient(to bottom, #0E1C19 0%, #0A1210 100%)",
          borderColor: autoEnabled
            ? "rgba(0, 150, 130, 0.5)"
            : "rgba(0, 80, 70, 0.5)",
        }}
      >
        {/* Glow effect when enabled */}
        {autoEnabled && (
          <div
            className="absolute -inset-0.5 rounded-[12px] animate-pulse"
            style={{
              backgroundColor: "rgba(0, 200, 180, 0.1)",
              animationDuration: "2s",
            }}
          />
        )}

        <p className="text-[9px] font-bold mb-1.5 relative z-10" style={{ color: "#00B4A0" }}>
          🤖 AUTO ANSWER
        </p>

        <button
          onClick={() => setAutoEnabled(!autoEnabled)}
          className="w-full flex items-center gap-2 rounded-lg px-1.5 py-1.5 transition-colors duration-200 relative z-10"
          style={{
            backgroundColor: autoEnabled
              ? "rgba(0, 40, 35, 0.5)"
              : "rgba(30, 30, 40, 1)",
          }}
        >
          {/* Toggle track */}
          <div
            className="w-[38px] h-[18px] rounded-full relative flex-shrink-0 transition-colors duration-250"
            style={{
              backgroundColor: autoEnabled ? "#00B496" : "#32323C",
            }}
          >
            <div
              className="absolute top-[2px] w-[14px] h-[14px] rounded-full transition-all duration-250"
              style={{
                left: autoEnabled ? 22 : 2,
                backgroundColor: autoEnabled ? "#FFFFFF" : "#969696",
              }}
            />
          </div>
          <span
            className="text-[10px] font-bold"
            style={{
              color: autoEnabled ? "#00DCC0" : "#8C8C9B",
            }}
          >
            {autoEnabled ? "ON — Auto jawab aktif!" : "OFF — Klik untuk aktifkan"}
          </span>
        </button>

        <p className="text-[8px] mt-1 relative z-10" style={{ color: autoEnabled ? "#00B4A0" : "#64646E" }}>
          {autoEnabled ? "⏳ Menunggu giliran..." : ""}
        </p>
      </div>

      {/* Divider */}
      <div className="h-px mx-1" style={{ backgroundColor: "#282A34" }} />

      {/* Tips */}
      <div className="flex-1 overflow-hidden">
        <p className="text-[10px] font-bold mb-1 px-1" style={{ color: theme.textMuted }}>
          💡 PANDUAN
        </p>
        {tips.map((tip, i) => (
          <p
            key={i}
            className="text-[9px] px-1.5 leading-[15px]"
            style={{ color: theme.textMuted }}
          >
            › {tip}
          </p>
        ))}
      </div>

      {/* Version badge */}
      <div
        className="rounded-[7px] py-1.5 text-center border"
        style={{
          backgroundColor: "#12141C",
          borderColor: "rgba(30, 35, 48, 1)",
        }}
      >
        <p className="text-[10px] font-medium" style={{ color: theme.textMuted }}>
          ⚡ v3 SmartAuto+DupFilter • KBBI
        </p>
      </div>
    </div>
  );
}