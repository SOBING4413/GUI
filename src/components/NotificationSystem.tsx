import { useState, useEffect, useCallback } from "react";

export interface Notification {
  id: number;
  type: string;
  title: string;
  message: string;
  duration: number;
  createdAt: number;
}

const NotifIcons: Record<string, string> = {
  success: "✅",
  error: "❌",
  info: "ℹ️",
  warning: "⚠️",
  correct: "🎉",
  wrong: "💢",
  loaded: "📦",
  unloaded: "🔌",
  danger: "💀",
  strategy: "🧠",
  auto: "🤖",
  filter: "🚫",
};

const NotifColors: Record<string, string> = {
  success: "#28C864",
  error: "#E63741",
  info: "#37AAF0",
  warning: "#F0B428",
  correct: "#28DC6E",
  wrong: "#F03C46",
  loaded: "#37AAF0",
  unloaded: "#B46432",
  danger: "#C81E1E",
  strategy: "#B478FF",
  auto: "#00C8B4",
  filter: "#FF7800",
};

interface NotificationSystemProps {
  notifications: Notification[];
  onDismiss: (id: number) => void;
}

export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  let counter = 0;

  const sendNotification = useCallback(
    (type: string, title: string, message: string, duration = 3.5) => {
      counter++;
      const id = Date.now() + counter;
      const notif: Notification = {
        id,
        type,
        title,
        message,
        duration,
        createdAt: Date.now(),
      };
      setNotifications((prev) => [...prev, notif]);

      setTimeout(() => {
        setNotifications((prev) => prev.filter((n) => n.id !== id));
      }, duration * 1000);

      return id;
    },
    []
  );

  const dismissNotification = useCallback((id: number) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
  }, []);

  return { notifications, sendNotification, dismissNotification };
}

export default function NotificationSystem({
  notifications,
  onDismiss,
}: NotificationSystemProps) {
  return (
    <div className="fixed top-3 right-3 z-[200] flex flex-col gap-2 w-[310px]">
      {notifications.map((notif) => (
        <NotificationCard key={notif.id} notif={notif} onDismiss={onDismiss} />
      ))}
    </div>
  );
}

function NotificationCard({
  notif,
  onDismiss,
}: {
  notif: Notification;
  onDismiss: (id: number) => void;
}) {
  const [progress, setProgress] = useState(100);
  const color = NotifColors[notif.type] || "#37AAF0";
  const icon = NotifIcons[notif.type] || "🔔";

  useEffect(() => {
    const start = Date.now();
    const dur = notif.duration * 1000;
    const interval = setInterval(() => {
      const elapsed = Date.now() - start;
      const remaining = Math.max(0, 100 - (elapsed / dur) * 100);
      setProgress(remaining);
      if (remaining <= 0) clearInterval(interval);
    }, 50);
    return () => clearInterval(interval);
  }, [notif.duration]);

  return (
    <div
      className="relative rounded-xl overflow-hidden border animate-in slide-in-from-right duration-350"
      style={{
        background: "linear-gradient(135deg, #161826 0%, #0C0E16 100%)",
        borderColor: `${color}66`,
      }}
    >
      {/* Accent bar */}
      <div
        className="absolute left-1.5 top-1.5 bottom-1.5 w-1 rounded-full"
        style={{ backgroundColor: color }}
      />

      {/* Accent glow */}
      <div
        className="absolute left-0 top-0 bottom-0 w-10"
        style={{
          background: `linear-gradient(to right, ${color}1F, transparent)`,
        }}
      />

      {/* Content */}
      <div className="relative flex items-start gap-3 px-4 py-3 pl-5">
        {/* Icon */}
        <div
          className="w-8 h-8 rounded-lg flex items-center justify-center text-sm flex-shrink-0"
          style={{ backgroundColor: `${color}22` }}
        >
          {icon}
        </div>

        <div className="flex-1 min-w-0">
          <p className="text-[13px] font-black text-white truncate">{notif.title}</p>
          <p className="text-[11px] mt-0.5 leading-tight" style={{ color: "#B4B9C8" }}>
            {notif.message}
          </p>
        </div>

        {/* Close button */}
        <button
          onClick={() => onDismiss(notif.id)}
          className="w-6 h-6 rounded-md flex items-center justify-center text-[10px] flex-shrink-0 transition-colors hover:bg-white/10"
          style={{
            backgroundColor: "rgba(255,255,255,0.08)",
            color: "#8C8C9B",
          }}
        >
          ✕
        </button>
      </div>

      {/* Progress bar */}
      <div className="px-2 pb-2">
        <div
          className="h-[3px] rounded-full overflow-hidden"
          style={{ backgroundColor: "#1E2030" }}
        >
          <div
            className="h-full rounded-full transition-all duration-100 ease-linear"
            style={{
              width: `${progress}%`,
              backgroundColor: color,
            }}
          />
        </div>
      </div>
    </div>
  );
}