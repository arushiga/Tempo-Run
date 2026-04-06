import { useDrop, useDrag } from 'react-dnd';
import { RunType, ScheduledRun } from '../screens/Calendar';
import svgPaths from '../../imports/svg-sq11q5zcmr';

interface CalendarCellProps {
  day: number;
  time: 'AM' | 'PM';
  scheduledRun?: ScheduledRun;
  onDrop: (runType: RunType, day: number, time: 'AM' | 'PM') => void;
  onRemove: (id: string) => void;
  onMove: (id: string, day: number, time: 'AM' | 'PM') => void;
}

const runColors: Record<RunType, { soft: string; vibrant: string }> = {
  easy: { soft: '#7DD3FC', vibrant: '#0EA5E9' },
  tempo: { soft: '#FDBA74', vibrant: '#F97316' },
  race: { soft: '#C084FC', vibrant: '#A855F7' },
  longRun: { soft: '#6EE7B7', vibrant: '#10B981' },
};

export function CalendarCell({ day, time, scheduledRun, onDrop, onRemove, onMove }: CalendarCellProps) {
  const [{ isOver, canDrop }, drop] = useDrop(() => ({
    accept: 'run',
    drop: (item: { runType?: RunType; runId?: string }) => {
      console.log('Drop received in CalendarCell:', { item, day, time, currentRun: scheduledRun?.id });
      
      if (item.runType) {
        // New run being dropped
        onDrop(item.runType, day, time);
      } else if (item.runId) {
        // Existing run being moved
        onMove(item.runId, day, time);
      }
    },
    collect: (monitor) => ({
      isOver: !!monitor.isOver(),
      canDrop: !!monitor.canDrop(),
    }),
  }));

  const [{ isDragging }, drag] = useDrag(() => ({
    type: 'run',
    item: scheduledRun ? { runId: scheduledRun.id } : {},
    canDrag: !!scheduledRun,
    collect: (monitor) => ({
      isDragging: !!monitor.isDragging(),
    }),
  }));

  const combinedRef = (node: HTMLDivElement | null) => {
    drop(node);
    drag(node);
  };

  const handleDoubleClick = () => {
    if (scheduledRun) {
      onRemove(scheduledRun.id);
    }
  };

  const cellColors = scheduledRun ? runColors[scheduledRun.type] : null;

  return (
    <div
      ref={combinedRef}
      onDoubleClick={handleDoubleClick}
      className={`w-[44px] h-[44px] rounded-2xl transition-all duration-300 flex items-center justify-center relative group ${
        isDragging ? 'opacity-30 scale-90' : 'opacity-100'
      }`}
      title={scheduledRun ? 'Drag to move, double-click to remove' : 'Drop a run here'}
    >
      {/* Cell background with glassmorphism */}
      <div className={`absolute inset-0 rounded-2xl transition-all duration-300 ${
        scheduledRun && !isDragging
          ? 'backdrop-blur-md bg-white/60 border-2 shadow-lg group-hover:shadow-xl group-hover:scale-110'
          : isOver && canDrop
          ? 'backdrop-blur-md bg-blue-400/20 border-2 border-blue-400 scale-110 shadow-lg animate-pulse'
          : 'backdrop-blur-sm bg-white/30 border-2 border-white/40 group-hover:bg-white/50 group-hover:border-white/60'
      }`}
        style={{
          borderColor: scheduledRun && !isDragging ? cellColors?.vibrant : undefined,
          boxShadow: scheduledRun && !isDragging 
            ? `0 4px 16px ${cellColors?.vibrant}40, 0 0 0 1px ${cellColors?.vibrant}20` 
            : undefined,
        }}
      />

      {/* Icon */}
      {scheduledRun && !isDragging && (
        <div className="relative z-10 w-full h-full flex items-center justify-center cursor-grab active:cursor-grabbing">
          <div className="drop-shadow-md group-hover:scale-110 transition-transform duration-200">
            <RunIcon type={scheduledRun.type} color={cellColors?.vibrant || ''} />
          </div>
        </div>
      )}

      {/* Drop indicator glow */}
      {isOver && canDrop && !scheduledRun && (
        <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-violet-400/30 via-blue-400/30 to-fuchsia-400/30 animate-pulse" />
      )}

      {/* Empty cell hint */}
      {!scheduledRun && !isOver && (
        <div className="relative z-10 text-slate-300 group-hover:text-slate-400 transition-colors">
          <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
        </div>
      )}
    </div>
  );
}

function RunIcon({ type, color }: { type: RunType; color: string }) {
  if (type === 'easy') {
    return (
      <svg className="w-[28px] h-[28px]" viewBox="0 0 36 36" fill="none">
        <path d={svgPaths.p62d3580} fill={color} />
      </svg>
    );
  }

  if (type === 'tempo') {
    return (
      <svg className="w-[24px] h-[22px]" viewBox="0 0 30.375 28.124" fill="none">
        <path d={svgPaths.p3d035380} fill={color} />
      </svg>
    );
  }

  if (type === 'race') {
    return (
      <svg className="w-[24px] h-[22px]" viewBox="0 0 30.375 28.124" fill="none">
        <path d={svgPaths.p22eee900} fill={color} />
      </svg>
    );
  }

  if (type === 'longRun') {
    return (
      <svg className="w-[24px] h-[22px]" viewBox="0 0 30.375 28.124" fill="none">
        <path d={svgPaths.p22eee900} fill={color} />
      </svg>
    );
  }

  return null;
}