import { useState, useEffect } from "react";

interface LoadingScreenProps {
  onComplete: () => void;
}

export default function LoadingScreen({ onComplete }: LoadingScreenProps) {
  const [progress, setProgress] = useState(0);
  const [status, setStatus] = useState("Memuat kamus...");
  const [fadeOut, setFadeOut] = useState(false);

  useEffect(() => {
    const steps = [
      { p: 30, s: "Menghubungkan ke server...", d: 200 },
      { p: 60, s: "Memproses kamus KBBI...", d: 200 },
      { p: 85, s: "Mengindeks 48,291 kata...", d: 200 },
      { p: 100, s: "Selesai!", d: 200 },
    ];

    let timeout: ReturnType<typeof setTimeout>;
    let currentStep = 0;

    const runStep = () => {
      if (currentStep >= steps.length) {
        setTimeout(() => {
          setFadeOut(true);
          setTimeout(onComplete, 300);
        }, 150);
        return;
      }
      const step = steps[currentStep];
      setProgress(step.p);
      setStatus(step.s);
      currentStep++;
      timeout = setTimeout(runStep, step.d);
    };

    timeout = setTimeout(runStep, 100);
    return () => clearTimeout(timeout);
  }, [onComplete]);

  // Floating particles
  const particles = Array.from({ length: 15 }, (_, i) => ({
    id: i,
    x: Math.random() * 90 + 5,
    y: Math.random() * 90 + 5,
    size: Math.random() * 4 + 2,
    opacity: Math.random() * 0.3 + 0.1,
    duration: Math.random() * 4 + 3,
  }));

  return (
    <div
      className={`fixed inset-0 z-50 flex items-center justify-center transition-opacity duration-300 ${fadeOut ? "opacity-0 pointer-events-none" : "opacity-100"}`}
      style={{
        background: "linear-gradient(150deg, #0C0F1E 0%, #080A14 50%, #060810 100%)",
      }}
    >
      {/* Floating particles */}
      {particles.map((p) => (
        <div
          key={p.id}
          className="absolute rounded-full animate-pulse"
          style={{
            left: `${p.x}%`,
            top: `${p.y}%`,
            width: p.size,
            height: p.size,
            backgroundColor: "#3782F0",
            opacity: p.opacity,
            animationDuration: `${p.duration}s`,
          }}
        />
      ))}

      <div className="flex flex-col items-center gap-4">
        {/* Globe */}
        <div className="relative w-[90px] h-[90px]">
          <div
            className="absolute -inset-2 rounded-full animate-pulse"
            style={{ backgroundColor: "#3782F0", opacity: 0.15 }}
          />
          <div
            className="w-full h-full rounded-full overflow-hidden border-2 relative"
            style={{
              background: "linear-gradient(135deg, #1E5AB4 0%, #143C8C 40%, #0A1E50 100%)",
              borderColor: "rgba(55, 130, 240, 0.7)",
            }}
          >
            {[
              { x: 15, y: 20, w: 22, h: 28 },
              { x: 45, y: 15, w: 16, h: 20 },
              { x: 55, y: 25, w: 24, h: 30 },
              { x: 70, y: 18, w: 28, h: 22 },
              { x: 75, y: 60, w: 18, h: 14 },
              { x: 20, y: 55, w: 14, h: 18 },
            ].map((c, i) => (
              <div
                key={i}
                className="absolute rounded"
                style={{
                  left: `${c.x}%`,
                  top: `${c.y}%`,
                  width: c.w,
                  height: c.h,
                  backgroundColor: `rgb(${38 + i * 2}, ${155 + i * 5}, ${75 + i * 3})`,
                }}
              />
            ))}
          </div>
        </div>

        {/* Book */}
        <div className="relative w-[160px] h-[120px]">
          <div
            className="absolute bottom-1 left-1/2 -translate-x-1/2 w-[150px] h-2 rounded-full"
            style={{ backgroundColor: "rgba(0,0,0,0.5)" }}
          />
          <div
            className="absolute rounded left-[6px] top-[12px] w-[70px] h-[96px] overflow-hidden"
            style={{ background: "linear-gradient(to right, #C8B99B, #A59478)" }}
          >
            {[1, 2, 3, 4, 5].map((l) => (
              <div
                key={l}
                className="absolute rounded-sm"
                style={{
                  left: 8,
                  top: 14 + (l - 1) * 14,
                  width: 30 + Math.random() * 25,
                  height: 2,
                  backgroundColor: "rgba(120, 105, 85, 0.5)",
                }}
              />
            ))}
          </div>
          <div
            className="absolute left-1/2 -translate-x-1/2 top-[10px] w-2 h-[100px] rounded-sm z-10"
            style={{ backgroundColor: "#2D2319" }}
          />
          <div
            className="absolute rounded right-[6px] top-[12px] w-[70px] h-[96px] overflow-hidden"
            style={{ background: "linear-gradient(to right, #AF9E80, #D2C3A8)" }}
          >
            {[1, 2, 3, 4, 5].map((l) => (
              <div
                key={l}
                className="absolute rounded-sm"
                style={{
                  left: 8,
                  top: 14 + (l - 1) * 14,
                  width: 30 + Math.random() * 25,
                  height: 2,
                  backgroundColor: "rgba(120, 105, 85, 0.5)",
                }}
              />
            ))}
          </div>
        </div>

        {/* Title */}
        <div className="text-center">
          <h1 className="text-4xl font-black text-white tracking-wider">KBBI</h1>
          <p className="text-sm font-medium mt-1" style={{ color: "#3782F0" }}>
            by.Sobing4413
          </p>
        </div>

        {/* Progress bar */}
        <div className="w-60">
          <div className="h-1 rounded-full overflow-hidden" style={{ backgroundColor: "#1E2337" }}>
            <div
              className="h-full rounded-full transition-all duration-300 ease-out"
              style={{
                width: `${progress}%`,
                background: "linear-gradient(90deg, #3782F0, #64B4FF, #3782F0)",
              }}
            />
          </div>
          <p className="text-[11px] text-center mt-2" style={{ color: "#788CB4" }}>
            {status}
          </p>
        </div>
      </div>
    </div>
  );
}
