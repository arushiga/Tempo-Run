import { Link } from 'react-router';
import { Mail, Lock, User, Eye, EyeOff } from 'lucide-react';
import { useState } from 'react';

export default function SignUp() {
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

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
        <div className="max-w-md w-full">
          {/* Sign Up Card */}
          <div className="backdrop-blur-2xl bg-white/40 rounded-[32px] shadow-2xl border border-white/60 overflow-hidden">
            {/* Header */}
            <div className="relative px-8 py-10 overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-blue-900" />
              <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/10" />
              
              <div className="relative z-10 text-center">
                <div className="w-20 h-20 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center mx-auto mb-4 shadow-xl border border-white/30">
                  <span className="text-4xl">🎯</span>
                </div>
                <h1 className="font-bold text-[32px] text-white mb-2 tracking-tight">
                  Start Your Journey
                </h1>
                <p className="text-white/90 text-[15px] font-medium">
                  Create an account to track your runs
                </p>
              </div>
            </div>

            <div className="px-8 py-8 space-y-5">
              {/* Name Input */}
              <div>
                <label className="text-[13px] font-semibold text-slate-700 mb-2 block">
                  Full Name
                </label>
                <div className="relative">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                    <User className="w-5 h-5" />
                  </div>
                  <input
                    type="text"
                    placeholder="John Doe"
                    className="w-full backdrop-blur-xl bg-white/70 border-2 border-white/80 rounded-2xl px-12 py-3.5 text-[15px] text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-violet-400 transition-all shadow-sm"
                  />
                </div>
              </div>

              {/* Email Input */}
              <div>
                <label className="text-[13px] font-semibold text-slate-700 mb-2 block">
                  Email Address
                </label>
                <div className="relative">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                    <Mail className="w-5 h-5" />
                  </div>
                  <input
                    type="email"
                    placeholder="your@email.com"
                    className="w-full backdrop-blur-xl bg-white/70 border-2 border-white/80 rounded-2xl px-12 py-3.5 text-[15px] text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-violet-400 transition-all shadow-sm"
                  />
                </div>
              </div>

              {/* Password Input */}
              <div>
                <label className="text-[13px] font-semibold text-slate-700 mb-2 block">
                  Password
                </label>
                <div className="relative">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                    <Lock className="w-5 h-5" />
                  </div>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Create a password"
                    className="w-full backdrop-blur-xl bg-white/70 border-2 border-white/80 rounded-2xl px-12 py-3.5 text-[15px] text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-violet-400 transition-all shadow-sm"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
                <p className="text-[11px] text-slate-500 mt-1 ml-1">
                  Must be at least 8 characters
                </p>
              </div>

              {/* Confirm Password Input */}
              <div>
                <label className="text-[13px] font-semibold text-slate-700 mb-2 block">
                  Confirm Password
                </label>
                <div className="relative">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                    <Lock className="w-5 h-5" />
                  </div>
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    placeholder="Confirm your password"
                    className="w-full backdrop-blur-xl bg-white/70 border-2 border-white/80 rounded-2xl px-12 py-3.5 text-[15px] text-slate-800 placeholder:text-slate-400 focus:outline-none focus:border-violet-400 transition-all shadow-sm"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    {showConfirmPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              {/* Terms & Conditions */}
              <div>
                <label className="flex items-start gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    className="w-4 h-4 mt-0.5 rounded border-2 border-white/60 backdrop-blur-md bg-white/50 checked:bg-gradient-to-br checked:from-violet-500 checked:to-fuchsia-500 flex-shrink-0"
                  />
                  <span className="text-[13px] text-slate-700 leading-tight">
                    I agree to the{' '}
                    <a href="#" className="text-violet-600 hover:text-fuchsia-600 font-semibold">
                      Terms of Service
                    </a>
                    {' '}and{' '}
                    <a href="#" className="text-violet-600 hover:text-fuchsia-600 font-semibold">
                      Privacy Policy
                    </a>
                  </span>
                </label>
              </div>

              {/* Sign Up Button */}
              <Link to="/">
                <button className="w-full backdrop-blur-xl bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white rounded-2xl py-4 font-bold text-[16px] shadow-lg hover:shadow-xl hover:scale-[1.02] transition-all">
                  Create Account
                </button>
              </Link>

              {/* Divider */}
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-white/40"></div>
                </div>
                <div className="relative flex justify-center text-[13px]">
                  <span className="px-4 backdrop-blur-md bg-white/60 text-slate-600 font-medium rounded-full">
                    or sign up with
                  </span>
                </div>
              </div>

              {/* Social Sign Up */}
              <div className="grid grid-cols-2 gap-3">
                <button className="backdrop-blur-xl bg-white/70 border-2 border-white/80 rounded-2xl py-3 flex items-center justify-center gap-2 hover:bg-white/90 transition-all shadow-sm">
                  <svg className="w-5 h-5" viewBox="0 0 24 24">
                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                  </svg>
                  <span className="text-[14px] font-semibold text-slate-700">Google</span>
                </button>
                <button className="backdrop-blur-xl bg-white/70 border-2 border-white/80 rounded-2xl py-3 flex items-center justify-center gap-2 hover:bg-white/90 transition-all shadow-sm">
                  <svg className="w-5 h-5" viewBox="0 0 24 24" fill="#000000">
                    <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
                  </svg>
                  <span className="text-[14px] font-semibold text-slate-700">Apple</span>
                </button>
              </div>

              {/* Sign In Link */}
              <div className="text-center pt-2">
                <p className="text-[14px] text-slate-600">
                  Already have an account?{' '}
                  <Link to="/login" className="text-violet-600 hover:text-fuchsia-600 font-bold transition-colors">
                    Sign In
                  </Link>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}