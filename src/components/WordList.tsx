import { Theme } from "@/lib/themes";

interface WordItem {
  word: string;
  danger: "impossible" | "killer" | "danger" | "risky" | "normal" | "safe";
  dangerLabel: string;
  dangerColor: string;
}

interface WordListProps {
  theme: Theme;
  words: WordItem[];
  sortMode: string;
  onWordClick: (word: string) => void;
}

export default function WordList({ theme, words, sortMode, onWordClick }: WordListProps) {
  return (
    <div className="flex-1 flex flex-col min-w-0">
      {/* Header */}
      <div
        className="rounded-lg px-3 py-1.5 mb-1 border"
        style={{
          backgroundColor: "rgba(18, 20, 28, 0.8)",
          borderColor: "rgba(30, 35, 48, 1)",
        }}
      >
        <p className="text-[10px] font-black" style={{ color: theme.textMuted }}>
          📋 DAFTAR KATA • 💀=killer ⚠️=bahaya 🟢=aman 🚫=filtered
        </p>
      </div>

      {/* Scrollable word list */}
      <div
        className="flex-1 overflow-y-auto pr-1 space-y-1"
        style={{
          scrollbarWidth: "thin",
          scrollbarColor: `${theme.scrollBar} transparent`,
        }}
      >
        {words.length === 0 ? (
          <div className="flex items-center justify-center h-full">
            <p className="text-sm" style={{ color: theme.textMuted }}>
              Menunggu huruf awalan...
            </p>
          </div>
        ) : (
          words.map((item, i) => (
            <button
              key={`${item.word}-${i}`}
              onClick={() => onWordClick(item.word)}
              className="w-full flex items-center rounded-[7px] px-3 py-1.5 border transition-all duration-120 group text-left"
              style={{
                backgroundColor: i % 2 === 0 ? theme.cardBg : theme.cardBgAlt,
                borderColor: `${theme.stroke}80`,
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.backgroundColor = theme.cardHover;
                const stroke = e.currentTarget;
                stroke.style.borderColor = `${theme.accentLight}D9`;
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.backgroundColor =
                  i % 2 === 0 ? theme.cardBg : theme.cardBgAlt;
                e.currentTarget.style.borderColor = `${theme.stroke}80`;
              }}
            >
              {/* Word text */}
              <span
                className="text-[13px] font-bold flex-1 truncate"
                style={{ color: theme.textPrimary }}
              >
                {item.word}
              </span>

              {/* Danger indicator */}
              {sortMode === "strategy" ? (
                <span
                  className="text-[8px] font-bold px-2 py-0.5 rounded flex-shrink-0 mr-2"
                  style={{
                    backgroundColor: `${item.dangerColor}30`,
                    color: item.dangerColor,
                  }}
                >
                  {item.dangerLabel}
                </span>
              ) : (
                item.danger === "killer" || item.danger === "impossible" ? (
                  <span
                    className="text-[8px] font-bold px-2 py-0.5 rounded flex-shrink-0 mr-2"
                    style={{
                      backgroundColor: "rgba(255, 60, 60, 0.2)",
                      color: "#FF3C3C",
                    }}
                  >
                    💀 HARD
                  </span>
                ) : item.danger === "danger" || item.danger === "risky" ? (
                  <span
                    className="text-[8px] font-bold px-2 py-0.5 rounded flex-shrink-0 mr-2"
                    style={{
                      backgroundColor: "rgba(240, 180, 40, 0.2)",
                      color: "#F0B428",
                    }}
                  >
                    ⚠️ MED
                  </span>
                ) : null
              )}

              {/* Index badge */}
              <span
                className="text-[9px] font-bold w-[22px] h-[18px] rounded flex items-center justify-center flex-shrink-0"
                style={{
                  backgroundColor: `${theme.accent}B3`,
                  color: `${theme.textPrimary}CC`,
                }}
              >
                {i + 1}
              </span>
            </button>
          ))
        )}
      </div>
    </div>
  );
}
