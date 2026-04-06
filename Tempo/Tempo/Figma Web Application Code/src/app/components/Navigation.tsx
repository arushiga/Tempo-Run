import { Link, useLocation } from 'react-router';

export function Navigation() {
  const location = useLocation();
  
  const isActive = (path: string) => location.pathname === path;

  return (
    <div className="flex justify-around py-4 px-6 border-t border-white/40 backdrop-blur-xl bg-white/30">
      <NavButton to="/" icon={<HomeIcon />} active={isActive('/')} />
      <NavButton to="/calendar" icon={<CalendarIcon />} active={isActive('/calendar')} />
      <NavButton to="/record" icon={<RecordIcon />} active={isActive('/record')} />
      <NavButton to="/activity" icon={<ActivityIcon />} active={isActive('/activity')} />
      <NavButton to="/profile" icon={<UserIcon />} active={isActive('/profile')} />
    </div>
  );
}

function NavButton({ to, icon, active = false }: { to: string; icon: React.ReactNode; active?: boolean }) {
  return (
    <Link
      to={to}
      className={`p-3 rounded-2xl transition-all duration-300 ${
        active
          ? 'bg-gradient-to-br from-slate-700 to-blue-900 text-white shadow-xl shadow-blue-900/30 scale-110'
          : 'text-slate-400 hover:bg-white/60 hover:text-slate-700 hover:scale-105 backdrop-blur-sm'
      }`}
    >
      {icon}
    </Link>
  );
}

// Navigation Icons
function HomeIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
      <polyline points="9 22 9 12 15 12 15 22" />
    </svg>
  );
}

function CalendarIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
      <line x1="16" y1="2" x2="16" y2="6" />
      <line x1="8" y1="2" x2="8" y2="6" />
      <line x1="3" y1="10" x2="21" y2="10" />
    </svg>
  );
}

function RecordIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10" />
      <circle cx="12" cy="12" r="3" fill="currentColor" />
    </svg>
  );
}

function ActivityIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
    </svg>
  );
}

function UserIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  );
}
