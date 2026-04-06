import { useDrag } from 'react-dnd';
import { RunType } from '../screens/Calendar';
import svgPaths from '../../imports/svg-sq11q5zcmr';

interface DraggableRunTypeProps {
  type: RunType;
  label: string;
  color: string;
  vibrant: string;
}

export function DraggableRunType({ type, label, color, vibrant }: DraggableRunTypeProps) {
  const [{ isDragging }, drag] = useDrag(() => ({
    type: 'run',
    item: { runType: type },
    collect: (monitor) => ({
      isDragging: !!monitor.isDragging(),
    }),
  }));

  return (
    <div
      ref={drag}
      className={`flex flex-col items-center cursor-grab active:cursor-grabbing transition-all duration-300 group ${
        isDragging ? 'opacity-30 scale-90' : 'opacity-100 hover:scale-105'
      }`}
    >
      {/* Glass pill container */}
      <div 
        className={`relative w-[60px] h-[60px] mb-3 flex items-center justify-center rounded-[20px] transition-all duration-300 ${
          isDragging 
            ? 'backdrop-blur-md bg-white/40 border-2 border-white/60 shadow-md' 
            : 'backdrop-blur-lg bg-white/70 border-2 shadow-lg group-hover:shadow-xl'
        }`}
        style={{
          borderColor: isDragging ? 'rgba(255,255,255,0.6)' : vibrant,
          boxShadow: isDragging 
            ? undefined 
            : `0 8px 24px ${vibrant}30, 0 0 0 1px ${vibrant}20`,
        }}
      >
        {/* Inner glow */}
        <div 
          className="absolute inset-0 rounded-[18px] opacity-20 group-hover:opacity-30 transition-opacity"
          style={{
            background: `radial-gradient(circle at 30% 30%, ${color}, transparent)`,
          }}
        />
        
        {/* Icon */}
        <div className="relative z-10 drop-shadow-md group-hover:scale-110 transition-transform duration-200">
          <RunIcon type={type} color={vibrant} />
        </div>
      </div>
      
      {/* Label */}
      <p className="text-[12px] text-slate-700 font-semibold text-center whitespace-nowrap">
        {label}
      </p>
    </div>
  );
}

function RunIcon({ type, color }: { type: RunType; color: string }) {
  if (type === 'easy') {
    return (
      <svg className="w-[32px] h-[32px]" viewBox="0 0 36 36" fill="none">
        <path d={svgPaths.p62d3580} fill={color} />
      </svg>
    );
  }

  if (type === 'tempo') {
    return (
      <svg className="w-[28px] h-[26px]" viewBox="0 0 30.375 28.124" fill="none">
        <path d={svgPaths.p3d035380} fill={color} />
      </svg>
    );
  }

  if (type === 'race') {
    return (
      <svg className="w-[28px] h-[26px]" viewBox="0 0 30.375 28.124" fill="none">
        <path d={svgPaths.p22eee900} fill={color} />
      </svg>
    );
  }

  if (type === 'longRun') {
    return (
      <svg className="w-[28px] h-[26px]" viewBox="0 0 30.375 28.124" fill="none">
        <path d={svgPaths.p22eee900} fill={color} />
      </svg>
    );
  }

  return null;
}