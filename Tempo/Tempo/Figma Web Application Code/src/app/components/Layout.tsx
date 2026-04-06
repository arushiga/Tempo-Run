import { Navigation } from './Navigation';

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative min-h-screen overflow-hidden bg-gradient-to-br from-violet-100 via-sky-50 to-amber-50">
      {/* Animated gradient orbs */}
      <div 
        className="absolute top-0 left-0 w-96 h-96 bg-gradient-to-br from-violet-300/30 to-purple-400/20 rounded-full blur-3xl animate-pulse" 
        style={{ animationDuration: '4s' }} 
      />
      <div 
        className="absolute bottom-0 right-0 w-96 h-96 bg-gradient-to-br from-sky-300/30 to-blue-400/20 rounded-full blur-3xl animate-pulse" 
        style={{ animationDuration: '5s', animationDelay: '1s' }} 
      />
      <div 
        className="absolute top-1/3 right-1/4 w-72 h-72 bg-gradient-to-br from-amber-300/20 to-orange-400/15 rounded-full blur-3xl animate-pulse" 
        style={{ animationDuration: '6s', animationDelay: '2s' }} 
      />
      
      <div className="relative flex items-center justify-center min-h-screen p-6">
        <div className="max-w-[520px] w-full">
          {/* Main Card with Glassmorphism */}
          <div className="backdrop-blur-2xl bg-white/40 rounded-[32px] shadow-2xl border border-white/60 overflow-hidden">
            {children}
            <Navigation />
          </div>
        </div>
      </div>
    </div>
  );
}
